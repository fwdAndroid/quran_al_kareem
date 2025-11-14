import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:ionicons/ionicons.dart';
import 'package:quran_al_kareem/provider/language_providrer.dart';
import 'package:quran_al_kareem/screens/pages/audio_screen.dart';
import 'package:quran_al_kareem/screens/pages/prayer_screen.dart';
import 'package:quran_al_kareem/screens/pages/qibla_screen.dart';
import 'package:quran_al_kareem/screens/pages/quran_screen.dart';
import 'package:quran_al_kareem/screens/pages/setting_screen.dart';
import 'package:quran_al_kareem/screens/widget/arabic_text_widget.dart';
import 'package:quran_al_kareem/utils/colors.dart';
import 'package:quran_al_kareem/utils/banner_util.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class MainDashboard extends StatefulWidget {
  final int initialPageIndex;

  const MainDashboard({super.key, this.initialPageIndex = 0});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _selectedIndex = 0;
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  final List<Widget> _screens = [
    const QuranScreen(),
    const AudioQuranScreen(),
    PrayerScreen(),
    QiblaScreen(),
    const SettingScreen(),
  ];

  final List<String> _screenNames = [
    "QuranScreen",
    "AudioQuranScreen",
    "PrayerScreen",
    "QiblaScreen",
    "SettingScreen",
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialPageIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBannerAd();
      _logScreenView(_selectedIndex);
    });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

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

  Future<void> _logScreenView(int index) async {
    try {
      await _analytics.logEvent(
        name: 'screen_view',
        parameters: {
          'screen_name': _screenNames[index],
          'screen_class': _screenNames[index],
        },
      );
      debugPrint("Screen logged: ${_screenNames[index]}");
    } catch (e) {
      debugPrint("Failed to log screen view: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await _showExitDialog(context);
        return shouldPop ?? false;
      },
      child: Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isBannerAdLoaded && _bannerAd != null)
              Container(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                alignment: Alignment.center,
                child: AdWidget(ad: _bannerAd!),
              ),

            Padding(
              padding: const EdgeInsets.only(bottom: 6, left: 6, right: 6),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 12,
                        spreadRadius: 2,
                        offset: Offset(0, 4), // Floating shadow
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(5, (index) {
                      final bool isSelected = _selectedIndex == index;

                      final icons = [
                        Ionicons.book_outline,
                        Ionicons.book,
                        Ionicons.time_outline,
                        Ionicons.compass_outline,
                        Ionicons.settings_outline,
                      ];

                      final activeIcons = [
                        Ionicons.book,
                        Ionicons.hand_left,
                        Ionicons.time,
                        Ionicons.compass,
                        Ionicons.settings,
                      ];

                      final labels = [
                        languageProvider.localizedStrings["Quran"] ?? "Quran",
                        languageProvider.localizedStrings["Audio Quran"] ??
                            "Audio Quran",
                        languageProvider.localizedStrings["Prayer"] ?? "Prayer",
                        languageProvider.localizedStrings["Qibla"] ?? "Qibla",
                        languageProvider.localizedStrings["Settings"] ??
                            "Settings",
                      ];

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedIndex = index;
                            _logScreenView(index);
                          });
                        },
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 250),
                          padding: EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 6,
                          ),
                          decoration: isSelected
                              ? BoxDecoration(
                                  color: Colors.amber.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(
                                    12,
                                  ), // BORDER RADIUS ONLY
                                )
                              : null,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isSelected ? activeIcons[index] : icons[index],
                                color: isSelected
                                    ? Colors.amber
                                    : Colors.black54,
                              ),
                              Text(
                                labels[index],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSelected
                                      ? Colors.amber
                                      : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showExitDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: ArabicText('Exit App', style: TextStyle(color: primaryText)),
        content: ArabicText(
          'Do you want to exit the app',
          style: TextStyle(color: primaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: ArabicText('No', style: TextStyle(color: primaryText)),
          ),
          TextButton(
            onPressed: () {
              if (Platform.isAndroid) {
                SystemNavigator.pop();
              } else if (Platform.isIOS) {
                exit(0);
              }
            },
            child: ArabicText('Yes', style: TextStyle(color: primaryText)),
          ),
        ],
      ),
    );
  }
}
