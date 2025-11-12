import 'dart:async';
import 'package:flutter/material.dart';
import 'package:quran_al_kareem/screens/auth/login_screen.dart';
import 'package:quran_al_kareem/service/ads_service.dart';

class SplashScreen extends StatefulWidget {
  final AppOpenAdManager adManager;

  const SplashScreen({Key? key, required this.adManager}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Start splash
    Timer(const Duration(seconds: 6), _showAppOpenAd);
  }

  void _showAppOpenAd() {
    if (widget.adManager.isAdAvailable) {
      // Show the App Open Ad, then navigate when ad is closed
      widget.adManager.showAdIfAvailable(onAdClosed: _goToLoginScreen);
    } else {
      // If ad is not ready, go straight to login
      _goToLoginScreen();
    }
  }

  void _goToLoginScreen() {
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
