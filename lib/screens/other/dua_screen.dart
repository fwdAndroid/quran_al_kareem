import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:quran_al_kareem/model/dua_model.dart';
import 'package:quran_al_kareem/provider/language_providrer.dart';
import 'package:quran_al_kareem/service/read_json.dart';
import 'package:quran_al_kareem/utils/colors.dart';
import 'package:rxdart/rxdart.dart'; // for combining position streams

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
            PositionData(position, duration ?? Duration.zero),
      );

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _playAudio(List<String> audios, DuaModel dua, int index) async {
    try {
      if (_currentIndex == index) {
        // If same dua clicked again
        if (_player.playing) {
          await _player.pause();
        } else {
          await _player.play(); // resume from last position
        }
      } else {
        // New dua selected
        await _player.stop();
        await _player.setUrl(audios.first);
        await _player.play();
        setState(() {
          _currentIndex = index;
          _currentDua = dua;
        });
      }
      setState(() {});
    } catch (e) {
      debugPrint("Error playing audio: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Error playing audio")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context); // Access

    return Scaffold(
      appBar: AppBar(
        title: Text(
          languageProvider.localizedStrings["Dua's"] ?? "Dua's",
          style: TextStyle(color: Colors.white),
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
                return Center(child: Text("Error: ${snapshot.error}"));
              } else if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final duas = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.only(bottom: 90),
                child: ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: duas.length,
                  itemBuilder: (context, index) {
                    final dua = duas[index];
                    final isPlaying = _currentIndex == index && _player.playing;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: mainColor.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Column(
                          children: [
                            const Text(
                              '﷽',
                              style: TextStyle(
                                fontSize: 36,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
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
                            Text(
                              dua.translation ?? "",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black.withOpacity(0.8),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              dua.reference ?? "",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: mainColor,
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
                              label: Text(isPlaying ? "Pause" : "Play Audio"),
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

          // 🌙 Mini Player
          if (_currentDua != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: StreamBuilder<PositionData>(
                stream: _positionDataStream,
                builder: (context, snapshot) {
                  final positionData = snapshot.data;
                  final position = positionData?.position ?? Duration.zero;
                  final duration = positionData?.duration ?? Duration.zero;
                  final isPlaying = _player.playing;

                  return Container(
                    height: 80,
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ListTile(
                          leading: IconButton(
                            icon: Icon(
                              isPlaying
                                  ? Icons.pause_circle_filled
                                  : Icons.play_circle_fill,
                              size: 36,
                              color: mainColor,
                            ),
                            onPressed: () async {
                              if (isPlaying) {
                                await _player.pause();
                              } else {
                                await _player
                                    .play(); // resume from last paused point
                              }
                              setState(() {});
                            },
                          ),
                          title: Text(
                            _currentDua?.dua?.substring(
                                  0,
                                  (_currentDua!.dua!.length > 20
                                      ? 20
                                      : _currentDua!.dua!.length),
                                ) ??
                                '',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Slider(
                            min: 0,
                            max: duration.inMilliseconds.toDouble(),
                            value: position.inMilliseconds
                                .clamp(0, duration.inMilliseconds)
                                .toDouble(),
                            onChanged: (value) {
                              _player.seek(
                                Duration(milliseconds: value.toInt()),
                              );
                            },
                            activeColor: mainColor,
                            inactiveColor: Colors.grey[300],
                          ),
                          trailing: Text(
                            _formatDuration(position),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: Text(
                            "Total: ${_formatDuration(duration)}",
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}

class PositionData {
  final Duration position;
  final Duration duration;

  PositionData(this.position, this.duration);
}
