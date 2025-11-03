import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:quran_al_kareem/provider/language_providrer.dart';
import 'package:quran_al_kareem/screens/pages/audio_screen.dart';
import 'package:quran_al_kareem/screens/pages/prayer_screen.dart';
import 'package:quran_al_kareem/screens/pages/qibla_screen.dart';
import 'package:quran_al_kareem/screens/pages/quran_screen.dart';
import 'package:quran_al_kareem/screens/pages/setting_screen.dart';
import 'package:ionicons/ionicons.dart';
import 'package:quran_al_kareem/utils/colors.dart';

class MainDashboard extends StatefulWidget {
  final int initialPageIndex; // new

  const MainDashboard({super.key, this.initialPageIndex = 0});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const QuranScreen(),
    const AudioQuranScreen(),
    PrayerScreen(),
    QiblaScreen(),
    const SettingScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await _showExitDialog(context);
        return shouldPop ?? false;
      },
      child: Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.brown,
            currentIndex: _selectedIndex,
            selectedItemColor: mainColor,
            unselectedItemColor: Colors.grey.shade500,
            showUnselectedLabels: true,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            onTap: (index) {
              setState(() => _selectedIndex = index);
            },
            items: [
              BottomNavigationBarItem(
                icon: Icon(Ionicons.book_outline),
                activeIcon: Icon(Ionicons.book),
                label: languageProvider.localizedStrings["Quran"] ?? "Quran",
              ),
              BottomNavigationBarItem(
                icon: Icon(Ionicons.book),
                activeIcon: Icon(Ionicons.hand_left),
                label:
                    languageProvider.localizedStrings["Audio Quran"] ??
                    "Audio Quran",
              ),
              BottomNavigationBarItem(
                icon: Icon(Ionicons.time_outline),
                activeIcon: Icon(Ionicons.time),
                label: languageProvider.localizedStrings["Prayer"] ?? "Prayer",
              ),
              BottomNavigationBarItem(
                icon: Icon(Ionicons.compass_outline),
                activeIcon: Icon(Ionicons.compass),
                label: languageProvider.localizedStrings["Qibla"] ?? "Qibla",
              ),
              BottomNavigationBarItem(
                icon: Icon(Ionicons.settings_outline),
                activeIcon: Icon(Ionicons.settings),
                label:
                    languageProvider.localizedStrings["Settings"] ?? "Settings",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _showExitDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Exit App'),
        content: Text('Do you want to exit the app?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () {
              if (Platform.isAndroid) {
                SystemNavigator.pop(); // For Android
              } else if (Platform.isIOS) {
                exit(0); // For iOS
              }
            },
            child: Text('Yes'),
          ),
        ],
      ),
    );
  }
}
