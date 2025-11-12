import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;
import 'package:quran_al_kareem/screens/widget/arabic_text_widget.dart';
import 'package:quran_al_kareem/utils/colors.dart';

class SurahDetailScreen extends StatefulWidget {
  final int surahNumber;

  const SurahDetailScreen({super.key, required this.surahNumber});

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  int fontSize = 18;
  bool showTranslation = true;

  @override
  Widget build(BuildContext context) {
    final surahName = quran.getSurahName(widget.surahNumber);
    final versesCount = quran.getVerseCount(widget.surahNumber);

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: mainColor,
        title: ArabicText(
          surahName,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          // 🌙 Background image
          Positioned.fill(
            child: Image.asset(
              'assets/bg.png', // ✅ Replace with your actual image path
              fit: BoxFit.cover,
            ),
          ),

          // Optional dark overlay for readability
          Container(color: mainColor.withOpacity(0.3)),

          // Main content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: versesCount,
              itemBuilder: (context, index) {
                final verseNumber = index + 1;
                return Card(
                  color: Colors.white.withOpacity(
                    0.1,
                  ), // <-- semi-transparent background
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Arabic verse
                        ArabicText(
                          quran.getVerse(
                            widget.surahNumber,
                            verseNumber,
                            verseEndSymbol: true,
                          ),
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: fontSize.toDouble() + 4,
                            fontFamily: 'Uthmanic',
                            color: primaryText,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Verse number
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: ArabicText(
                              verseNumber.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: mainColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
