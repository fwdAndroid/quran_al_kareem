import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quran_al_kareem/screens/widget/arabic_text_widget.dart';
import 'package:quran_al_kareem/utils/colors.dart';

class TashbeehCounter extends StatefulWidget {
  const TashbeehCounter({super.key});

  @override
  State<TashbeehCounter> createState() => _TashbeehCounterState();
}

class _TashbeehCounterState extends State<TashbeehCounter> {
  int counter = 0;
  bool timerRunning = false;
  DateTime? startTime;
  Duration elapsed = Duration.zero;
  Timer? timer;

  List<Map<String, dynamic>> sessions = [];
  List<Map<String, dynamic>> currentSessionHistory = [];
  String chartPeriod = 'Weekly'; // For modal chart

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedSessions = prefs.getStringList('tasbeeh_sessions');
    if (savedSessions != null) {
      setState(() {
        sessions = savedSessions
            .map((s) => Map<String, dynamic>.from(jsonDecode(s)))
            .toList();
      });
    }
  }

  Future<void> _saveSessions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> stringSessions = sessions.map((s) => jsonEncode(s)).toList();
    await prefs.setStringList('tasbeeh_sessions', stringSessions);
  }

  void startTimer() {
    setState(() {
      counter = 0;
      elapsed = Duration.zero;
      timerRunning = true;
      startTime = DateTime.now();
      currentSessionHistory = [];
    });

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        elapsed = DateTime.now().difference(startTime!);
        // Update live graph every second
        currentSessionHistory.add({
          'count': counter,
          'time': DateTime.now().toIso8601String(),
        });
        if (currentSessionHistory.length > 20) {
          currentSessionHistory.removeAt(0); // keep last 20 points
        }
      });
    });
  }

  void stopTimer() {
    if (!timerRunning) return;

    timer?.cancel();
    setState(() {
      timerRunning = false;
    });

    _addSession(counter);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const ArabicText("Session Summary"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ArabicText("Total Taps: $counter"),
            const SizedBox(height: 8),
            ArabicText("Total Time: ${elapsed.inSeconds} seconds"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const ArabicText("Close"),
          ),
        ],
      ),
    );
  }

  void incrementCounter() {
    if (!timerRunning) {
      startTimer(); // Start timer on first tap
    }
    setState(() {
      counter++;
      currentSessionHistory.add({
        'count': counter,
        'time': DateTime.now().toIso8601String(),
      });
      if (currentSessionHistory.length > 20) {
        currentSessionHistory.removeAt(0);
      }
    });
  }

  void resetCounter() {
    timer?.cancel();
    setState(() {
      counter = 0;
      elapsed = Duration.zero;
      timerRunning = false;
      currentSessionHistory.clear();
    });
  }

  void saveSession() {
    if (counter > 0) {
      _addSession(counter);
      resetCounter(); // Reset after saving
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Session saved! Counter reset.")),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("No taps to save!")));
    }
  }

  void _addSession(int count) {
    final session = {
      'count': count,
      'timestamp': DateTime.now().toIso8601String(),
    };
    setState(() {
      sessions.add(session);
    });
    _saveSessions();
  }

  void clearAllSessions() async {
    bool confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: mainColor,
        title: const ArabicText("Confirm Clear"),
        content: const ArabicText(
          "Are you sure you want to clear all sessions? This cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const ArabicText("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const ArabicText("Clear"),
          ),
        ],
      ),
    );

    if (confirm) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('tasbeeh_sessions');
      setState(() {
        sessions.clear();
        counter = 0;
        elapsed = Duration.zero;
        timerRunning = false;
        currentSessionHistory.clear();
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("All sessions cleared!")));
    }
  }

  void openGraph() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ['Weekly', 'Monthly', 'Yearly'].map((period) {
                return ChoiceChip(
                  label: Text(period),
                  selected: chartPeriod == period,
                  onSelected: (_) {
                    setState(() {
                      chartPeriod = period;
                    });
                    Navigator.of(context).pop();
                    openGraph();
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            Expanded(child: _buildChart()),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _aggregateData() {
    DateTime now = DateTime.now();
    List<FlSpot> spots = [];

    if (sessions.isEmpty) return spots;

    List<Map<String, dynamic>> parsedSessions = sessions
        .map(
          (s) => {
            'count': s['count'],
            'timestamp': DateTime.parse(s['timestamp']),
          },
        )
        .toList();

    if (chartPeriod == 'Weekly') {
      for (int i = 0; i < 7; i++) {
        DateTime day = now.subtract(Duration(days: i));
        int total = parsedSessions
            .where(
              (s) =>
                  s['timestamp'].day == day.day &&
                  s['timestamp'].month == day.month &&
                  s['timestamp'].year == day.year,
            )
            .fold(0, (int sum, s) => sum + (s['count'] as num).toInt());
        spots.add(FlSpot((6 - i).toDouble(), total.toDouble()));
      }
    } else if (chartPeriod == 'Monthly') {
      int daysInMonth = DateTime(now.year, now.month + 1, 0).day;
      for (int i = 1; i <= daysInMonth; i++) {
        int total = parsedSessions
            .where(
              (s) =>
                  s['timestamp'].day == i &&
                  s['timestamp'].month == now.month &&
                  s['timestamp'].year == now.year,
            )
            .fold(0, (int sum, s) => sum + (s['count'] as num).toInt());
        spots.add(FlSpot(i.toDouble(), total.toDouble()));
      }
    } else if (chartPeriod == 'Yearly') {
      for (int m = 1; m <= 12; m++) {
        int total = parsedSessions
            .where(
              (s) =>
                  s['timestamp'].month == m && s['timestamp'].year == now.year,
            )
            .fold(0, (int sum, s) => sum + (s['count'] as num).toInt());
        spots.add(FlSpot(m.toDouble(), total.toDouble()));
      }
    }

    return spots;
  }

  Widget _buildChart() {
    final spots = _aggregateData();
    if (spots.isEmpty) return const Center(child: Text("No data available"));

    return Padding(
      padding: const EdgeInsets.all(12),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
          ),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              barWidth: 3,
              color: Colors.orange,
              dotData: FlDotData(show: true),
            ),
          ],
        ),
      ),
    );
  }

  // Mini live graph
  Widget _buildLiveGraph() {
    if (currentSessionHistory.isEmpty) {
      return const SizedBox(
        height: 80,
        child: Center(child: Text("Start tapping to see live progress")),
      );
    }

    List<FlSpot> spots = [];
    for (int i = 0; i < currentSessionHistory.length; i++) {
      spots.add(
        FlSpot(i.toDouble(), currentSessionHistory[i]['count'].toDouble()),
      );
    }

    return SizedBox(
      height: 100,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: false),
            titlesData: FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: Colors.yellowAccent,
                barWidth: 3,
                dotData: FlDotData(show: true),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(d.inMinutes)}:${twoDigits(d.inSeconds.remainder(60))}";
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final counterFontSize = screenWidth * 0.2;
    final timerFontSize = screenWidth * 0.07;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: mainColor,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryText),
        centerTitle: true,
        title: ArabicText(
          "Tasbeeh",
          style: TextStyle(color: primaryText, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/bg.png"),
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (timerRunning)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ArabicText(
                  formatDuration(elapsed),
                  style: TextStyle(
                    fontSize: timerFontSize,
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ArabicText(
              "$counter",
              style: TextStyle(
                fontSize: counterFontSize,
                color: primaryText,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: incrementCounter,
              style: _buttonStyle(screenWidth, screenHeight),
              child: const ArabicText(
                "Tap",
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            _buildLiveGraph(),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: mainColor.withOpacity(0.9),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                tooltip: 'Reset',
                onPressed: resetCounter,
              ),
              IconButton(
                icon: const Icon(Icons.play_arrow, color: Colors.white),
                tooltip: 'Start',
                onPressed: timerRunning ? null : startTimer,
              ),
              IconButton(
                icon: const Icon(Icons.save, color: Colors.white),
                tooltip: 'Save',
                onPressed: saveSession,
              ),
              IconButton(
                icon: const Icon(Icons.show_chart, color: Colors.white),
                tooltip: 'Graph',
                onPressed: openGraph,
              ),
              IconButton(
                icon: const Icon(Icons.delete_forever, color: Colors.white),
                tooltip: 'Clear All',
                onPressed: clearAllSessions,
              ),
              // NEW: Show Results button
              IconButton(
                icon: const Icon(Icons.list_alt, color: Colors.white),
                tooltip: 'Saved Sessions',
                onPressed: _showSavedSessions,
              ),
            ],
          ),
        ),
      ),
    );
  }

  ButtonStyle _buttonStyle(double width, double height) {
    return ElevatedButton.styleFrom(
      backgroundColor: mainColor,
      foregroundColor: Colors.black,
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.2,
        vertical: height * 0.02,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
    );
  }

  void _showSavedSessions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Text(
              "Saved Sessions",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Expanded(
              child: sessions.isEmpty
                  ? const Center(child: Text("No saved sessions"))
                  : ListView.builder(
                      itemCount: sessions.length,
                      itemBuilder: (context, index) {
                        final session = sessions[index];
                        DateTime ts = DateTime.parse(session['timestamp']);
                        return ListTile(
                          leading: const Icon(Icons.history),
                          title: Text("Taps: ${session['count']}"),
                          subtitle: Text(
                            "${ts.day}-${ts.month}-${ts.year} ${ts.hour}:${ts.minute.toString().padLeft(2, '0')}",
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
