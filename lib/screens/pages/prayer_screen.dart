import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:quran_al_kareem/model/prayer_model.dart';
import 'package:shimmer/shimmer.dart';

// Import the static data store

// Existing Imports
import 'package:quran_al_kareem/screens/drawer_pages/tasbeeh_counter.dart';
import 'package:quran_al_kareem/screens/pages/quran_screen.dart';
import 'package:quran_al_kareem/service/anayltics_helper.dart';
import 'package:quran_al_kareem/screens/drawer_pages/allah_names.dart';
import 'package:quran_al_kareem/screens/other/dua_screen.dart';
import 'package:quran_al_kareem/screens/other/hadith_screen.dart';
import 'package:quran_al_kareem/screens/other/namaz_screen.dart';
import 'package:quran_al_kareem/screens/widget/arabic_text_widget.dart';
import 'package:quran_al_kareem/utils/colors.dart';

// Placeholder/Example global key reference
const String bannerKey = 'ca-app-pub-3940256099942544/6300978111';

class PrayerScreen extends StatefulWidget {
  // Constructor remains simple
  const PrayerScreen({super.key});

  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {
  Map<String, dynamic>? timings;
  String? hijriDate;
  // isLoading is now controlled by the static check
  bool isLoading = true;
  String? error;
  String? nextPrayerName;
  Duration? timeRemaining;
  Timer? countdownTimer;
  final ScrollController _scrollController = ScrollController();
  double scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBannerAd();
    });
    _scrollController.addListener(() {
      setState(() {
        scrollOffset = _scrollController.offset;
      });
    });

    // 🌟 NEW: Check Static Data Store for instant load 🌟
    if (PrayerDataStore.isPreloaded) {
      timings = PrayerDataStore.timings;
      hijriDate = PrayerDataStore.hijriDate;
      error = PrayerDataStore.error;

      isLoading = timings == null; // Only show loading/error if data is null

      if (timings != null) {
        determineNextPrayer();
      }
    } else {
      // Fallback: If for any reason the splash screen was skipped, load it now
      loadPrayerTimes();
    }

    AnalyticsHelper.logScreenView("PrayerScreen");
  }

  // Fallback and Refresh logic (can be triggered by a pull-to-refresh)
  Future<void> loadPrayerTimes() async {
    try {
      // Re-run the preload logic to fetch the latest data
      await PrayerDataStore.preloadData();

      // Update local state from the static store
      setState(() {
        timings = PrayerDataStore.timings;
        hijriDate = PrayerDataStore.hijriDate;
        error = PrayerDataStore.error;
        isLoading = timings == null;
      });

      if (timings != null) {
        determineNextPrayer();
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  void determineNextPrayer() {
    final now = DateTime.now();
    if (timings == null) return;

    final prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

    for (var prayer in prayers) {
      final timeString = timings![prayer];
      final timeParts = timeString.split(' ')[0];
      final prayerTime = DateFormat('HH:mm').parse(timeParts);

      final dateTime = DateTime(
        now.year,
        now.month,
        now.day,
        prayerTime.hour,
        prayerTime.minute,
      );
      if (dateTime.isAfter(now)) {
        nextPrayerName = prayer;
        timeRemaining = dateTime.difference(now);
        startCountdown();
        return;
      }
    }

    // Next Fajr is tomorrow
    nextPrayerName = 'Fajr (Tomorrow)';
    final timeString = timings!['Fajr'];
    final timeParts = timeString.split(' ')[0];
    final fajrTime = DateFormat('HH:mm').parse(timeParts);
    final tomorrow = now.add(const Duration(days: 1));
    final nextFajr = DateTime(
      tomorrow.year,
      tomorrow.month,
      tomorrow.day,
      fajrTime.hour,
      fajrTime.minute,
    );
    timeRemaining = nextFajr.difference(now);
    startCountdown();
  }

  void startCountdown() {
    countdownTimer?.cancel();
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (timeRemaining!.inSeconds <= 0) {
            determineNextPrayer();
          } else {
            timeRemaining = timeRemaining! - const Duration(seconds: 1);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    return "${hours.toString().padLeft(2, '0')}:"
        "${minutes.toString().padLeft(2, '0')}:"
        "${seconds.toString().padLeft(2, '0')}";
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

  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  Future<void> _loadBannerAd() async {
    final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      MediaQuery.of(context).size.width.truncate(),
    );
    final adSize = size ?? AdSize.banner;

    _bannerAd = BannerAd(
      adUnitId: bannerKey,
      size: adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() => _isBannerAdLoaded = true),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          Future.delayed(const Duration(seconds: 5), _loadBannerAd);
        },
      ),
    )..load();
  }

  static const Color lightCard = Color(0xFFE8F6F5);
  // mainColor is assumed to be defined in utils/colors.dart

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/bg.png", fit: BoxFit.cover),
          ),
          Container(color: mainColor.withOpacity(0.3)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  if (_isBannerAdLoaded && _bannerAd != null)
                    Container(
                      width: _bannerAd!.size.width.toDouble(),
                      height: _bannerAd!.size.height.toDouble(),
                      alignment: Alignment.center,
                      child: AdWidget(ad: _bannerAd!),
                    ),

                  // Display Error if it exists
                  if (error != null)
                    Text(
                      'Error: $error',
                      style: const TextStyle(color: Colors.redAccent),
                    ),

                  ArabicText(
                    "🗓 Hijri Date: ${hijriDate ?? (isLoading ? 'Loading...' : 'N/A')}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),

                  // ⏳ Next prayer shimmer/widget
                  isLoading
                      ? Shimmer.fromColors(
                          baseColor: Colors.grey[400]!,
                          highlightColor: Colors.grey[100]!,
                          child: Column(
                            children: [
                              Container(
                                width: 180,
                                height: 22,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 6),
                              Container(
                                width: 120,
                                height: 28,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        )
                      : Column(
                          children: [
                            if (nextPrayerName != null)
                              ArabicText(
                                "Next Prayer: ${nextPrayerName!.replaceAll(' (Tomorrow)', '')}",
                                style: const TextStyle(
                                  fontSize: 22,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            const SizedBox(height: 6),
                            if (timeRemaining != null &&
                                timeRemaining!.inSeconds > 0)
                              ArabicText(
                                formatDuration(timeRemaining!),
                                style: const TextStyle(
                                  fontSize: 30,
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            else if (nextPrayerName != null)
                              const ArabicText(
                                "Time for Prayer!",
                                style: TextStyle(
                                  fontSize: 30,
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),

                  const SizedBox(height: 20),

                  // 📿 Prayer times shimmer or list
                  Expanded(
                    child: isLoading
                        ? ListView.builder(
                            itemCount: 5,
                            itemBuilder: (_, __) => Shimmer.fromColors(
                              baseColor: Colors.grey[400]!,
                              highlightColor: Colors.grey[100]!,
                              child: Card(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ListTile(
                                  leading: Container(
                                    width: 40,
                                    height: 40,
                                    color: Colors.white,
                                  ),
                                  title: Container(
                                    width: 100,
                                    height: 18,
                                    color: Colors.white,
                                  ),
                                  trailing: Container(
                                    width: 60,
                                    height: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            itemCount: timings!.length,
                            itemBuilder: (context, index) {
                              final entry = timings!.entries.elementAt(index);
                              final icon = getPrayerIcon(entry.key);
                              final isNextPrayer =
                                  entry.key ==
                                  nextPrayerName?.replaceAll(' (Tomorrow)', '');

                              return Card(
                                color: isNextPrayer
                                    ? mainColor
                                    : const Color(0xff326c6d),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ListTile(
                                  leading: Icon(icon, color: Colors.amber),
                                  title: ArabicText(
                                    entry.key,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  trailing: ArabicText(
                                    entry.value,
                                    style: TextStyle(
                                      color: isNextPrayer
                                          ? Colors.white
                                          : Colors.white70,
                                      fontSize: 16,
                                      fontWeight: isNextPrayer
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 10),
                  // 🔹 Bottom buttons
                  Container(
                    width: double.infinity,
                    height: 200,
                    child: _featureGrid(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Your existing _featureGrid code remains unchanged
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
        },
      },
      {
        "label": "Allah Names",
        "icon": Icons.compass_calibration,
        "onTap": () {
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
        childAspectRatio: 16 / 12,
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
}
