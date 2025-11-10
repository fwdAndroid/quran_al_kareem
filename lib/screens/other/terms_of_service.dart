import 'package:flutter/material.dart';
import 'package:quran_al_kareem/screens/widget/arabic_text_widget.dart';
import 'package:quran_al_kareem/utils/colors.dart';

class TermsAndServicesScreen extends StatelessWidget {
  const TermsAndServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,

      appBar: AppBar(
        title: ArabicText(
          "Terms & Services",
          style: TextStyle(color: primaryText, fontWeight: FontWeight.bold),
        ),
        backgroundColor: mainColor,
        iconTheme: IconThemeData(color: primaryText),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            ArabicText(
              "By using this application, you agree to the following terms and conditions:\n\n"
              "1. The app is intended for personal, non-commercial Islamic education and guidance.\n"
              "2. All Quran, Hadith, and Dua content is sourced from authentic references.\n"
              "3. You may not copy, modify, or redistribute any part of the app without permission.\n"
              "4. The app developers are not responsible for any misuse or interpretation of the content.\n\n"
              "Continued use of the app means you agree to these terms.",
              style: TextStyle(fontSize: 16, height: 1.5, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
