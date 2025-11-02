import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;
import 'package:quran_al_kareem/screens/detail/surah_detail_page.dart';
import 'package:quran_al_kareem/screens/widget/my_drawer.dart';
import 'package:quran_al_kareem/utils/colors.dart';
import 'package:quran_al_kareem/utils/surah_names_utils.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  List<int> allSurah = List.generate(114, (index) => index + 1);
  List<int> filteredSurah = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredSurah = allSurah;
    _searchController.addListener(_filterSurahs);
  }

  void _filterSurahs() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        filteredSurah = allSurah;
      });
    } else {
      setState(() {
        filteredSurah = allSurah.where((surahNumber) {
          final arabic = arabicSurahNames[surahNumber - 1].toLowerCase();
          final english = quran.getSurahNameEnglish(surahNumber).toLowerCase();
          final transliteration = transliterationSurahNames[surahNumber - 1]
              .toLowerCase();

          return arabic.contains(query) ||
              english.contains(query) ||
              transliteration.contains(query);
        }).toList();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search surah...',
                prefixIcon: const Icon(Icons.search),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      drawer: DrawerWidget(),
      backgroundColor: mainColor,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset("assets/bg.png", fit: BoxFit.cover),
            ),
            Container(
              color: mainColor.withOpacity(
                0.3,
              ), // optional overlay for better contrast
            ),
            // Modern search bar
            Expanded(
              child: ListView.builder(
                itemCount: filteredSurah.length,
                itemBuilder: (context, index) {
                  final surahNumber = filteredSurah[index];
                  return buildSurahCard(context, surahNumber);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSurahCard(BuildContext context, int surahNumber) {
    return Card(
      color: Colors.white.withOpacity(0.15), // <-- semi-transparent background
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.brown,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            surahNumber.toString(),
            style: TextStyle(fontWeight: FontWeight.bold, color: mainColor),
          ),
        ),
        title: Text(
          arabicSurahNames[surahNumber - 1],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          '${quran.getVerseCount(surahNumber)} verses ',
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SurahDetailScreen(surahNumber: surahNumber),
            ),
          );
        },
      ),
    );
  }
}
