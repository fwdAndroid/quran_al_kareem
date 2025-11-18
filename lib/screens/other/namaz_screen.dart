import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_al_kareem/provider/language_providrer.dart';
import 'package:quran_al_kareem/screens/widget/arabic_text_widget.dart';
import 'package:quran_al_kareem/utils/colors.dart';

class NamazGuideScreen extends StatelessWidget {
  const NamazGuideScreen({super.key});

  final List<Map<String, String>> namazSteps = const [
    {
      "title": "Make Wudu (Ablution)",
      "content": "Be clean and in a state of purity.",
    },
    {
      "title": "Face Qiblah",
      "content":
          "Stand upright, feet slightly apart, and focus with khushu (humility).",
    },
    {
      "title": "Make the Intention (Niyyah)",
      "content":
          "Say silently in your heart: “I intend to perform two/four Rak‘ah Salah for Allah, facing the Qiblah.”",
    },
    {
      "title": "Takbeer al-Ihraam",
      "arabic": "اللَّهُ أَكْبَرُ",
      "content":
          "Raise both hands up to ears and say Allahu Akbar — Allah is the Greatest.",
    },
    {
      "title": "Qiyaam (Standing)",
      "content":
          "Place your right hand over your left hand — on the chest (for women) or above the navel (for men).",
    },
    {
      "title": "Dua al-Istiftah",
      "arabic":
          "سُبْحَانَكَ اللَّهُمَّ وَبِحَمْدِكَ، وَتَبَارَكَ اسْمُكَ، وَتَعَالَى جَدُّكَ، وَلَا إِلٰهَ غَيْرُكَ",
      "content":
          "Glory be to You, O Allah, and praise. Blessed is Your name, exalted is Your majesty, and there is no god besides You.",
    },
    {
      "title": "Recite Surah Al-Fātiḥah",
      "arabic":
          "بِسْمِ اللَّهِ الرَّحْمَـٰنِ الرَّحِيمِ\n"
          "الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ\n"
          "الرَّحْمَـٰنِ الرَّحِيمِ\n"
          "مَالِكِ يَوْمِ الدِّينِ\n"
          "إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ\n"
          "اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ\n"
          "صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ\n"
          "غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ\n"
          "آمِينَ",
      "content":
          "In the name of Allah, the Most Gracious, the Most Merciful. "
          "All praise is due to Allah, Lord of the worlds. "
          "The Most Gracious, the Most Merciful. "
          "Master of the Day of Judgment. "
          "You alone we worship, and You alone we ask for help. "
          "Guide us on the Straight Path, "
          "the path of those upon whom You have bestowed favor, "
          "not of those who have evoked Your anger or of those who are astray. Ameen.",
    },
    {
      "title": "Recite Another Surah (e.g. Al-Ikhlas)",
      "arabic":
          "قُلْ هُوَ اللَّهُ أَحَدٌ\n"
          "اللَّهُ الصَّمَدُ\n"
          "لَمْ يَلِدْ وَلَمْ يُولَدْ\n"
          "وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ",
      "content":
          "Say, 'He is Allah, [who is] One, Allah, the Eternal Refuge. "
          "He neither begets nor is born, "
          "nor is there to Him any equivalent.'",
    },
    {
      "title": "Rukoo‘ (Bowing)",
      "arabic": "سُبْحَانَ رَبِّيَ الْعَظِيمِ",
      "content":
          "Glory be to my Lord, the Most Great. Then rise saying: سَمِعَ اللَّهُ لِمَنْ حَمِدَهُ / رَبَّنَا وَلَكَ الْحَمْدُ",
    },
    {
      "title": "Sujood (Prostration)",
      "arabic": "سُبْحَانَ رَبِّيَ الأَعْلَى",
      "content":
          "Go down and say three times: Glory be to my Lord, the Most High.",
    },
    {
      "title": "Sit Between Two Sujoods",
      "arabic": "رَبِّ اغْفِرْ لِي، رَبِّ اغْفِرْ لِي",
      "content": "My Lord, forgive me; my Lord, forgive me.",
    },
    {
      "title": "Second Sujood",
      "arabic": "سُبْحَانَ رَبِّيَ الأَعْلَى",
      "content": "Repeat the Sujood then stand for the next Rak‘ah.",
    },
    {
      "title": "At-Tahiyyat (Tashahhud)",
      "arabic":
          "التَّحِيَّاتُ لِلَّهِ، وَالصَّلَوَاتُ وَالطَّيِّبَاتُ،\n"
          "السَّلَامُ عَلَيْكَ أَيُّهَا النَّبِيُّ وَرَحْمَةُ اللَّهِ وَبَرَكَاتُهُ،\n"
          "السَّلَامُ عَلَيْنَا وَعَلَىٰ عِبَادِ اللَّهِ الصَّالِحِينَ،\n"
          "أَشْهَدُ أَنْ لَا إِلٰهَ إِلَّا اللَّهُ،\n"
          "وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ",
      "content":
          "Greetings, prayers, and goodness are for Allah. Peace be upon you, O Prophet, and the mercy of Allah and His blessings. "
          "Peace be upon us and upon the righteous servants of Allah. I bear witness that there is no deity but Allah, and I bear witness that Muhammad is His servant and messenger.",
    },
    {
      "title": "Darood Ibrahim",
      "arabic":
          "اللَّهُمَّ صَلِّ عَلَىٰ مُحَمَّدٍ وَعَلَىٰ آلِ مُحَمَّدٍ كَمَا صَلَّيْتَ عَلَىٰ إِبْرَاهِيمَ وَعَلَىٰ آلِ إِبْرَاهِيمَ، وَبَارِكْ عَلَىٰ مُحَمَّدٍ وَعَلَىٰ آلِ مُحَمَّدٍ كَمَا بَارَكْتَ عَلَىٰ إِبْرَاهِيمَ وَعَلَىٰ آلِ إِبْرَاهِيمَ فِي الْعَالَمِينَ إِنَّكَ حَمِيدٌ مَجِيدٌ",
      "content":
          "O Allah, send Your mercy upon Muhammad and his family, as You sent mercy upon Ibrahim and his family. And bless Muhammad and his family, as You blessed Ibrahim and his family. You are indeed Praiseworthy, Glorious.",
    },
    {
      "title": "Final Dua",
      "arabic":
          "رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ",
      "content":
          "Our Lord, give us good in this world and in the Hereafter, and save us from the punishment of the Fire.",
    },
    {
      "title": "Tasleem (Ending Salah)",
      "arabic":
          "السَّلَامُ عَلَيْكُمْ وَرَحْمَةُ اللَّهِ → right\n"
          "السَّلَامُ عَلَيْكُمْ وَرَحْمَةُ اللَّهِ → left",
      "content":
          "Peace and mercy of Allah be upon you — first to the right, then to the left.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: ArabicText(
          lang.localizedStrings["Complete Salah (Namaz) Guide"] ??
              "Complete Salah (Namaz) Guide",
          style: TextStyle(color: primaryText),
        ),
        iconTheme: IconThemeData(color: primaryText),
        backgroundColor: mainColor,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/bg.png", fit: BoxFit.cover),
          ),
          Container(color: mainColor.withOpacity(0.25)),
          ListView.builder(
            padding: const EdgeInsets.only(
              left: 5,
              right: 5,
              bottom: 40, // <-- add enough bottom padding
            ),
            itemCount: namazSteps.length,
            itemBuilder: (context, index) {
              final step = namazSteps[index];
              return Card(
                color: mainColor.withOpacity(0.85),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ExpansionTile(
                  collapsedIconColor: Colors.white,
                  title: Text(
                    step["title"] ?? "",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  children: [
                    if (step["arabic"] != null) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: ArabicText(
                          step["arabic"]!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 12,
                      ),
                      child: Text(
                        step["content"] ?? "",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
