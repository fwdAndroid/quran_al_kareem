import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quran_al_kareem/screens/pages/azkar_screen.dart';
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

  final List<Widget> _screens = const [
    QuranScreen(),
    AzkarScreen(),
    PrayerScreen(),
    QiblaScreen(),
    SettingScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            currentIndex: _selectedIndex,
            selectedItemColor: mainColor,
            unselectedItemColor: Colors.grey.shade500,
            showUnselectedLabels: true,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            onTap: (index) {
              setState(() => _selectedIndex = index);
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Ionicons.book_outline),
                activeIcon: Icon(Ionicons.book),
                label: "Quran",
              ),
              BottomNavigationBarItem(
                icon: Icon(Ionicons.hand_left_outline),
                activeIcon: Icon(Ionicons.hand_left),
                label: "Azkar",
              ),
              BottomNavigationBarItem(
                icon: Icon(Ionicons.time_outline),
                activeIcon: Icon(Ionicons.time),
                label: "Prayer",
              ),
              BottomNavigationBarItem(
                icon: Icon(Ionicons.compass_outline),
                activeIcon: Icon(Ionicons.compass),
                label: "Qibla",
              ),
              BottomNavigationBarItem(
                icon: Icon(Ionicons.settings_outline),
                activeIcon: Icon(Ionicons.settings),
                label: "Settings",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
