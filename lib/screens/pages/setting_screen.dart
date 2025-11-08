import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_al_kareem/provider/language_providrer.dart';
import 'package:quran_al_kareem/screens/drawer_pages/change_language.dart';
import 'package:quran_al_kareem/screens/other/font_setting.dart';
import 'package:quran_al_kareem/screens/other/privacy_policy.dart';
import 'package:quran_al_kareem/screens/other/terms_of_service.dart';
import 'package:quran_al_kareem/screens/widget/arabic_text_widget.dart';
import 'package:quran_al_kareem/utils/colors.dart';
import 'package:share_plus/share_plus.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context); // Access

    return Scaffold(
      backgroundColor: mainColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/bg.png", fit: BoxFit.cover),
          ),
          Container(
            color: mainColor.withOpacity(
              0.3,
            ), // optional overlay for better contrast
          ),
          Column(
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset("assets/logo.png", height: 250),
              ),

              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 8),
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (builder) => ChangeLangage()),
                    );
                  },
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
                  title: ArabicText(
                    languageProvider.localizedStrings["Change Language"] ??
                        "Change Language",
                    style: TextStyle(color: Colors.white),
                  ),
                  leading: Icon(Icons.language, color: Colors.white),
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 8),
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (builder) => FontSettingsScreen(),
                      ),
                    );
                  },
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
                  title: ArabicText(
                    languageProvider.localizedStrings["Font Setting"] ??
                        "Font Setting",
                    style: TextStyle(color: Colors.white),
                  ),
                  leading: Icon(Icons.font_download_sharp, color: Colors.white),
                ),
              ),
              const Divider(),

              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 8),
                child: ListTile(
                  leading: const Icon(
                    Icons.privacy_tip_outlined,
                    color: Colors.white,
                  ),
                  title: const ArabicText(
                    "Privacy Policy",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PrivacyPolicyScreen(),
                      ),
                    );
                  },
                ),
              ),
              const Divider(),

              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 8),
                child: ListTile(
                  leading: const Icon(
                    Icons.article_outlined,
                    color: Colors.white,
                  ),
                  title: const ArabicText(
                    "Terms & Services",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TermsAndServicesScreen(),
                      ),
                    );
                  },
                ),
              ),
              const Divider(),

              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 8),
                child: ListTile(
                  onTap: () {
                    shareApp();
                  },
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
                  title: ArabicText(
                    languageProvider.localizedStrings["Invite Friends"] ??
                        "Invite Friends",
                    style: TextStyle(color: Colors.white),
                  ),
                  leading: Icon(Icons.share, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void shareApp() {
    String appLink =
        "https://play.google.com/store/apps/details?id=com.example.yourapp";
    Share.share("Hey, check out this amazing app: $appLink");
  }
}
