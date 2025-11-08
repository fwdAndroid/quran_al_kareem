import 'package:flutter/material.dart';
import 'package:quran_al_kareem/utils/colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        title: const Text(
          "Privacy Policy",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: mainColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "We respect your privacy and are committed to protecting your personal data. "
              "This Privacy Policy explains how we handle your information when you use our app.\n\n"
              "1. We do not collect any unnecessary personal data.\n"
              "2. Any information such as login or subscription details are securely processed.\n"
              "3. We do not share or sell your information to third parties.\n"
              "4. Permissions (like storage or audio) are only used to enable app features.\n\n"
              "By using this app, you consent to this Privacy Policy.",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
