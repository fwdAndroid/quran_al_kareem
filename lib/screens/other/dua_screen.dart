import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:quran_al_kareem/model/dua_model.dart';
import 'package:quran_al_kareem/provider/language_providrer.dart';
import 'package:quran_al_kareem/screens/widget/arabic_text_widget.dart';
import 'package:quran_al_kareem/service/read_json.dart';
import 'package:quran_al_kareem/utils/colors.dart';
import 'package:rxdart/rxdart.dart';

class DuaScreen extends StatefulWidget {
  const DuaScreen({Key? key}) : super(key: key);

  @override
  State<DuaScreen> createState() => _DuaScreenState();
}

class _DuaScreenState extends State<DuaScreen> {
  final AudioPlayer _player = AudioPlayer();
  int? _currentIndex;
  DuaModel? currentDua;

  @override
  void initState() {
    super.initState();

    // Listen to audio state changes (playing, paused, completed)
    _player.playerStateStream.listen((state) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest2<Duration, Duration?, PositionData>(
        _player.positionStream,
        _player.durationStream,
        (position, duration) =>
            PositionData(position, duration ?? Duration(seconds: 1)),
      );

  Future<void> _playAudio(List<String> audios, DuaModel dua, int index) async {
    try {
      if (_currentIndex == index) {
        if (_player.playing) {
          await _player.pause();
        } else {
          await _player.play();
        }
      } else {
        _currentIndex = index;
        currentDua = dua;

        await _player.stop();
        await _player.setUrl(audios.first);
        await _player.play();
      }

      setState(() {});
    } catch (e) {
      debugPrint("Audio Error: $e");
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: ArabicText(
          languageProvider.localizedStrings["Dua's"] ?? "Dua's",
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: mainColor,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/bg.png", fit: BoxFit.cover),
          ),
          Container(color: mainColor.withOpacity(0.25)),

          FutureBuilder<List<DuaModel>>(
            future: ReadJSON().ReadJsonDua(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: ArabicText("Error: ${snapshot.error}"));
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final duas = snapshot.data!;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: duas.length,
                  itemBuilder: (context, index) {
                    final dua = duas[index];
                    final isCurrent = _currentIndex == index;
                    final isPlaying = isCurrent && _player.playing;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: mainColor.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        children: [
                          const ArabicText(
                            '﷽',
                            style: TextStyle(fontSize: 36, color: Colors.white),
                          ),
                          const SizedBox(height: 8),

                          ArabicText(
                            dua.dua ?? "",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'ScheherazadeNew',
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.amberAccent,
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          ArabicText(
                            dua.translation ?? "",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white.withOpacity(0.8),
                              fontStyle: FontStyle.italic,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Play / Pause Button
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: () =>
                                _playAudio(dua.audios!, dua, index),
                            icon: Icon(
                              isPlaying
                                  ? Icons.pause_circle
                                  : Icons.play_circle,
                              size: 26,
                              color: Colors.black,
                            ),
                            label: ArabicText(
                              isPlaying
                                  ? languageProvider.localizedStrings["Pause"]
                                  : languageProvider
                                        .localizedStrings["Play Audio"],
                              style: const TextStyle(color: Colors.black),
                            ),
                          ),

                          const SizedBox(height: 8),

                          StreamBuilder<PositionData>(
                            stream: _positionDataStream,
                            builder: (context, snap) {
                              final data = snap.data;
                              final position = isCurrent
                                  ? data?.position ?? Duration.zero
                                  : Duration.zero;
                              final duration =
                                  data?.duration ?? Duration(seconds: 1);

                              final value = isCurrent
                                  ? position.inMilliseconds
                                        .clamp(0, duration.inMilliseconds)
                                        .toDouble()
                                  : 0.0;

                              return Column(
                                children: [
                                  Slider(
                                    min: 0,
                                    max: duration.inMilliseconds.toDouble(),
                                    value: value,
                                    onChanged: isCurrent
                                        ? (newValue) {
                                            _player.seek(
                                              Duration(
                                                milliseconds: newValue.toInt(),
                                              ),
                                            );
                                          }
                                        : null,
                                    activeColor: isCurrent
                                        ? Colors.black
                                        : Colors.grey,
                                    inactiveColor: Colors.grey[300],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      ArabicText(
                                        _formatDuration(position),
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      ArabicText(
                                        _formatDuration(duration),
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class PositionData {
  final Duration position;
  final Duration duration;

  PositionData(this.position, this.duration);
}
