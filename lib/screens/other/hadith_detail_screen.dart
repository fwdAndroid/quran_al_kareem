import 'package:flutter/material.dart';
import 'package:quran_al_kareem/screens/widget/arabic_text_widget.dart';
import 'package:quran_al_kareem/service/hadith_service.dart';
import 'package:quran_al_kareem/model/hadith_model.dart';
import 'package:quran_al_kareem/utils/colors.dart';
import 'package:shimmer/shimmer.dart';

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
        iconTheme: IconThemeData(color: primaryText),
        title: ArabicText(
          widget.bookName,
          style: TextStyle(color: primaryText, fontWeight: FontWeight.bold),
        ),
        backgroundColor: mainColor,
        // actions: [
        //   PopupMenuButton<Language>(
        //     onSelected: (Language lang) {
        //       setState(() => selectedLanguage = lang);
        //     },
        //     itemBuilder: (context) => [
        //       PopupMenuItem(
        //         value: Language.urdu,
        //         child: ArabicText("Urdu", style: TextStyle(color: primaryText)),
        //       ),
        //     ],
        //     icon: Icon(Icons.language, color: iconColor),
        //   ),
        // ],
      ),
      body: FutureBuilder<List<Hadith>>(
        future: _service.fetchAllHadiths(book: widget.bookKey),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Shimmer loader for multiple cards
            return ListView.builder(
              itemCount: 5, // Number of shimmer cards to display
              itemBuilder: (context, index) => Card(
                color: mainColor.withOpacity(0.95),
                elevation: 4,
                margin: const EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[700]!,
                  highlightColor: Colors.grey[500]!,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 20,
                          width: double.infinity,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 16,
                          width: double.infinity,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Container(
                            height: 12,
                            width: 80,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: ArabicText("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: ArabicText("No Hadiths found"));
          }

          // Actual data loaded
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
                      ArabicText(
                        h.arabic,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Amiri',
                          color: primaryText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ArabicText(
                        selectedLanguage == Language.urdu ? h.urdu : h.urdu,
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
