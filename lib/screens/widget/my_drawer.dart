import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:quran_al_kareem/provider/language_providrer.dart';
import 'package:quran_al_kareem/screens/drawer_pages/allah_names.dart';
import 'package:quran_al_kareem/screens/drawer_pages/tasbeeh_counter.dart';
import 'package:quran_al_kareem/screens/main_dashboard.dart';
import 'package:quran_al_kareem/screens/other/dua_screen.dart';
import 'package:quran_al_kareem/screens/other/hadith_screen.dart';
import 'package:quran_al_kareem/screens/other/namaz_screen.dart';
import 'package:quran_al_kareem/utils/colors.dart';
import 'package:quran_al_kareem/screens/widget/arabic_text_widget.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({super.key});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  InterstitialAd? _interstitialAd;
  bool _isAdReady = false;
  int _actionCounter = 0; // Track user actions for frequency

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _loadInterstitialAd();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId:
          'ca-app-pub-7677534136736515/6010431655', // Your real interstitial Ad Unit ID
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _isAdReady = true;
          _interstitialAd!.setImmersiveMode(true);
        },
        onAdFailedToLoad: (LoadAdError error) {
          _isAdReady = false;
        },
      ),
    );
  }

  void _showInterstitialAndNavigate(Widget page) {
    _actionCounter++;

    // List of pages where we skip ads (sensitive content)
    final skipAdPages = [
      MainDashboard,
      NamazGuideScreen,
      DuaScreen,
      AllahNames,
      TasbeehScreen,
    ];

    // Skip ad if page is in sensitive screens
    if (skipAdPages.any((type) => page.runtimeType == type)) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      return;
    }

    // Show interstitial every 3 actions if ad is ready
    if (_isAdReady && _interstitialAd != null && _actionCounter % 3 == 0) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _loadInterstitialAd();
          Navigator.push(context, MaterialPageRoute(builder: (_) => page));
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          Navigator.push(context, MaterialPageRoute(builder: (_) => page));
        },
      );

      // Optional small delay for better UX
      Future.delayed(const Duration(milliseconds: 500), () {
        _interstitialAd!.show();
      });
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Drawer(
      backgroundColor: mainColor,
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Image.asset("assets/logo.png", height: 150, width: 150),
            ),
            const Divider(),

            // Audio Quran
            _drawerItem(
              icon: Icons.audio_file,
              text:
                  languageProvider.localizedStrings["Audio Quran"] ??
                  'Audio Quran',
              onTap: () => _showInterstitialAndNavigate(
                const MainDashboard(initialPageIndex: 1),
              ),
            ),

            // Hadith
            _drawerItem(
              icon: Ionicons.book,
              text: languageProvider.localizedStrings["Hadith"] ?? 'Hadith',
              onTap: () => _showInterstitialAndNavigate(const HadithScreen()),
            ),

            // Qibla
            _drawerItem(
              icon: Icons.explore,
              text: languageProvider.localizedStrings["Qibla"] ?? 'Qibla',
              onTap: () => _showInterstitialAndNavigate(
                MainDashboard(initialPageIndex: 3),
              ),
            ),

            // Prayer Times
            _drawerItem(
              icon: Icons.access_time,
              text:
                  languageProvider.localizedStrings["Prayer Times"] ??
                  'Prayer Times',
              onTap: () => _showInterstitialAndNavigate(
                MainDashboard(initialPageIndex: 2),
              ),
            ),

            // Namaz Guide
            _drawerItem(
              icon: Ionicons.calendar_number_sharp,
              text: languageProvider.localizedStrings["Namaz"] ?? 'Namaz',
              onTap: () =>
                  _showInterstitialAndNavigate(const NamazGuideScreen()),
            ),

            // Dua
            _drawerItem(
              icon: Ionicons.book_sharp,
              text: languageProvider.localizedStrings["Dua"] ?? 'Dua',
              onTap: () => _showInterstitialAndNavigate(const DuaScreen()),
            ),

            // Allah Names
            _drawerItem(
              icon: Ionicons.book_outline,
              text:
                  languageProvider.localizedStrings["Allah Names"] ??
                  'Allah Names',
              onTap: () => _showInterstitialAndNavigate(const AllahNames()),
            ),

            // Tasbeeh Counter
            _drawerItem(
              icon: Icons.countertops,
              text:
                  languageProvider.localizedStrings["Tasbeeh Counter"] ??
                  'Tasbeeh Counter',
              onTap: () => _showInterstitialAndNavigate(const TasbeehScreen()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.white),
          title: ArabicText(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            textAlign: TextAlign.left,
          ),
          onTap: onTap,
        ),
        const Divider(color: Colors.white24),
      ],
    );
  }
}
