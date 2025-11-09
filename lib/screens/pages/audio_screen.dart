import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:quran_al_kareem/api/api_calls.dart';
import 'package:quran_al_kareem/model/qari_model.dart';
import 'package:quran_al_kareem/screens/detail/audio_surah_screen.dart';
import 'package:quran_al_kareem/screens/widget/arabic_text_widget.dart';
import 'package:quran_al_kareem/screens/widget/qari_custom_tile_widget.dart';
import 'package:quran_al_kareem/utils/colors.dart';

class AudioQuranScreen extends StatefulWidget {
  const AudioQuranScreen({super.key});

  @override
  State<AudioQuranScreen> createState() => _AudioQuranScreenState();
}

class _AudioQuranScreenState extends State<AudioQuranScreen> {
  List<Qari> _allQaris = [];
  List<Qari> _filteredQaris = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQaris();
  }

  Future<void> _loadQaris() async {
    try {
      final api = ApiCalls();
      final qariList = await api.getQariList();

      final excludedQaris = [
        "Al-Hussayni Al-'Azazy (with Children)",
        "Hatem Farid - Taraweeh 1431",
        "Madinah Taraweeh 1435",
        "Mahmoud Khaleel",
        "Mostafa Ismaeel",
        "Mahmoud Khaleel Al-Husary",
        "Sudais and Shuraym",
      ];

      final filteredList = qariList
          .where((q) => !excludedQaris.contains(q.name?.trim()))
          .toList();

      setState(() {
        _allQaris = filteredList;
        _filteredQaris = filteredList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Error loading Qaris: $e");
    }
  }

  void _filterQaris(String query) {
    setState(() {
      _filteredQaris = _allQaris
          .where(
            (q) => q.name!.toLowerCase().contains(query.toLowerCase().trim()),
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const ArabicText(
          "Audio Quran",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: mainColor,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/bg.png", fit: BoxFit.cover),
          ),
          Container(color: mainColor.withOpacity(0.3)),
          Column(
            children: [
              // 🔍 Search bar
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  onChanged: _filterQaris,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Search Qari...",
                    hintStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.search, color: Colors.white70),
                    filled: true,
                    fillColor: Colors.black26,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // 📜 Qari List or Shimmer
              Expanded(
                child: _isLoading
                    ? _buildShimmerList()
                    : _filteredQaris.isEmpty
                    ? const Center(
                        child: ArabicText(
                          "No Qari found",
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredQaris.length,
                        itemBuilder: (context, index) {
                          final qari = _filteredQaris[index];
                          return Column(
                            children: [
                              QariCustomTile(
                                index: index,
                                qari: qari,
                                ontap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          AudioSurahScreen(qari: qari),
                                    ),
                                  );
                                },
                              ),
                              const Divider(color: Colors.white30),
                            ],
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

  // 🔄 Shimmer Placeholder while loading
  Widget _buildShimmerList() {
    return ListView.builder(
      itemCount: 8,
      padding: const EdgeInsets.all(8),
      itemBuilder: (_, __) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade800,
          highlightColor: Colors.grey.shade500,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        );
      },
    );
  }
}
