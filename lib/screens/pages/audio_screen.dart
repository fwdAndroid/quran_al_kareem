import 'package:flutter/material.dart';
import 'package:quran_al_kareem/api/api_calls.dart';
import 'package:quran_al_kareem/model/qari_model.dart';
import 'package:quran_al_kareem/model/quran_audio_model.dart';
import 'package:quran_al_kareem/screens/detail/audio_surah_screen.dart';
import 'package:quran_al_kareem/screens/widget/qari_custom_tile_widget.dart';
import 'package:quran_al_kareem/utils/colors.dart';

class AudioQuranScreen extends StatefulWidget {
  const AudioQuranScreen({super.key});

  @override
  State<AudioQuranScreen> createState() => _AudioQuranScreenState();
}

class _AudioQuranScreenState extends State<AudioQuranScreen> {
  late Future<QuranAudio> _quranAudio;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _quranAudio = ApiCalls().getQuranAudio();
  }

  @override
  Widget build(BuildContext context) {
    ApiCalls apiServices = ApiCalls();
    return FutureBuilder(
      future: apiServices.getQariList(),
      builder: (BuildContext context, AsyncSnapshot<List<Qari>> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Qari's data not found"));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        return Stack(
          children: [
            Positioned.fill(
              child: Image.asset("assets/bg.png", fit: BoxFit.cover),
            ),
            Container(
              color: mainColor.withOpacity(
                0.3,
              ), // optional overlay for better contrast
            ),
            Container(
              margin: const EdgeInsets.only(top: 20),
              height: MediaQuery.of(context).size.height,
              child: ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      QariCustomTile(
                        index: index, // 👈 pass index here

                        qari: snapshot.data![index],
                        ontap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AudioSurahScreen(qari: snapshot.data![index]),
                            ),
                          );
                        },
                      ),
                      Divider(),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
