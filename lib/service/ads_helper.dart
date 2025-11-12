import 'package:flutter/material.dart';
import 'package:quran_al_kareem/service/ads_service.dart';

class AppLifecycleReactor with WidgetsBindingObserver {
  final AppOpenAdManager adManager;

  AppLifecycleReactor({required this.adManager}) {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      adManager.showAdIfAvailable();
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }
}
