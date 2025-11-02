import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:quran_al_kareem/utils/allah_names_utils.dart';

class AllahNames extends StatefulWidget {
  const AllahNames({super.key});

  @override
  State<AllahNames> createState() => _AllahNamesState();
}

class _AllahNamesState extends State<AllahNames>
    with SingleTickerProviderStateMixin {
  int currentIndex = 0;

  late AnimationController _controller;
  late Animation<Alignment> _alignment1;
  late Animation<Alignment> _alignment2;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);

    _alignment1 = Tween<Alignment>(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).animate(_controller);

    _alignment2 = Tween<Alignment>(
      begin: Alignment.bottomRight,
      end: Alignment.topLeft,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        title: Text("Allah Names", style: TextStyle(color: Colors.white)),
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: _alignment1.value,
                end: _alignment2.value,
                colors: [
                  const Color(0xFF001F3F),
                  const Color(0xFF003366),
                  const Color(0xFF005C97),
                  const Color(0xFF363795),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'أسماء الله الحسنى',
                      style: TextStyle(
                        fontSize: 32,
                        fontFamily: 'Amiri',
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(color: Colors.amberAccent, blurRadius: 10),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1,
                          ),
                      itemCount: names.length,
                      itemBuilder: (context, index) {
                        final name = names[index];
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1,
                                ),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.1),
                                    Colors.white.withOpacity(0.05),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      name['arabic']!,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 26,
                                        fontFamily: 'Amiri',
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                            color: Colors.amberAccent,
                                            blurRadius: 10,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      name['transliteration']!,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.amber[200],
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      name['meaning']!,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
