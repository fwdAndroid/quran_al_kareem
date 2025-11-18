import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_al_kareem/provider/language_providrer.dart';
import 'package:quran_al_kareem/screens/widget/arabic_text_widget.dart';
import 'package:quran_al_kareem/utils/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class TermsAndServicesScreen extends StatefulWidget {
  const TermsAndServicesScreen({super.key});

  @override
  State<TermsAndServicesScreen> createState() => _TermsAndServicesScreenState();
}

class _TermsAndServicesScreenState extends State<TermsAndServicesScreen> {
  Future<void> _launchRateUs() async {
    const url =
        'https://ashaapp.online/terms-of-service-tos-islampro/'; // change to your app ID
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Play Store')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        title: ArabicText(
          lang.localizedStrings["Terms of Service"] ?? "Terms of Service",
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
                    lang.localizedStrings["Terms of Service Overview"] ??
                        "Terms of Service Overview",
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
                      lang.localizedStrings["We take your terms of service seriously  and are commited to protected your personal information. We collect only the minimal data needed to provide and improve our services."] ??
                          "We take your terms of service seriously  and are commited to protected your personal information. We collect only the minimal data needed to provide and improve our services.",
                      style: TextStyle(fontSize: 16.0, color: primaryText),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      lang.localizedStrings["For complete details about our data collection,usage and your rights. please read our full Terms of Service."] ??
                          "For complete details about our data collection,usage and your rights. please read our full Terms of Service.",
                      style: TextStyle(fontSize: 16.0, color: primaryText),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
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
                    lang.localizedStrings["View Full Terms of Service"] ??
                        "View Full Terms of Service",
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
                      lang.localizedStrings["Read our complete Terms of Service\n on our website."] ??
                          "Read our complete Terms of Service\n on our website.",
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
