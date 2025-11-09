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
  DuaModel? _currentDua;

  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest2<Duration, Duration?, PositionData>(
        _player.positionStream,
        _player.durationStream,
        (position, duration) =>
            PositionData(position, duration ?? Duration(seconds: 1)),
      );

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _playAudio(List<String> audios, DuaModel dua, int index) async {
    try {
      // If same dua pressed again — toggle play/pause
      if (_currentIndex == index) {
        if (_player.playing) {
          await _player.pause();
        } else {
          await _player.play();
        }
      } else {
        // New dua selected
        setState(() {
          _currentIndex = index;
          _currentDua = dua;
        });

        await _player.stop();
        await _player.setUrl(audios.first);
        await _player.play(); // ✅ Play immediately after setting URL
      }

      setState(() {}); // Refresh UI immediately
    } catch (e) {
      debugPrint("Error playing audio: $e");
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: ArabicText("Error playing audio")),
      // );
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
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
              } else if (!snapshot.hasData) {
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
                    final isCurrentDua = _currentIndex == index;
                    final isPlaying = isCurrentDua && _player.playing;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: mainColor.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Column(
                          children: [
                            const ArabicText(
                              '﷽',
                              style: TextStyle(
                                fontSize: 36,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ArabicText(
                              dua.dua ?? "",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'ScheherazadeNew',
                                color: Colors.black,
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
                                color: Colors.black.withOpacity(0.8),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 6),
                            ArabicText(
                              dua.reference ?? "",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 10),

                            // 🎵 Play/Pause Button
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: buttonColor,
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
                                size: 24,
                              ),
                              label: ArabicText(
                                isPlaying ? "Pause" : "Play Audio",
                              ),
                            ),

                            const SizedBox(height: 8),

                            // 🎚 Always visible Seekbar
                            StreamBuilder<PositionData>(
                              stream: _positionDataStream,
                              builder: (context, snapshot) {
                                final positionData = snapshot.data;
                                final position =
                                    positionData?.position ?? Duration.zero;
                                final duration =
                                    positionData?.duration ??
                                    Duration(seconds: 1);

                                final value = isCurrentDua
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
                                      onChanged: isCurrentDua
                                          ? (newValue) {
                                              _player.seek(
                                                Duration(
                                                  milliseconds: newValue
                                                      .toInt(),
                                                ),
                                              );
                                            }
                                          : null,
                                      activeColor: isCurrentDua
                                          ? mainColor
                                          : Colors.grey[400],
                                      inactiveColor: Colors.grey[300],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        ArabicText(
                                          _formatDuration(
                                            isCurrentDua
                                                ? position
                                                : Duration.zero,
                                          ),
                                          style: const TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                        ArabicText(
                                          _formatDuration(duration),
                                          style: const TextStyle(
                                            color: Colors.black,
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
