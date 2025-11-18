import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_al_kareem/datasource/qari_datasource.dart';
import 'package:quran_al_kareem/provider/language_providrer.dart';
import 'package:quran_al_kareem/service/anayltics_helper.dart';
import 'package:shimmer/shimmer.dart';
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
  bool _isLoading = !QariDataStore.isPreloaded;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadQaris();
    AnalyticsHelper.logScreenView("AudioQuranScreen");
  }

  Future<void> _loadQaris() async {
    if (QariDataStore.isPreloaded) {
      if (QariDataStore.qariList.isNotEmpty) {
        setState(() {
          _allQaris = QariDataStore.qariList;
          _filteredQaris = _allQaris;
          _isLoading = false;
          _error = QariDataStore.error;
        });
        return;
      } else if (QariDataStore.error != null) {
        setState(() {
          _error = QariDataStore.error;
          _isLoading = false;
        });
        return;
      }
    }

    if (!_isLoading) {
      setState(() => _isLoading = true);
    }

    try {
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
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: ArabicText(
          lang.localizedStrings["Audio Quran"] ?? "Audio Quran",
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
              // SEARCH BAR
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  onChanged: _filterQaris,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText:
                        lang.localizedStrings["Search Qari..."] ??
                        "Search Qari...",
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

              // LIST CONTENT
              Expanded(
                child: _isLoading
                    ? _buildShimmerList()
                    : _error != null
                    ? Center(
                        child: ArabicText(
                          "${lang.localizedStrings["Error loading Qaris:"] ?? "Error loading Qaris:"} $_error",
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      )
                    : _filteredQaris.isEmpty
                    ? Center(
                        child: ArabicText(
                          lang.localizedStrings["No Qari found"] ??
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
