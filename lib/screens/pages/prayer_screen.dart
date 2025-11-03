import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quran_al_kareem/screens/other/hadith_screen.dart';
import 'package:quran_al_kareem/service/location_service.dart';
import 'package:quran_al_kareem/service/prayer_time_service.dart';
import 'package:quran_al_kareem/utils/paint.dart';

class PrayerScreen extends StatefulWidget {
  const PrayerScreen({super.key});

  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? timings;
  String? hijriDate;
  bool isLoading = true;
  String? error;
  String? nextPrayerName;
  Duration? timeRemaining;
  Timer? countdownTimer;
  Timer? backgroundTimer;
  late List<Color> _gradientColors;
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;
  late AnimationController _fajrGlowController;

  @override
  void initState() {
    super.initState();
    _gradientColors = [Colors.indigo.shade900, Colors.black];
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
    _fajrGlowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
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
      _setGradientFromPrayerTimes();
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

  void _setGradientFromPrayerTimes() {
    if (timings == null) return;
    final now = DateTime.now();

    DateTime parsePrayer(String name) {
      final t = DateFormat('HH:mm').parse(timings![name]);
      return DateTime(now.year, now.month, now.day, t.hour, t.minute);
    }

    final fajr = parsePrayer('Fajr');
    final maghrib = parsePrayer('Maghrib');

    if (now.isAfter(fajr.subtract(const Duration(minutes: 30))) &&
        now.isBefore(fajr.add(const Duration(hours: 1)))) {
      // Fajr: sunrise colors
      _gradientColors = [Colors.orange.shade200, Colors.blue.shade300];
    } else if (now.isAfter(fajr.add(const Duration(hours: 1))) &&
        now.isBefore(maghrib.subtract(const Duration(hours: 2)))) {
      // Day
      _gradientColors = [Colors.lightBlue.shade200, Colors.blueAccent.shade700];
    } else if (now.isAfter(maghrib.subtract(const Duration(hours: 1))) &&
        now.isBefore(maghrib.add(const Duration(hours: 1)))) {
      // Sunset
      _gradientColors = [Colors.deepOrange.shade300, Colors.purple.shade100];
    } else {
      // Night
      _gradientColors = [Colors.indigo.shade900, Colors.black];
    }
  }

  bool get isFajrTime {
    if (timings == null) return false;
    final now = DateTime.now();
    final fajr = DateFormat('HH:mm').parse(timings!['Fajr']);
    final fajrTime = DateTime(
      now.year,
      now.month,
      now.day,
      fajr.hour,
      fajr.minute,
    );
    return now.isAfter(fajrTime.subtract(const Duration(minutes: 30))) &&
        now.isBefore(fajrTime.add(const Duration(hours: 1)));
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    backgroundTimer?.cancel();
    _scrollController.dispose();
    _fajrGlowController.dispose();
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
      body: Stack(
        children: [
          // 🌌 Animated Gradient Background
          AnimatedContainer(
            duration: const Duration(seconds: 3),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _gradientColors,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // 🌠 Floating Stars at Night
          if (_gradientColors.first == Colors.indigo.shade900)
            CustomPaint(painter: StarFieldPainter(), child: Container()),

          // 🌅 Fajr Glowing Rays
          if (isFajrTime)
            AnimatedBuilder(
              animation: _fajrGlowController,
              builder: (context, _) {
                final glow = Tween<double>(begin: 0.4, end: 1.0)
                    .animate(
                      CurvedAnimation(
                        parent: _fajrGlowController,
                        curve: Curves.easeInOut,
                      ),
                    )
                    .value;
                return Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Colors.yellowAccent.withOpacity(glow * 0.2),
                        Colors.transparent,
                      ],
                      radius: 1.2,
                      center: Alignment(0, -0.6),
                    ),
                  ),
                );
              },
            ),

          // 🌙 Main Content
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
                                color: Colors.amber,
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
                                color: Colors.black26.withOpacity(0.4),
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
                      Container(
                        width: 400,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Color(0xffFFFFFF).withOpacity(.2),
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  //Hadith
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (builder) => HadithScreen(),
                                        ),
                                      );
                                    },
                                    child: Image.asset(
                                      "assets/item 1.png",
                                      height: 90,
                                      width: 90,
                                    ),
                                  ),
                                  //Dua
                                  Image.asset(
                                    "assets/item 2-1.png",
                                    height: 90,
                                    width: 90,
                                  ),
                                  //Allah Names
                                  Image.asset(
                                    "assets/item 3.png",
                                    height: 90,
                                    width: 90,
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                //Namaz
                                Image.asset(
                                  "assets/item 2.png",
                                  height: 90,
                                  width: 90,
                                ),
                                //Qibla
                                Image.asset(
                                  "assets/item 1-1.png",
                                  height: 90,
                                  width: 90,
                                ),
                                //Allah Names
                                Image.asset(
                                  "assets/item 3.png",
                                  height: 90,
                                  width: 90,
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
