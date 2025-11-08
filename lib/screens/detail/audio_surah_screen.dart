import 'package:flutter/material.dart';
import 'package:quran_al_kareem/api/api_calls.dart';
import 'package:quran_al_kareem/model/qari_model.dart';
import 'package:quran_al_kareem/model/surrah_model.dart' as surah;
import 'package:quran_al_kareem/screens/detail/audio_screen.dart';
import 'package:quran_al_kareem/screens/widget/arabic_text_widget.dart';
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
    _quranText = apiServices.getSurah();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final languageProvider = Provider.of<LanguageProvider>(context); // Access

    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          title: ArabicText(
            'Surah List',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/bg.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: FutureBuilder(
            future: apiServices.getSurah(),
            builder:
                (
                  BuildContext context,
                  AsyncSnapshot<List<surah.Surah>> snapshot,
                ) {
                  if (snapshot.hasData) {
                    var surah = snapshot.data;
                    return ListView.builder(
                      itemCount: surah!.length,
                      itemBuilder: (context, index) => AudioTile(
                        surahName: snapshot.data![index].englishName,
                        totalAya: snapshot.data![index].numberOfAyahs,
                        number: snapshot.data![index].number,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AudioScreen(
                                qari: widget.qari,
                                index: index + 1,
                                list: surah,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                  return Center(child: CircularProgressIndicator());
                },
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
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: const Color(0xFFD9D9D9).withOpacity(0.19), // 19% opacity
        ),
        child: Row(
          children: [
            Container(
              alignment: Alignment.center,
              height: 40,
              width: 60,
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: ArabicText(
                (number).toString(),
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ArabicText(
                  surahName!,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 3),
                ArabicText(
                  "Total Aya : $totalAya",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
            Spacer(),
            Icon(Icons.play_circle_fill, color: Constants.kPrimary),
          ],
        ),
      ),
    ),
  );
}
