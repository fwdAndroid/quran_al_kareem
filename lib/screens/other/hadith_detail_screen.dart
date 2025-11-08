import 'package:flutter/material.dart';
import 'package:quran_al_kareem/screens/widget/arabic_text_widget.dart';
import 'package:quran_al_kareem/service/hadith_service.dart';
import 'package:quran_al_kareem/model/hadith_model.dart';
import 'package:quran_al_kareem/utils/colors.dart';

enum Language { english, urdu }

class HadithListScreen extends StatefulWidget {
  final String bookKey;
  final String bookName;

  const HadithListScreen({
    super.key,
    required this.bookKey,
    required this.bookName,
  });

  @override
  State<HadithListScreen> createState() => _HadithListScreenState();
}

class _HadithListScreenState extends State<HadithListScreen> {
  final HadithService _service = HadithService();
  Language selectedLanguage = Language.english;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: ArabicText(
          widget.bookName,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: mainColor,
        actions: [
          PopupMenuButton<Language>(
            onSelected: (Language lang) {
              setState(() => selectedLanguage = lang);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: Language.english,
                child: ArabicText(
                  "English",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const PopupMenuItem(
                value: Language.urdu,
                child: ArabicText(
                  "Urdu",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
            icon: const Icon(Icons.language, color: Colors.white),
          ),
        ],
      ),
      body: FutureBuilder<List<Hadith>>(
        future: _service.fetchAllHadiths(book: widget.bookKey),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: ArabicText("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: ArabicText("No Hadiths found"));
          }

          final hadiths = snapshot.data!;
          return ListView.builder(
            itemCount: hadiths.length,
            itemBuilder: (context, index) {
              final h = hadiths[index];
              return Card(
                color: mainColor.withOpacity(0.95),
                elevation: 4,
                margin: const EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Arabic Text
                      ArabicText(
                        h.arabic,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Amiri',
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Translation
                      ArabicText(
                        selectedLanguage == Language.english
                            ? h.english
                            : h.urdu,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),

                      Align(
                        alignment: Alignment.bottomRight,
                        child: ArabicText(
                          h.reference,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
