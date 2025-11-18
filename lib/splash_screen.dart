import 'dart:async';
import 'package:flutter/material.dart';
import 'package:quran_al_kareem/model/prayer_model.dart';
import 'package:quran_al_kareem/screens/auth/login_screen.dart';
import 'package:quran_al_kareem/service/ads_service.dart';

class SplashScreen extends StatefulWidget {
  final AppOpenAdManager adManager;

  const SplashScreen({Key? key, required this.adManager}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _timerElapsed = false;

  @override
  void initState() {
    super.initState();

    // 1. Start preloading the data globally
    PrayerDataStore.preloadData().then((_) {
      if (mounted) {
        // Data is loaded (or failed), now check timer
        _attemptNavigation();
      }
    });

    // 2. Start the minimum display timer
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        _timerElapsed = true;
        _attemptNavigation();
      }
    });
  }

  void _attemptNavigation() {
    // Navigate only when the timer is done AND the data fetching is complete
    if (!PrayerDataStore.isPreloaded || !_timerElapsed || !mounted) return;

    if (widget.adManager.isAdAvailable) {
      // Show the App Open Ad, then navigate to login
      widget.adManager.showAdIfAvailable(onAdClosed: _goToLoginScreen);
    } else {
      // Go straight to login
      _goToLoginScreen();
    }
  }

  void _goToLoginScreen() {
    // Navigate to LoginScreen. The PrayerScreen will pick up the data later.
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(child: Image.asset('assets/logo.png', height: 200)),
      ),
    );
  }
}
