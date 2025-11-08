import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:quran_al_kareem/provider/language_providrer.dart';
import 'package:quran_al_kareem/screens/drawer_pages/allah_names.dart';
import 'package:quran_al_kareem/screens/drawer_pages/change_language.dart';
import 'package:quran_al_kareem/screens/drawer_pages/tasbeeh_counter.dart';
import 'package:quran_al_kareem/screens/main_dashboard.dart';
import 'package:quran_al_kareem/screens/other/dua_screen.dart';
import 'package:quran_al_kareem/screens/other/hadith_screen.dart';
import 'package:quran_al_kareem/screens/other/namaz_screen.dart';
import 'package:quran_al_kareem/screens/pages/prayer_screen.dart';
import 'package:quran_al_kareem/screens/pages/qibla_screen.dart';
import 'package:quran_al_kareem/utils/colors.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({super.key});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context); // Access

    return Drawer(
      backgroundColor: mainColor,
      child: Column(
        children: [
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8, top: 10),
            child: Image.asset("assets/logo.png", height: 150, width: 150),
          ),
          Divider(),

          ListTile(
            leading: Icon(Icons.party_mode_rounded, color: Colors.brown),

            title: Text(
              languageProvider.localizedStrings["Prayer Times"] ??
                  'Prayer Times',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w300,
                fontSize: 16,
              ),
              textAlign: TextAlign.left,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (builder) => PrayerScreen()),
              );
            },
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: ListTile(
              leading: Icon(Ionicons.book, color: Colors.brown),
              title: Text(
                languageProvider.localizedStrings["Allah Names"] ??
                    'Allah Names',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                  fontSize: 16,
                ),
                textAlign: TextAlign.left,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AllahNames()),
                );
              },
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.countertops, color: Colors.brown),

            title: Text(
              languageProvider.localizedStrings["Tasbeeh Counter"] ??
                  'Tasbeeh Counter',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w300,
                fontSize: 16,
              ),
              textAlign: TextAlign.left,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TashbeehCounter()),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.audio_file, color: Colors.brown),

            title: Text(
              languageProvider.localizedStrings["Audio Quran"] ?? 'Audio Quran',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w300,
                fontSize: 16,
              ),
              textAlign: TextAlign.left,
            ),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MainDashboard(initialPageIndex: 2),
                ),
              );
            },
          ),
          Divider(),

          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 8),
            child: ListTile(
              leading: Icon(Ionicons.book_sharp, color: Colors.brown),
              title: Text(
                languageProvider.localizedStrings["Dua"] ?? 'Dua',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                  fontSize: 16,
                ),
                textAlign: TextAlign.left,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DuaScreen()),
                );
              },
            ),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 8),
            child: ListTile(
              leading: Icon(Ionicons.bag_handle, color: Colors.brown),
              title: Text(
                languageProvider.localizedStrings["Hadith"] ?? 'Hadith',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                  fontSize: 16,
                ),
                textAlign: TextAlign.left,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HadithScreen()),
                );
              },
            ),
          ),
          Divider(),

          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 8),
            child: ListTile(
              leading: Icon(
                Ionicons.calendar_number_sharp,
                color: Colors.brown,
              ),
              title: Text(
                languageProvider.localizedStrings["Namaz"] ?? 'Namaz',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                  fontSize: 16,
                ),
                textAlign: TextAlign.left,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NamazGuideScreen()),
                );
              },
            ),
          ),
          Divider(),

          ListTile(
            leading: Icon(Icons.language, color: Colors.brown),

            title: Text(
              languageProvider.localizedStrings["Qibla"] ?? 'Qibla',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w300,
                fontSize: 16,
              ),
              textAlign: TextAlign.left,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (builder) => QiblaScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
