import 'dart:async';
import 'package:flutter/material.dart';
import 'package:quran_al_kareem/model/prayer_model.dart';
import 'package:quran_al_kareem/screens/auth/login_screen.dart';
import 'package:quran_al_kareem/service/ads_service.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 1. Import Firebase Auth
import 'package:quran_al_kareem/screens/main_dashboard.dart'; // 2. Import Main Dashboard

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
      // Show the App Open Ad, then navigate
      widget.adManager.showAdIfAvailable(onAdClosed: _determineNextScreen);
    } else {
      // Go straight to the auth check
      _determineNextScreen();
    }
  }

  // 🌟 NEW FUNCTION: Determines if the user is logged in
  void _determineNextScreen() {
    // Check if a user is currently logged in
    final user = FirebaseAuth.instance.currentUser;
    final Widget nextScreen;

    if (user != null) {
      // User is logged in, go to the Main Dashboard
      nextScreen = const MainDashboard(initialPageIndex: 0);
    } else {
      // User is not logged in, go to the Login Screen
      nextScreen = const LoginScreen();
    }

    // Replace the Splash Screen with the determined next screen
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => nextScreen));
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
