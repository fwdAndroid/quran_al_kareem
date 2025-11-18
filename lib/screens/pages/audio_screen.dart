import 'package:flutter/material.dart';
import 'package:quran_al_kareem/datasource/qari_datasource.dart';
import 'package:quran_al_kareem/service/anayltics_helper.dart';
import 'package:shimmer/shimmer.dart';
import 'package:quran_al_kareem/model/qari_model.dart';
import 'package:quran_al_kareem/screens/detail/audio_surah_screen.dart';
import 'package:quran_al_kareem/screens/widget/arabic_text_widget.dart';
import 'package:quran_al_kareem/screens/widget/qari_custom_tile_widget.dart';
import 'package:quran_al_kareem/utils/colors.dart';
// 🆕 Import the new Qari Data Store

class AudioQuranScreen extends StatefulWidget {
  const AudioQuranScreen({super.key});

  @override
  State<AudioQuranScreen> createState() => _AudioQuranScreenState();
}

class _AudioQuranScreenState extends State<AudioQuranScreen> {
  List<Qari> _allQaris = [];
  List<Qari> _filteredQaris = [];
  // 🆕 Initial loading state is set based on preloaded status
  bool _isLoading = !QariDataStore.isPreloaded;
  String? _error; // To display error if preloading failed

  @override
  void initState() {
    super.initState();
    // 🆕 Use the preloaded data if available, otherwise fetch
    _loadQaris();
    AnalyticsHelper.logScreenView("AudioQuranScreen");
  }

  Future<void> _loadQaris() async {
    // 1. Check Static Store first
    if (QariDataStore.isPreloaded) {
      if (QariDataStore.qariList.isNotEmpty) {
        // Data is ready and available
        setState(() {
          _allQaris = QariDataStore.qariList;
          _filteredQaris = _allQaris;
          _isLoading = false;
          _error = QariDataStore.error; // Should be null if list is not empty
        });
        return;
      } else if (QariDataStore.error != null) {
        // Preload failed, display the error
        setState(() {
          _error = QariDataStore.error;
          _isLoading = false;
        });
        return;
      }
    }

    // 2. Fallback: If not preloaded or list is empty/failed, fetch directly
    if (!_isLoading) {
      setState(() => _isLoading = true);
    }

    try {
      // Re-run the global preload logic (it handles the API call and filtering)
      await QariDataStore.preloadData();

      setState(() {
        _allQaris = QariDataStore.qariList;
        _filteredQaris = _allQaris;
        _isLoading = false;
        _error = QariDataStore.error;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = "Failed to load Qaris: ${e.toString()}";
      });
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
        automaticallyImplyLeading: false,
        title: ArabicText(
          "Audio Quran",
          style: TextStyle(color: primaryText, fontWeight: FontWeight.bold),
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
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Search Qari...",
                    hintStyle: TextStyle(color: Colors.white),
                    prefixIcon: Icon(Icons.search, color: Colors.white),
                    filled: true,
                    fillColor: Colors.black26,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // 📜 Qari List or Shimmer or Error
              Expanded(
                child: _isLoading
                    ? _buildShimmerList()
                    : _error != null
                    ? Center(
                        child: ArabicText(
                          "Error loading Qaris: $_error",
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      )
                    : _filteredQaris.isEmpty
                    ? Center(
                        child: ArabicText(
                          "No Qari found",
                          style: TextStyle(color: primaryText),
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
                              Divider(color: Colors.white30.withOpacity(.2)),
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
