import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_al_kareem/provider/font_provider.dart';
import 'package:quran_al_kareem/provider/language_providrer.dart';
import 'package:quran_al_kareem/screens/widget/arabic_text_widget.dart';
import 'package:quran_al_kareem/utils/colors.dart';

class FontSettingsScreen extends StatelessWidget {
  final List<String> fonts = ['Tahoma', 'Amiri', 'Scheherazade', 'KFGQPC'];

  @override
  Widget build(BuildContext context) {
    final fontProvider = Provider.of<FontSettingsProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: IconThemeData(color: primaryText),
        title: ArabicText(
          'Font Settings',
          style: TextStyle(color: primaryText, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                ArabicText(
                  languageProvider
                          .localizedStrings["Choose the type of Arabic font"] ??
                      "Choose the type of Arabic font",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Font Selection (Radio Buttons)
                ...fonts.map((font) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: RadioListTile<String>(
                      title: ArabicText(
                        font,
                        style: TextStyle(fontFamily: font),
                      ),
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      value: font,
                      groupValue: fontProvider.arabicFontFamily,
                      onChanged: (value) {
                        if (value != null) {
                          fontProvider.updateFontFamily(value);
                        }
                      },
                    ),
                  );
                }).toList(),

                const SizedBox(height: 20),
                ArabicText(
                  languageProvider.localizedStrings["Font Size"] ?? "Font Size",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Slider(
                  value: fontProvider.fontSize,
                  min: 18,
                  max: 48,
                  divisions: 10,
                  label: fontProvider.fontSize.toInt().toString(),
                  onChanged: (size) {
                    fontProvider.updateFontSize(size);
                  },
                ),
                Center(
                  child: ArabicText(
                    "${fontProvider.fontSize.toInt()} px",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),

                const SizedBox(height: 24),
                const Divider(color: Colors.white70),
                const SizedBox(height: 16),

                ArabicText(
                  languageProvider.localizedStrings["Font Preview"] ??
                      "Font Preview",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ArabicText(
                    languageProvider
                            .localizedStrings["God is the Light of the heavens and the earth."] ??
                        'ٱللَّهُ نُورُ ٱلسَّمَـٰوَٰتِ وَٱلْأَرْضِ',
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 30),

                // Reset Button
                Center(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    icon: const Icon(Icons.refresh),
                    label: ArabicText(
                      languageProvider
                              .localizedStrings["Restore default settings"] ??
                          "Restore default settings",
                    ),
                    onPressed: () {
                      fontProvider.updateFontFamily('Amiri');
                      fontProvider.updateFontSize(24.0);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: ArabicText(
                            languageProvider
                                    .localizedStrings["Default settings have been restored"] ??
                                "Default settings have been restored",
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
