import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_al_kareem/provider/language_providrer.dart';

class ChangeLangage extends StatefulWidget {
  const ChangeLangage({super.key});

  @override
  State<ChangeLangage> createState() => _ChangeLangageState();
}

class _ChangeLangageState extends State<ChangeLangage> {
  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
    ); // Access the provider

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          languageProvider.localizedStrings['Language'] ?? "Language",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10.0, left: 16),
                child: Align(
                  alignment: AlignmentDirectional.topStart,
                  child: Text(
                    languageProvider.localizedStrings['Select Language'] ??
                        'Select Language',
                  ),
                ),
              ),

              // ListTile for English
              ListTile(
                onTap: () {
                  languageProvider.changeLanguage('en'); // Change to English
                  Navigator.pop(context);
                },
                trailing: Icon(
                  languageProvider.currentLanguage == 'en'
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: Colors.white,
                  size: 20,
                ),
                title: Text(
                  languageProvider.localizedStrings['English'] ?? "English",
                ),
              ),
              // ListTile for Arrabic
              ListTile(
                onTap: () {
                  languageProvider.changeLanguage('ar'); // Change to French
                  Navigator.pop(context);
                },
                trailing: Icon(
                  languageProvider.currentLanguage == 'ar'
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: Colors.white,
                  size: 20,
                ),
                title: Text(
                  languageProvider.localizedStrings['Arabic'] ?? "Arabic",
                ),
              ),

              // ListTile for Urdu
              ListTile(
                onTap: () {
                  languageProvider.changeLanguage('ur'); // Change to English
                  Navigator.pop(context);
                },
                trailing: Icon(
                  languageProvider.currentLanguage == 'ur'
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: Colors.white,
                  size: 20,
                ),
                title: Text(
                  languageProvider.localizedStrings['Urdu'] ?? "Urdu",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
