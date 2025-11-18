// tasbeeh_screen.dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_al_kareem/provider/language_providrer.dart';
import 'package:quran_al_kareem/screens/drawer_pages/tashbeeh_summary_screen.dart';
import 'package:quran_al_kareem/utils/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TasbeehScreen extends StatefulWidget {
  const TasbeehScreen({Key? key}) : super(key: key);

  @override
  State<TasbeehScreen> createState() => _TasbeehScreenState();
}

class _TasbeehScreenState extends State<TasbeehScreen> {
  final TextEditingController _textController = TextEditingController();
  int _counter = 0;
  bool _isCounting = false;

  // TIMER
  Timer? _timer;
  int _seconds = 0;

  // FORMATTED TIME
  String get formattedTime {
    final min = (_seconds ~/ 60).toString().padLeft(2, '0');
    final sec = (_seconds % 60).toString().padLeft(2, '0');
    return "$min:$sec";
  }

  // START TIMER
  void _startTimer() {
    _timer?.cancel();
    _seconds = 0;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isCounting) {
        timer.cancel();
        return;
      }
      setState(() => _seconds++);
    });
  }

  // STOP TIMER
  void _stopTimer() {
    _timer?.cancel();
  }

  // START COUNTING
  void _startCounting() {
    if (_textController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a tasbeeh word first")),
      );
      return;
    }

    setState(() => _isCounting = true);
    _startTimer();
  }

  // RESET
  void _resetCounter() {
    setState(() {
      _counter = 0;
      _isCounting = false;
      _seconds = 0;
    });
    _stopTimer();
  }

  // SAVE
  Future<void> _saveResult() async {
    final prefs = await SharedPreferences.getInstance();

    // Read existing list of saved tasbeehs
    final List<String> list = prefs.getStringList('tasbeeh_history') ?? [];

    // Create new entry
    final Map<String, dynamic> newEntry = {
      "tasbeeh": _textController.text.trim(),
      "count": _counter,
      "time": formattedTime,
      "timestamp": DateTime.now().toIso8601String(),
    };

    // Append new entry
    list.add(jsonEncode(newEntry));

    // Save back to SharedPreferences
    await prefs.setStringList('tasbeeh_history', list);

    // Show confirmation
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Saved successfully!")));

    // Reset counter for new tasbeeh
    _resetCounter();
  }

  // GRAPH SCREEN NAVIGATION (placeholder)
  void _openGraph() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TasbeehGraphScreen()),
    );
  }

  // MAIN UI
  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          lang.localizedStrings["Tasbeeh Counter"] ?? "Tasbeeh Counter",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/bg.png", fit: BoxFit.cover),
          ),
          Container(color: mainColor.withOpacity(0.3)),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Text field
                  TextField(
                    controller: _textController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText:
                          lang.localizedStrings["Tasbeeh Word"] ??
                          "Tasbeeh Word",
                      labelStyle: const TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.white70,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                  Spacer(flex: 1),
                  // COUNTER CIRCLE
                  GestureDetector(
                    onTap: () {
                      if (_isCounting) {
                        setState(() => _counter++);
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 180,
                      width: 180,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.9),
                          width: 3,
                        ),
                      ),
                      child: Text(
                        lang.localizedStrings["Tap to Count"] ?? "Tap to Count",
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  // SwitchTile
                  const SizedBox(height: 20),
                  // TIMER
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                    decoration: BoxDecoration(
                      color: Color(0xff284142),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Color(0xff284142).withOpacity(0.9),
                      ),
                    ),
                    child: Text(
                      "$formattedTime",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    lang.localizedStrings["Tasbeeh Counter"] ??
                        "Tasbeeh Counter",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  Text(
                    "$_counter",
                    style: const TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: Color(0xffF9AE4C),
                    ),
                  ),
                  Spacer(flex: 3),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Transform.scale(
                      scale: 2, // Increase size (1.0 = default)
                      child: Switch(
                        value: _isCounting,
                        activeColor: Color(0xffFDC269),

                        onChanged: (value) {
                          if (!_isCounting) {
                            _startCounting();
                          } else {
                            _stopTimer();
                            setState(() => _isCounting = false);
                          }
                        },
                      ),
                    ),
                  ),

                  Spacer(),
                  // BUTTONS ROW
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: mainColor.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.bottomCenter,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // SAVE
                          IconButton(
                            icon: const Icon(
                              Icons.save,
                              color: Colors.white,
                              size: 34,
                            ),
                            onPressed: _saveResult,
                          ),

                          // GRAPH
                          IconButton(
                            icon: const Icon(
                              Icons.bar_chart,
                              color: Colors.white,
                              size: 34,
                            ),
                            onPressed: _openGraph,
                          ),

                          // RESET
                          IconButton(
                            icon: const Icon(
                              Icons.refresh,
                              color: Colors.white,
                              size: 34,
                            ),
                            onPressed: _resetCounter,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
