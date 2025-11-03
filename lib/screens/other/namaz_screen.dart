import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_al_kareem/provider/language_providrer.dart';
import 'package:quran_al_kareem/utils/colors.dart';

class NamazStep {
  final String title;
  final String arabic;
  final String transliteration;
  final String translation;
  final String description;
  final String imagePath;

  NamazStep({
    required this.title,
    required this.arabic,
    required this.transliteration,
    required this.translation,
    required this.description,
    required this.imagePath,
  });
}

class NamazGuideScreen extends StatelessWidget {
  final List<NamazStep> steps = [
    NamazStep(
      title: '1. Niyyah (Intention)',
      arabic: 'نويت أن أصلي لله',
      transliteration: 'Nawaytu an usallia lillahi',
      translation: 'I intend to pray for Allah.',
      description:
          'Stand calmly and make your intention in your heart before starting the prayer.',
      imagePath: 'assets/images/niyyah.png',
    ),
    NamazStep(
      title: '2. Takbeer (Allahu Akbar)',
      arabic: 'الله أكبر',
      transliteration: 'Allahu Akbar',
      translation: 'Allah is the Greatest',
      description: 'Raise both hands to your ears and say Allahu Akbar.',
      imagePath: 'assets/images/takbeer.png',
    ),
    NamazStep(
      title: '3. Qiyam (Standing)',
      arabic: 'سورة الفاتحة',
      transliteration: 'Surah Al-Fatiha',
      translation: 'Recite Surah Al-Fatiha and another surah.',
      description:
          'Fold your hands on your chest and recite Surah Al-Fatiha followed by a short surah.',
      imagePath: 'assets/images/qiyam.png',
    ),
    NamazStep(
      title: '4. Ruku (Bowing)',
      arabic: 'سبحان ربي العظيم',
      transliteration: 'Subhana Rabbiyal Azeem',
      translation: 'Glory is to my Lord, the Most Great',
      description: 'Bow down with your back straight and say three times.',
      imagePath: 'assets/images/ruku.png',
    ),
    NamazStep(
      title: '5. Sujood (Prostration)',
      arabic: 'سبحان ربي الأعلى',
      transliteration: 'Subhana Rabbiyal A\'la',
      translation: 'Glory is to my Lord, the Most High',
      description:
          'Prostrate on the ground with forehead, nose, palms, knees, and toes touching the ground.',
      imagePath: 'assets/images/sujood.png',
    ),
    NamazStep(
      title: '6. Tashahhud (Sitting)',
      arabic: 'التحيات لله...',
      transliteration: 'At-tahiyyatu lillahi...',
      translation:
          'All compliments, prayers and good things belong to Allah...',
      description: 'Sit calmly on your knees and recite Tashahhud.',
      imagePath: 'assets/images/tashahhud.png',
    ),
    NamazStep(
      title: '7. Tasleem (Ending)',
      arabic: 'السلام عليكم ورحمة الله',
      transliteration: 'As-salamu Alaikum wa Rahmatullah',
      translation: 'Peace and mercy of Allah be upon you',
      description:
          'Turn your head to the right and then left to end the prayer.',
      imagePath: 'assets/images/tasleem.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context); // Access

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          languageProvider.localizedStrings["How to Pray Namaz"] ??
              'How to Pray Namaz',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: mainColor,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: EdgeInsets.zero, // 👈 Removes padding
        itemCount: steps.length,
        itemBuilder: (context, index) {
          final step = steps[index];
          return Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8),
            child: Card(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(
                          step.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          step.arabic,
                          style: const TextStyle(
                            fontSize: 26,
                            fontFamily: 'Amiri',
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          step.transliteration,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          step.translation,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          step.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
