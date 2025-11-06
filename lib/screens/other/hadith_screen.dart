import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_al_kareem/model/hadith_model.dart';
import 'package:quran_al_kareem/provider/language_providrer.dart';
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
  String selectedBook = 'sahih-bukhari';

  final List<Map<String, String>> hadithBooks = [
    {'name': 'Sahih al-Bukhari', 'key': 'sahih-bukhari'},
    {'name': 'Sahih Muslim', 'key': 'sahih-muslim'},
    {'name': 'Sunan Abu Dawood', 'key': 'abu-dawood'},
    {'name': 'Sunan al-Nasa\'i', 'key': 'sunan-nasai'},
    {'name': 'Jami al-Tirmidhi', 'key': 'al-tirmidhi'},
    {'name': 'Sunan Ibn Majah', 'key': 'ibn-e-majah'},
  ];

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: mainColor,
        title: Text(
          languageProvider.localizedStrings["Hadith Collection"] ??
              "Hadith Collection",
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          PopupMenuButton<Language>(
            onSelected: (Language lang) {
              setState(() => selectedLanguage = lang);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: Language.english,
                child: Text(
                  languageProvider.localizedStrings["English"] ?? "English",
                ),
              ),
              PopupMenuItem(
                value: Language.urdu,
                child: Text(
                  languageProvider.localizedStrings["Urdu"] ?? "Urdu",
                ),
              ),
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
          Container(color: mainColor.withOpacity(0.3)),

          // Body
          Column(
            children: [
              // 📚 Hadith Book Selector
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 10,
                  ),
                  itemCount: hadithBooks.length,
                  itemBuilder: (context, index) {
                    final book = hadithBooks[index];
                    final isSelected = selectedBook == book['key'];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: ChoiceChip(
                        label: Text(
                          book['name']!,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: mainColor,
                        backgroundColor: Colors.white,
                        onSelected: (_) {
                          setState(() {
                            selectedBook = book['key']!;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),

              // 🕌 Hadith List
              Expanded(
                child: FutureBuilder<List<Hadith>>(
                  future: _service.fetchAllHadiths(book: selectedBook),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          "Error: ${snapshot.error}",
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
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
              ),
            ],
          ),
        ],
      ),
    );
  }
}
