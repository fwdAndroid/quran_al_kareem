import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quran_al_kareem/screens/drawer_pages/allah_names.dart';
import 'package:quran_al_kareem/screens/other/dua_screen.dart';
import 'package:quran_al_kareem/screens/other/hadith_screen.dart';
import 'package:quran_al_kareem/screens/other/namaz_screen.dart';
import 'package:quran_al_kareem/screens/pages/qibla_screen.dart';
import 'package:quran_al_kareem/service/location_service.dart';
import 'package:quran_al_kareem/service/prayer_time_service.dart';
import 'package:quran_al_kareem/utils/colors.dart';
import 'package:quran_al_kareem/utils/paint.dart';

class PrayerScreen extends StatefulWidget {
  const PrayerScreen({super.key});

  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {
  Map<String, dynamic>? timings;
  String? hijriDate;
  bool isLoading = true;
  String? error;
  String? nextPrayerName;
  Duration? timeRemaining;
  Timer? countdownTimer;
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
    loadPrayerTimes();
  }

  Future<void> loadPrayerTimes() async {
    try {
      setState(() => isLoading = true);
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
      determineNextPrayer();
      setState(() => isLoading = false);
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  void determineNextPrayer() {
    final now = DateTime.now();
    final prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

    for (var prayer in prayers) {
      final timeString = timings![prayer];
      final prayerTime = DateFormat('HH:mm').parse(timeString);
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

    nextPrayerName = 'Fajr (Tomorrow)';
    final fajrTime = DateFormat('HH:mm').parse(timings!['Fajr']);
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
          timeRemaining = timeRemaining! - const Duration(seconds: 1);
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (error != null) {
      return Scaffold(body: Center(child: Text('Error: $error')));
    }

    return Scaffold(
      backgroundColor: mainColor,

      body: Stack(
        children: [
          // Plain Background Color
          Positioned.fill(
            child: Image.asset("assets/bg.png", fit: BoxFit.cover),
          ),
          Container(
            color: mainColor.withOpacity(
              0.3,
            ), // optional overlay for better contrast
          ),
          SafeArea(
            child: NotificationListener<ScrollNotification>(
              onNotification: (_) {
                setState(() {});
                return false;
              },
              child: Transform.translate(
                offset: Offset(0, -_scrollOffset * 0.2),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        "🗓 Hijri Date: $hijriDate",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (timeRemaining != null)
                        Column(
                          children: [
                            Text(
                              "Next Prayer: $nextPrayerName",
                              style: const TextStyle(
                                fontSize: 22,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              formatDuration(timeRemaining!),
                              style: const TextStyle(
                                fontSize: 30,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: timings!.length,
                          itemBuilder: (context, index) {
                            final entry = timings!.entries.elementAt(index);
                            final icon = getPrayerIcon(entry.key);
                            return Transform.translate(
                              offset: Offset(0, -_scrollOffset * 0.05 * index),
                              child: Card(
                                color: Colors.black26.withOpacity(0.9),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ListTile(
                                  leading: Icon(icon, color: Colors.amber),
                                  title: Text(
                                    entry.key,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  trailing: Text(
                                    entry.value,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Bottom Buttons
                      Container(
                        width: 400,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  GestureDetector(
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => HadithScreen(),
                                      ),
                                    ),
                                    child: Image.asset(
                                      "assets/item 1.png",
                                      height: 90,
                                      width: 90,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => DuaScreen(),
                                      ),
                                    ),
                                    child: Image.asset(
                                      "assets/item 2-1.png",
                                      height: 90,
                                      width: 90,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => AllahNames(),
                                      ),
                                    ),
                                    child: Image.asset(
                                      "assets/item 3.png",
                                      height: 90,
                                      width: 90,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => NamazGuideScreen(),
                                    ),
                                  ),
                                  child: Image.asset(
                                    "assets/item 2.png",
                                    height: 90,
                                    width: 90,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => QiblaScreen(),
                                    ),
                                  ),
                                  child: Image.asset(
                                    "assets/item 1-1.png",
                                    height: 90,
                                    width: 90,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
