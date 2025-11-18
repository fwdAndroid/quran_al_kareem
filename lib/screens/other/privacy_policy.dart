import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_al_kareem/provider/language_providrer.dart';
import 'package:quran_al_kareem/screens/widget/arabic_text_widget.dart';
import 'package:quran_al_kareem/utils/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  Future<void> _launchRateUs() async {
    const url = 'https://ashaapp.online/privacy-policy-islampro/';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open website')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        title: ArabicText(
          lang.localizedStrings["Privacy Policy"] ?? "Privacy Policy",
          style: TextStyle(color: primaryText, fontWeight: FontWeight.bold),
        ),
        backgroundColor: mainColor,
        iconTheme: IconThemeData(color: primaryText),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Container
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: primaryText, width: .5),
                borderRadius: BorderRadius.circular(8.0),
              ),
              margin: EdgeInsets.only(bottom: 16.0),
              child: Column(
                children: [
                  Icon(Icons.info_outline, size: 80.0, color: primaryText),
                  SizedBox(height: 16.0),
                  Text(
                    lang.localizedStrings["Your Privacy Matters"] ??
                        "Your Privacy Matters",
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: primaryText,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      lang.localizedStrings["We take your privacy seriously and are committed to protecting your personal information. We collect only the minimal data needed to provide and improve our services."] ??
                          "We take your privacy seriously and are committed to protecting your personal information. We collect only the minimal data needed to provide and improve our services.",
                      style: TextStyle(fontSize: 16.0, color: primaryText),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      lang.localizedStrings["For complete details about our data collection, usage, and your rights, please read our full Privacy Policy."] ??
                          "For complete details about our data collection, usage, and your rights, please read our full Privacy Policy.",
                      style: TextStyle(fontSize: 16.0, color: primaryText),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            // Website Container
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: primaryText, width: .5),
                borderRadius: BorderRadius.circular(8.0),
              ),
              margin: EdgeInsets.only(bottom: 16.0),
              child: Column(
                children: [
                  Icon(Icons.language, size: 80.0, color: primaryText),
                  SizedBox(height: 16.0),
                  Text(
                    lang.localizedStrings["View Full Privacy Policy"] ??
                        "View Full Privacy Policy",
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: primaryText,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      lang.localizedStrings["Read our complete Privacy Policy\non our website."] ??
                          "Read our complete Privacy Policy\non our website.",
                      style: TextStyle(fontSize: 16.0, color: primaryText),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: Colors.grey),
                        ),
                      ),
                      onPressed: _launchRateUs,
                      child: ArabicText(
                        lang.localizedStrings["View on Website"] ??
                            "View on Website",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
