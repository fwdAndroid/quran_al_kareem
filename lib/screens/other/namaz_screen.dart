import 'package:flutter/material.dart';
import 'package:quran_al_kareem/utils/colors.dart';

class NamazGuideScreen extends StatelessWidget {
  const NamazGuideScreen({super.key});

  final List<String> namazImages = const [
    "assets/namaz/namaz1.png",
    "assets/namaz/namaz2.png",
    "assets/namaz/namaz3.png",
    "assets/namaz/namaz4.png",
    "assets/namaz/namaz5.png",
    "assets/namaz/namaz6.png",
    "assets/namaz/namaz7.png",
    "assets/namaz/namaz8.png",
    "assets/namaz/namaz9.png",
    "assets/namaz/namaz10.png",
    "assets/namaz/namaz11.png",
    "assets/namaz/namaz12.png",
    "assets/namaz/namaz13.png",
    "assets/namaz/namaz14.png",
    "assets/namaz/namaz15.png",
    "assets/namaz/namaz16.png",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black.withOpacity(0.2),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Namaz Guide",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: ListView.builder(
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 30,
        ),
        itemCount: namazImages.length,
        itemBuilder: (context, index) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: mainColor, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: mainColor.withOpacity(0.25),
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.asset(namazImages[index], fit: BoxFit.cover),
            ),
          );
        },
      ),
    );
  }
}
