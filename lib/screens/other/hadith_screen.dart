import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_al_kareem/provider/language_providrer.dart';
import 'package:quran_al_kareem/screens/other/hadith_detail_screen.dart';
import 'package:quran_al_kareem/utils/colors.dart';

class HadithScreen extends StatelessWidget {
  const HadithScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    final List<Map<String, String>> hadithBooks = [
      {'name': 'Sahih al-Bukhari', 'key': 'sahih-bukhari'},
      {'name': 'Sahih Muslim', 'key': 'sahih-muslim'},
      {'name': 'Sunan Abu Dawood', 'key': 'abu-dawood'},
      {'name': 'Sunan al-Nasa\'i', 'key': 'sunan-nasai'},
      {'name': 'Jami al-Tirmidhi', 'key': 'al-tirmidhi'},
      {'name': 'Sunan Ibn Majah', 'key': 'ibn-e-majah'},
    ];

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: mainColor,
        title: Text(
          languageProvider.localizedStrings["Hadith Collection"] ??
              "Hadith Collection",
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/bg.png", fit: BoxFit.cover),
          ),
          Container(color: mainColor.withOpacity(0.3)),

          // 📘 Narrator Grid
          GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Two columns
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: hadithBooks.length,
            itemBuilder: (context, index) {
              final book = hadithBooks[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HadithListScreen(
                        bookKey: book['key']!,
                        bookName: book['name']!,
                      ),
                    ),
                  );
                },
                child: Card(
                  color: mainColor.withOpacity(0.9),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        book['name']!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
