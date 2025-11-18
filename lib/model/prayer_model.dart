// lib/service/prayer_data_store.dart

import 'dart:async';
import 'package:quran_al_kareem/service/location_service.dart';
import 'package:quran_al_kareem/service/prayer_time_service.dart';

class PrayerDataStore {
  // Static fields to hold the preloaded data
  static Map<String, dynamic>? timings;
  static String? hijriDate;
  static bool isPreloaded = false;

  // Static field to hold any loading error
  static String? error;

  // Static method to fetch and store the data
  static Future<void> preloadData() async {
    if (isPreloaded) return; // Avoid re-fetching if already done

    try {
      final position = await LocationService.getCurrentLocation();
      final data = await PrayerTimeService.fetchPrayerTimes(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      timings = {
        'Fajr': data['timings']['Fajr'],
        'Dhuhr': data['timings']['Dhuhr'],
        'Asr': data['timings']['Asr'],
        'Maghrib': data['timings']['Maghrib'],
        'Isha': data['timings']['Isha'],
      };

      hijriDate = data['date']['hijri']['date'];
      isPreloaded = true;
      error = null;
    } catch (e) {
      error = e.toString();
      isPreloaded = true; // Mark as loaded even on failure to proceed
      print("Error preloading prayer times: $e");
    }
  }
}
