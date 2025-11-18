import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_al_kareem/provider/language_providrer.dart';
import 'package:quran_al_kareem/screens/widget/arabic_text_widget.dart';
import 'package:quran_al_kareem/service/anayltics_helper.dart';
import 'package:quran_al_kareem/utils/allah_names_utils.dart';
import 'package:quran_al_kareem/utils/colors.dart';

class AllahNames extends StatefulWidget {
  const AllahNames({super.key});

  @override
  State<AllahNames> createState() => _AllahNamesState();
}

class _AllahNamesState extends State<AllahNames>
    with SingleTickerProviderStateMixin {
  int currentIndex = 0;
  @override
  void initState() {
    super.initState();
    AnalyticsHelper.logScreenView("AllahNames");
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryText),
        centerTitle: true,
        title: ArabicText(
          lang.localizedStrings["Allah Names"] ?? "Allah Names",
          style: TextStyle(color: primaryText, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/bg.png", fit: BoxFit.cover),
          ),
          Container(
            color: mainColor.withOpacity(
              0.3,
            ), // optional overlay for better contrast
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: ArabicText(
                    'أسماء الله الحسنى',
                    style: TextStyle(
                      fontSize: 32,
                      fontFamily: 'Amiri',
                      color: primaryText,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: primaryText, blurRadius: 10)],
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
                              color: mainColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: buttonColor.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ArabicText(
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
                                  ArabicText(
                                    name['transliteration']!,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.amber[200],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  ArabicText(
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
        ],
      ),
    );
  }
}
