import 'package:flutter/material.dart';
import 'package:quran_al_kareem/api/api_calls.dart';
import 'package:quran_al_kareem/model/qari_model.dart';
import 'package:quran_al_kareem/model/surrah_model.dart' as surah;
import 'package:quran_al_kareem/screens/detail/audio_screen.dart';
import 'package:quran_al_kareem/screens/widget/arabic_text_widget.dart';
import 'package:quran_al_kareem/utils/colors.dart';
import 'package:quran_al_kareem/utils/constant.dart';

class AudioSurahScreen extends StatefulWidget {
  const AudioSurahScreen({Key? key, required this.qari}) : super(key: key);
  final Qari qari;

  @override
  _AudioSurahScreenState createState() => _AudioSurahScreenState();
}

class _AudioSurahScreenState extends State<AudioSurahScreen> {
  ApiCalls apiServices = ApiCalls();
  late Future<List<surah.Surah>> _quranText;

  @override
  void initState() {
    super.initState();
    _quranText = apiServices.getSurah();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: primaryText),
          title: ArabicText(
            'Surah List',
            style: TextStyle(
              color: primaryText,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/bg.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              // ✅ Show selected Qari info

              // 🔹 Surah list
              Expanded(
                child: FutureBuilder<List<surah.Surah>>(
                  future: _quranText,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      var surahList = snapshot.data!;
                      return ListView.builder(
                        itemCount: surahList.length,
                        itemBuilder: (context, index) => AudioTile(
                          surahName: surahList[index].englishName,
                          totalAya: surahList[index].numberOfAyahs,
                          number: surahList[index].number,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AudioScreen(
                                  qari: widget.qari,
                                  index: index + 1,
                                  list: surahList,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: ArabicText(
                          "Error loading Surah",
                          style: TextStyle(color: primaryText),
                        ),
                      );
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget AudioTile({
  required String? surahName,
  required totalAya,
  required number,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          color: const Color(0xFFD9D9D9).withOpacity(0.19),
        ),
        child: Row(
          children: [
            Container(
              alignment: Alignment.center,
              height: 40,
              width: 60,
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: ArabicText(
                number.toString(),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ArabicText(
                  surahName ?? "",
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: primaryText,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                ArabicText(
                  "Total Aya : $totalAya",
                  style: TextStyle(color: primaryText, fontSize: 16),
                ),
              ],
            ),
            const Spacer(),
            Icon(Icons.play_circle_fill, color: buttonColor),
          ],
        ),
      ),
    ),
  );
}
