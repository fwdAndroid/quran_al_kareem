import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quran_al_kareem/provider/language_providrer.dart';
import 'package:quran_al_kareem/utils/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TasbeehGraphScreen extends StatefulWidget {
  const TasbeehGraphScreen({super.key});

  @override
  State<TasbeehGraphScreen> createState() => _TasbeehGraphScreenState();
}

class _TasbeehGraphScreenState extends State<TasbeehGraphScreen> {
  List<Map<String, dynamic>> history = [];
  String selectedView = "monthly"; // default view

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('tasbeeh_history') ?? [];

    setState(() {
      history = list
          .map((e) {
            try {
              return Map<String, dynamic>.from(jsonDecode(e));
            } catch (_) {
              return <String, dynamic>{};
            }
          })
          .where((m) => m.isNotEmpty)
          .toList();
    });
  }

  // -------------------- GROUPING FUNCTIONS --------------------
  Map<String, int> groupWeekly() {
    final Map<String, int> weekly = {};
    for (var item in history) {
      final date = DateTime.parse(item['timestamp']);
      final key = "${date.year}-W${DateFormat('w').format(date)}";
      weekly[key] = (weekly[key] ?? 0) + (item['count'] as int);
    }
    return weekly;
  }

  Map<String, int> groupMonthly() {
    final Map<String, int> monthly = {};
    for (var item in history) {
      final date = DateTime.parse(item['timestamp']);
      final key = "${date.year}-${date.month.toString().padLeft(2, '0')}";
      monthly[key] = (monthly[key] ?? 0) + (item['count'] as int);
    }
    return monthly;
  }

  Map<String, int> groupYearly() {
    final Map<String, int> yearly = {};
    for (var item in history) {
      final date = DateTime.parse(item['timestamp']);
      final key = "${date.year}";
      yearly[key] = (yearly[key] ?? 0) + (item['count'] as int);
    }
    return yearly;
  }

  Map<String, int> groupDaily() {
    final Map<String, int> daily = {};
    for (var item in history) {
      final date = DateTime.parse(item['timestamp']);
      final key = DateFormat('yyyy-MM-dd').format(date); // day key
      daily[key] = (daily[key] ?? 0) + (item['count'] as int);
    }
    return daily;
  }

  // -------------------- BAR BUILD --------------------
  List<BarChartGroupData> buildBars(Map<String, int> data) {
    final keys = data.keys.toList();
    return List.generate(keys.length, (i) {
      final y = data[keys[i]]!.toDouble();
      return BarChartGroupData(
        x: i,
        barsSpace: 6,
        barRods: [
          BarChartRodData(
            toY: y,
            width: 20,
            borderRadius: BorderRadius.circular(8),
            color: Colors.greenAccent,
          ),
        ],
      );
    });
  }

  double getMaxY(Map<String, int> data) {
    if (data.isEmpty) return 10;
    final maxVal = data.values.reduce((a, b) => a > b ? a : b).toDouble();
    return maxVal * 1.2;
  }

  // -------------------- CHART WIDGET --------------------
  Widget buildChart(Map<String, int> grouped) {
    if (grouped.isEmpty) {
      return const Center(
        child: Text(
          "No data to display",
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    final keys = grouped.keys.toList();
    final bars = buildBars(grouped);
    final maxY = getMaxY(grouped);

    return BarChart(
      BarChartData(
        maxY: maxY,
        barGroups: bars,
        alignment: BarChartAlignment.spaceAround,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index < 0 || index >= keys.length) return const SizedBox();

                String label = keys[index];

                if (RegExp(r'^\d{4}-\d{2}$').hasMatch(label)) {
                  final year = int.parse(label.split('-')[0]);
                  final month = int.parse(label.split('-')[1]);
                  label = DateFormat.MMM().format(DateTime(year, month));
                } else if (RegExp(r'^\d{4}-W\d+$').hasMatch(label)) {
                  label = "W${label.split('W').last}";
                }

                return Transform.rotate(
                  angle: -0.5,
                  child: Text(
                    label,
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                );
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final label = keys[group.x.toInt()];
              return BarTooltipItem(
                "$label\n${rod.toY.toInt()}",
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
      ),
      swapAnimationDuration: const Duration(milliseconds: 700),
      swapAnimationCurve: Curves.easeOutBack,
    );
  }

  // -------------------- FILTER BUTTON --------------------
  Widget buildFilterButton(String text, String value) {
    final bool active = selectedView == value;
    return ElevatedButton(
      onPressed: () {
        setState(() => selectedView = value);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: active ? Color(0xffF7C96C) : Colors.white,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(29)),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  // -------------------- ENTRY LIST WIDGET --------------------
  Widget buildEntryList() {
    if (history.isEmpty) {
      return const Center(
        child: Text(
          "No tasbeeh entries yet",
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return ListView.separated(
      itemCount: history.length,
      separatorBuilder: (_, __) => const Divider(color: Colors.transparent),
      itemBuilder: (context, index) {
        final item = history[index];
        return Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8),
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xff336C6D),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              leading: Image.asset(
                "assets/vecteezy_prayer-bead-perfect-for-muslim-islam-religious_-removebg-preview.png",
                height: 40,
              ),
              title: Text(
                item['tasbeeh'] ?? '—',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              trailing: Text(
                item['count'].toString() + " Count",
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    final weekly = groupWeekly();
    final monthly = groupMonthly();
    final yearly = groupYearly();

    Map<String, int> selectedData = selectedView == "weekly"
        ? weekly
        : selectedView == "monthly"
        ? monthly
        : yearly;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          lang.localizedStrings["Counter Summary"] ?? "Counter Summary",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/bg.png", fit: BoxFit.cover),
          ),
          Container(color: mainColor.withOpacity(0.3)),
          SafeArea(
            child: Column(
              children: [
                // Filter buttons
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      buildFilterButton(
                        lang.localizedStrings["Day"] ??
                            lang.localizedStrings["Day"],
                        "daily",
                      ),
                      buildFilterButton(
                        lang.localizedStrings["Weekly"] ??
                            lang.localizedStrings["Weekly"],
                        "weekly",
                      ),
                      buildFilterButton(
                        lang.localizedStrings["Monthly"] ??
                            lang.localizedStrings["Monthly"],
                        "monthly",
                      ),
                      buildFilterButton(
                        lang.localizedStrings["Yearly"] ??
                            lang.localizedStrings["Yearly"],
                        "yearly",
                      ),
                    ],
                  ),
                ),

                // Chart
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xff275658),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: buildChart(selectedData),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xff275658),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: buildSummary(),
                  ),
                ),

                const SizedBox(height: 20),
                // Entry list
                Expanded(
                  flex: 2,
                  child: Container(
                    width: double.infinity,

                    child: buildEntryList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------- SUMMARY WIDGET --------------------
  Widget buildSummary() {
    int totalCount = history.fold<int>(
      0,
      (sum, item) => sum + (item['count'] as int),
    );

    final today = DateTime.now();
    int dailyCount = history.fold<int>(0, (sum, item) {
      final date = DateTime.parse(item['timestamp']);
      return (date.year == today.year &&
              date.month == today.month &&
              date.day == today.day)
          ? sum + (item['count'] as int)
          : sum;
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              const Text(
                "Total Count",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 4),
              Text(
                "$totalCount",
                style: const TextStyle(
                  color: Color(0xffF9AE4C),
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Column(
            children: [
              const Text(
                "Today's Count",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 4),
              Text(
                "$dailyCount",
                style: const TextStyle(
                  color: Color(0xffF9AE4C),
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
