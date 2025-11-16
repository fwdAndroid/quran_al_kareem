// home_screen.dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:quran_al_kareem/screens/drawer_pages/allah_names.dart';
import 'package:quran_al_kareem/screens/drawer_pages/tasbeeh_counter.dart';
import 'package:quran_al_kareem/screens/main_dashboard.dart';
import 'package:quran_al_kareem/screens/other/dua_screen.dart';
import 'package:quran_al_kareem/screens/other/hadith_screen.dart';
import 'package:quran_al_kareem/screens/other/namaz_screen.dart';
import 'package:quran_al_kareem/screens/pages/quran_screen.dart';
import 'package:shimmer/shimmer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quran_al_kareem/utils/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- User data
  String userName = "User";
  String? profileImage;

  // --- Prayer data state
  bool isLoadingPrayer = true;
  String? errorPrayer;
  Map<String, String> timings = {}; // Fajr, Dhuhr, Asr, Maghrib, Isha
  String? cityName;
  String? hijriDate;
  String? nextPrayerName;
  Duration? timeRemaining;
  Timer? countdownTimer;

  // UI constants
  static const Color cardColor = Color(0xFFf2A5A5C);
  static const Color lightCard = Color(0xFFE8F6F5);

  @override
  void initState() {
    super.initState();
    fetchUserData();
    _initPrayerFlow();
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }

  // --------------------------
  // User data from Firestore
  // --------------------------
  Future<void> fetchUserData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .get();

      if (doc.exists) {
        setState(() {
          userName = doc["name"] ?? "User";
          profileImage = doc["image"];
        });
      }
    } catch (e) {
      // ignore errors for user fetch
      debugPrint("Error fetching user data: $e");
    }
  }

  // --------------------------
  // Init prayer loading flow
  // --------------------------
  Future<void> _initPrayerFlow() async {
    await _fetchPrayerTimesAndStart();
  }

  // --------------------------
  // Main fetch: get location -> call AlAdhan API
  // --------------------------
  Future<void> _fetchPrayerTimesAndStart() async {
    setState(() {
      isLoadingPrayer = true;
      errorPrayer = null;
    });

    try {
      final pos = await _determinePosition();
      final data = await _fetchTimingsFromAlAdhan(pos.latitude, pos.longitude);

      // parse timings (take only HH:mm)
      final apiTimings = data['data']['timings'] as Map<String, dynamic>;
      timings = {
        'Fajr': _normalizeTime(apiTimings['Fajr'] as String),
        'Dhuhr': _normalizeTime(apiTimings['Dhuhr'] as String),
        'Asr': _normalizeTime(apiTimings['Asr'] as String),
        'Maghrib': _normalizeTime(apiTimings['Maghrib'] as String),
        'Isha': _normalizeTime(apiTimings['Isha'] as String),
      };

      // location / date
      final meta = data['data']['meta'] as Map<String, dynamic>?;
      if (meta != null) {
        // city is part of meta? AlAdhan returns timezone & method; fallback to reverse geocode if needed.
        cityName = meta['timezone'] as String? ?? 'Your Location';
      } else {
        cityName = 'Your Location';
      }

      // hijri date - AlAdhan returns date.hijri.date
      final date = data['data']['date'] as Map<String, dynamic>?;
      if (date != null && date['hijri'] != null) {
        hijriDate = (date['hijri']['date'] as String?) ?? "";
      } else {
        // fallback to gregorian formatted string
        hijriDate = DateFormat('dd MMM, yyyy').format(DateTime.now());
      }

      determineNextPrayer();

      setState(() {
        isLoadingPrayer = false;
      });
    } catch (e, st) {
      debugPrint('Prayer fetch error: $e\n$st');
      setState(() {
        isLoadingPrayer = false;
        errorPrayer = e.toString();
      });
    }
  }

  // --------------------------
  // AlAdhan API call
  // docs: https://aladhan.com/prayer-times-api
  // Example: https://api.aladhan.com/v1/timings?latitude=...&longitude=...&method=2
  // --------------------------
  Future<Map<String, dynamic>> _fetchTimingsFromAlAdhan(
    double lat,
    double lng,
  ) async {
    final uri = Uri.parse(
      'https://api.aladhan.com/v1/timings?latitude=$lat&longitude=$lng&method=2',
    );
    final resp = await http.get(uri).timeout(const Duration(seconds: 15));
    if (resp.statusCode != 200) {
      throw Exception('Failed to fetch prayer times (${resp.statusCode})');
    }
    return jsonDecode(resp.body) as Map<String, dynamic>;
  }

  // --------------------------
  // Geolocator wrapper (permission & position)
  // --------------------------
  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // --------------------------
  // normalize "05:12 (PKT)" -> "05:12"
  // --------------------------
  String _normalizeTime(String s) {
    // keep first 5 chars if looks like HH:mm, else attempt to extract digits
    if (s.length >= 5 && RegExp(r'\d{1,2}:\d{2}').hasMatch(s)) {
      final match = RegExp(r'\d{1,2}:\d{2}').firstMatch(s);
      if (match != null) return match.group(0)!;
    }
    return s;
  }

  // --------------------------
  // Next prayer logic & countdown
  // --------------------------
  void determineNextPrayer() {
    if (timings.isEmpty) return;

    final now = DateTime.now();
    final order = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

    for (var prayer in order) {
      final timeStr = timings[prayer]!;
      final prayerTime = DateFormat('HH:mm').parse(timeStr);
      final dt = DateTime(
        now.year,
        now.month,
        now.day,
        prayerTime.hour,
        prayerTime.minute,
      );
      if (dt.isAfter(now)) {
        nextPrayerName = prayer;
        timeRemaining = dt.difference(now);
        startCountdown();
        return;
      }
    }

    // if we reach here → next is tomorrow's Fajr
    final fajr = DateFormat('HH:mm').parse(timings['Fajr']!);
    final tomorrow = now.add(const Duration(days: 1));
    final nextFajr = DateTime(
      tomorrow.year,
      tomorrow.month,
      tomorrow.day,
      fajr.hour,
      fajr.minute,
    );
    nextPrayerName = 'Fajr';
    timeRemaining = nextFajr.difference(now);
    startCountdown();
  }

  void startCountdown() {
    countdownTimer?.cancel();
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (timeRemaining == null) return;
        if (timeRemaining!.inSeconds <= 0) {
          // Re-fetch times when countdown completes to refresh for next prayer/day.
          _fetchPrayerRefresh();
        } else {
          timeRemaining = timeRemaining! - const Duration(seconds: 1);
        }
      });
    });
  }

  Future<void> _fetchPrayerRefresh() async {
    // small delay to avoid multiple rapid calls
    await Future.delayed(const Duration(seconds: 1));
    await _fetchPrayerTimesAndStart();
  }

  // --------------------------
  // Utils
  // --------------------------
  String formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  IconData getPrayerIcon(String name) {
    switch (name) {
      case 'Fajr':
        return Icons.wb_twilight;
      case 'Dhuhr':
        return Icons.wb_sunny;
      case 'Asr':
        return Icons.cloud;
      case 'Maghrib':
        return Icons.nights_stay;
      case 'Isha':
        return Icons.dark_mode;
      default:
        return Icons.access_time;
    }
  }

  // --------------------------
  // UI
  // --------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      body: Column(
        children: [
          const SizedBox(height: 50),

          // Header user row
          Padding(
            padding: const EdgeInsets.only(left: 4.0, right: 4, bottom: 2),
            child: ListTile(
              leading: CircleAvatar(
                radius: 24,
                backgroundImage:
                    profileImage != null && profileImage!.isNotEmpty
                    ? NetworkImage(profileImage!)
                    : const AssetImage("assets/logo.png") as ImageProvider,
              ),
              title: const Text(
                "Assalamu Alaikum!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                userName,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              trailing: GestureDetector(
                onTap: () {
                  // Navigate to settings screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const MainDashboard(initialPageIndex: 4),
                    ),
                  );
                },
                child: const Icon(
                  Icons.settings,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),

          // Tasbih card
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 2),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xffFDA946),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // left texts
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Remember Allah",
                        style: TextStyle(
                          color: Colors.blueGrey,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Start Tasbih\nCounter",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  // right image + button
                  Column(
                    children: [
                      Image.asset(
                        "assets/vecteezy_prayer-bead-perfect-for-muslim-islam-religious_-removebg-preview.png",
                        height: 60,
                        width: 60,
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TasbeehScreen(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xff152e2e),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "Get Start Now",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 15),

          // White container with rounded top
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Padding(
                // reduced top padding (moves grid up)
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _featureGrid(),
                    const SizedBox(height: 10),
                    _prayerTimingCard(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Feature grid (unchanged, reduced distance already applied via padding)
  Widget _featureGrid() {
    final items = [
      {
        "label": "Tasbih",
        "icon": Icons.fingerprint,
        "onTap": () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TasbeehScreen()),
          );
        },
      },
      {
        "label": "Hadith",
        "icon": Icons.menu_book,
        "onTap": () {
          // Navigate to Hadith screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => HadithScreen()),
          );
        },
      },
      {
        "label": "Dua",
        "icon": Icons.favorite,
        "onTap": () {
          // Navigate to Dua screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DuaScreen()),
          );
        },
      },
      {
        "label": "Al-Quran",
        "icon": Icons.book,
        "onTap": () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => QuranScreen()),
          );

          // Navigate to Quran screen
        },
      },
      {
        "label": "Allah Names",
        "icon": Icons.compass_calibration,
        "onTap": () {
          // Navigate to Wallpaper screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AllahNames()),
          );
        },
      },
      {
        "label": "Namaz",
        "icon": Icons.app_blocking,
        "onTap": () {
          // Navigate to Donation screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => NamazGuideScreen()),
          );
        },
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 16 / 13,
      ),
      itemBuilder: (_, i) {
        final item = items[i];
        return GestureDetector(
          onTap: item["onTap"] as void Function(),
          child: Container(
            decoration: BoxDecoration(
              color: lightCard,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item["icon"] as IconData, color: mainColor, size: 32),
                const SizedBox(height: 8),
                Text(
                  item["label"] as String,
                  style: TextStyle(
                    color: mainColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Prayer card: shimmer when loading, dynamic times when ready
  Widget _prayerTimingCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: isLoadingPrayer
          ? _buildPrayerShimmer()
          : (errorPrayer != null ? _buildPrayerError() : _buildPrayerContent()),
    );
  }

  Widget _buildPrayerShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade400,
      highlightColor: Colors.grey.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 14, width: 160, color: Colors.white),
          const SizedBox(height: 8),
          Container(height: 12, width: 220, color: Colors.white),
          const SizedBox(height: 10),
          Container(height: 90, width: double.infinity, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildPrayerError() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Prayer times unavailable',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(
          errorPrayer ?? '',
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () => _fetchPrayerTimesAndStart(),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.black87),
          child: const Text('Retry'),
        ),
      ],
    );
  }

  Widget _buildPrayerContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            "Namaz Timings",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Text(
              "🗓 Hijri Date: ${hijriDate ?? 'Loading...'}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Prayer row with icons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: timings.entries.map((entry) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      entry.value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      getPrayerIcon(entry.key),
                      color: Colors.white,
                      size: 30,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      entry.key,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
