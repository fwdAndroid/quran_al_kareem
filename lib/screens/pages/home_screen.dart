import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quran_al_kareem/model/prayer_model.dart';
import 'package:quran_al_kareem/provider/language_providrer.dart';
import 'package:quran_al_kareem/screens/drawer_pages/allah_names.dart';
import 'package:quran_al_kareem/screens/drawer_pages/tasbeeh_counter.dart';
import 'package:quran_al_kareem/screens/main_dashboard.dart';
import 'package:quran_al_kareem/screens/other/dua_screen.dart';
import 'package:quran_al_kareem/screens/other/hadith_screen.dart';
import 'package:quran_al_kareem/screens/other/namaz_screen.dart';
import 'package:quran_al_kareem/screens/pages/quran_screen.dart';
import 'package:quran_al_kareem/utils/banner_util.dart';
import 'package:shimmer/shimmer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quran_al_kareem/utils/colors.dart';
// 🆕 Import the PrayerDataStore service

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
  // 🆕 Initial loading state is determined by the store
  bool isLoadingPrayer = true;
  String? errorPrayer;
  Map<String, String> timings = {}; // Fajr, Dhuhr, Asr, Maghrib, Isha
  String? cityName;
  String? hijriDate;
  String? nextPrayerName;
  Duration? timeRemaining;
  Timer? countdownTimer;

  // UI constants
  // Note: cardColor definition uses incorrect hex, assuming 0xffA5A5C as intended
  static const Color cardColor = Color(0xff2A5A5C);
  static const Color lightCard = Color(0xFFE8F6F5);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBannerAd();
    });
    fetchUserData();

    // 🆕 Initialize the prayer flow using the preloaded data
    _initPrayerFlow();
  }

  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  @override
  void dispose() {
    _bannerAd?.dispose();
    countdownTimer?.cancel();
    super.dispose();
  }

  // --------------------------
  // User data from Firestore
  // (Unchanged)
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
    // 1. Check for preloaded data (instant load)
    if (PrayerDataStore.isPreloaded) {
      if (PrayerDataStore.timings != null) {
        setState(() {
          timings = PrayerDataStore.timings!.map(
            (k, v) => MapEntry(k, v as String),
          );
          hijriDate = PrayerDataStore.hijriDate;
          errorPrayer = PrayerDataStore.error;
          isLoadingPrayer = false;
        });
        determineNextPrayer();
      } else if (PrayerDataStore.error != null) {
        // Data loaded but failed (error present)
        setState(() {
          errorPrayer = PrayerDataStore.error;
          isLoadingPrayer = false;
        });
      }
    }

    // 2. If not preloaded or timings are null (failed), fetch now (fallback)
    if (timings.isEmpty && isLoadingPrayer) {
      await _fetchPrayerTimesAndStart();
    }
  }

  // --------------------------
  // Main fetch: get location -> call AlAdhan API
  // NOTE: This logic is largely redundant now but kept as a fallback/refresh
  // --------------------------
  Future<void> _fetchPrayerTimesAndStart() async {
    setState(() {
      isLoadingPrayer = true;
      errorPrayer = null;
    });

    try {
      final pos = await _determinePosition();
      final data = await _fetchTimingsFromAlAdhan(pos.latitude, pos.longitude);

      // --- Use data structure from PrayerDataStore's fetch logic ---
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
        cityName = meta['timezone'] as String? ?? 'Your Location';
      } else {
        cityName = 'Your Location';
      }

      final date = data['data']['date'] as Map<String, dynamic>?;
      if (date != null && date['hijri'] != null) {
        hijriDate = (date['hijri']['date'] as String?) ?? "";
      } else {
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

  //Ads
  Future<void> _loadBannerAd() async {
    final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      MediaQuery.of(context).size.width.truncate(),
    );

    if (size == null) return;

    final banner = BannerAd(
      adUnitId: "ca-app-pub-3940256099942544/6300978111", // live banner ID
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint("Banner loaded successfully");
          setState(() {
            _bannerAd = ad as BannerAd;
            _isBannerAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint("Banner failed to load: $error");
          ad.dispose();
          Future.delayed(const Duration(seconds: 5), _loadBannerAd);
        },
      ),
    );

    banner.load();
  }

  // --------------------------
  // AlAdhan API call (kept for refresh/fallback)
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
  // Geolocator wrapper (kept for refresh/fallback)
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
  // normalize "05:12 (PKT)" -> "05:12" (Unchanged)
  // --------------------------
  String _normalizeTime(String s) {
    if (s.length >= 5 && RegExp(r'\d{1,2}:\d{2}').hasMatch(s)) {
      final match = RegExp(r'\d{1,2}:\d{2}').firstMatch(s);
      if (match != null) return match.group(0)!;
    }
    return s;
  }

  // --------------------------
  // Next prayer logic & countdown (Unchanged)
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
    // Use the global store refresh for consistency
    await PrayerDataStore.preloadData();

    // Update state from the global store after refresh
    if (mounted) {
      setState(() {
        timings =
            PrayerDataStore.timings?.map((k, v) => MapEntry(k, v as String)) ??
            {};
        hijriDate = PrayerDataStore.hijriDate;
        errorPrayer = PrayerDataStore.error;
        isLoadingPrayer = timings.isEmpty;
      });
      if (timings.isNotEmpty) {
        determineNextPrayer();
      }
    }
  }

  // --------------------------
  // Utils & UI (Unchanged)
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

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: mainColor,
      body: Column(
        children: [
          if (_isBannerAdLoaded && _bannerAd != null)
            Container(
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              alignment: Alignment.center,
              child: AdWidget(ad: _bannerAd!),
            ),

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
                "السلام عليكم!",
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
                    children: [
                      Text(
                        lang.localizedStrings["Remember Allah"] ??
                            "Remember Allah",
                        style: TextStyle(
                          color: Colors.blueGrey,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        lang.localizedStrings["Start Tasbih\nCounter"] ??
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
                          child: Text(
                            lang.localizedStrings["Get Start Now"] ??
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
                    _featureGrid(lang),
                    const SizedBox(height: 10),
                    _prayerTimingCard(lang),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Feature grid (unchanged)
  Widget _featureGrid(LanguageProvider language) {
    final items = [
      {
        "label": language.localizedStrings["Tasbih"] ?? "Tasbih",
        "icon": Icons.fingerprint,
        "onTap": () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TasbeehScreen()),
          );
        },
      },
      {
        "label": language.localizedStrings["Hadith"] ?? "Hadith",
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
        "label": language.localizedStrings["Dua"] ?? "Dua",
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
        "label": language.localizedStrings["Al-Quran"] ?? "Al-Quran",
        "icon": Icons.book,
        "onTap": () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => QuranScreen()),
          );
        },
      },
      {
        "label": language.localizedStrings["Allah Names"] ?? "Allah Names",
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
        "label": language.localizedStrings["Namaz"] ?? "Namaz",
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

  // Prayer card: shimmer when loading, dynamic times when ready (Unchanged logic, uses new state)
  Widget _prayerTimingCard(LanguageProvider language) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: isLoadingPrayer
          ? _buildPrayerShimmer()
          : (errorPrayer != null
                ? _buildPrayerError()
                : _buildPrayerContent(language)),
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
          // 🔄 Use the refresh function which uses the store
          onPressed: _fetchPrayerRefresh,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.black87),
          child: const Text('Retry'),
        ),
      ],
    );
  }

  Widget _buildPrayerContent(LanguageProvider language) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            language.localizedStrings["Namaz Timings"] ?? "Namaz Timings",
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
