import 'package:flutter/material.dart';
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
                child: Image.asset("assets/logo.png", height: 150),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (builder) => NotificationSetting(),
                    //   ),
                    // );
                  },
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
                  title: Text(
                    // languageProvider.localizedStrings["Notifications"] ??
                    "Notifications",
                    style: TextStyle(color: Colors.white),
                  ),
                  leading: Icon(Icons.notifications, color: Colors.white),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 8),
                child: ListTile(
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (builder) => ChangeLangage()),
                    // );
                  },
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
                  title: Text(
                    // languageProvider.localizedStrings["Change Language"] ??
                    "Change Language",
                    style: TextStyle(color: Colors.white),
                  ),
                  leading: Icon(Icons.language, color: Colors.white),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 8),
                child: ListTile(
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (builder) => FontSettingsScreen()),
                    // );
                  },
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
                  title: Text(
                    // languageProvider.localizedStrings["Font Setting"] ??
                    "Font Setting",
                    style: TextStyle(color: Colors.white),
                  ),
                  leading: Icon(Icons.font_download, color: Colors.white),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 8),
                child: ListTile(
                  onTap: () {
                    shareApp();
                  },
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
                  title: Text(
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
