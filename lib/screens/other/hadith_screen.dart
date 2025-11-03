import 'package:flutter/material.dart';
import 'package:quran_al_kareem/model/hadith_model.dart';
import 'package:quran_al_kareem/service/hadith_service.dart';
import 'package:quran_al_kareem/utils/colors.dart';

enum Language { english, urdu }

class HadithScreen extends StatefulWidget {
  const HadithScreen({super.key});

  @override
  State<HadithScreen> createState() => _HadithScreenState();
}

class _HadithScreenState extends State<HadithScreen> {
  final HadithService _service = HadithService();
  Language selectedLanguage = Language.english;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: mainColor,
        title: const Text(
          "Hadith Collection",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          PopupMenuButton<Language>(
            onSelected: (Language lang) {
              setState(() => selectedLanguage = lang);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: Language.english, child: Text("English")),
              PopupMenuItem(value: Language.urdu, child: Text("Urdu")),
            ],
            icon: const Icon(Icons.language),
          ),
        ],
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
          // Mo
          FutureBuilder<List<Hadith>>(
            future: _service.fetchHadiths(book: 'sahih-bukhari', limit: 15),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("No Hadiths found"));
              }

              final hadiths = snapshot.data!;
              return ListView.builder(
                itemCount: hadiths.length,
                itemBuilder: (context, index) {
                  final h = hadiths[index];
                  return Card(
                    color: Colors.white.withOpacity(0.95),
                    elevation: 5,
                    margin: const EdgeInsets.all(10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Arabic Text
                          Text(
                            h.arabic,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Amiri',
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Translation
                          Text(
                            selectedLanguage == Language.english
                                ? h.english
                                : h.urdu,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Reference
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              h.reference,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
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
        ],
      ),
    );
  }
}
