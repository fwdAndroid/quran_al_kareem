import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NamazGuideScreen extends StatelessWidget {
  const NamazGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final arabicStyle = GoogleFonts.notoNaskhArabic(fontSize: 18, height: 1.8);
    final engStyle = GoogleFonts.poppins(fontSize: 16, height: 1.6);

    return Scaffold(
      appBar: AppBar(
        title: const Text("🕌 Complete Salah (Namaz) Guide"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _buildIntro(context, engStyle),
          const SizedBox(height: 12),

          _buildTile(
            "STEP 1 — Takbeer al-Ihraam",
            "Raise both hands up to ears and say:",
            '''
اللَّهُ أَكْبَرُ  
Allāhu Akbar  
Meaning: Allah is the Greatest.
''',
            arabicStyle,
            engStyle,
          ),

          _buildTile(
            "STEP 2 — Qiyaam (Standing)",
            "Place right hand over left and recite Dua al-Istiftah:",
            '''
سُبْحَانَكَ اللَّهُمَّ وَبِحَمْدِكَ، وَتَبَارَكَ اسْمُكَ، وَتَعَالَى جَدُّكَ، وَلَا إِلٰهَ غَيْرُكَ  
Subhānaka Allāhumma wa biḥamdika, wa tabāraka ismuka, wa ta‘ālā jadduka, wa lā ilāha ghayruk  
Meaning: Glory be to You, O Allah, and praise. Blessed is Your name, exalted is Your majesty, and there is no god besides You.
''',
            arabicStyle,
            engStyle,
          ),

          _buildTile(
            "STEP 3 — Surah Al-Fātiḥah",
            "Recite the Opening Chapter of the Qur’an:",
            '''
بِسْمِ اللَّهِ الرَّحْمَـٰنِ الرَّحِيمِ  
ٱلْـحَمْدُ لِلَّهِ رَبِّ ٱلْعَـٰلَمِينَ  
ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ  
مَـٰلِكِ يَوْمِ ٱلدِّينِ  
إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ  
ٱهْدِنَا ٱلصِّرَٰطَ ٱلْمُسْتَقِيمَ  
صِرَٰطَ ٱلَّذِينَ أَنْعَمْتَ عَلَيْهِمْ  
غَيْرِ ٱلْمَغْضُوبِ عَلَيْهِمْ وَلَا ٱلضَّآلِّينَ  
آمِينَ
''',
            arabicStyle,
            engStyle,
          ),

          _buildTile(
            "STEP 4 — Another Surah (e.g. Al-Ikhlas)",
            "Recite after Surah Al-Fātiḥah:",
            '''
قُلْ هُوَ اللَّهُ أَحَدٌ  
اللَّهُ الصَّمَدُ  
لَمْ يَلِدْ وَلَمْ يُولَدْ  
وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ  
Meaning: Say, He is Allah, the One and Only...
''',
            arabicStyle,
            engStyle,
          ),

          _buildTile(
            "STEP 5 — Rukoo‘ (Bowing)",
            "Bend forward, hands on knees, and say three times:",
            '''
سُبْحَانَ رَبِّيَ الْعَظِيمِ  
Subḥāna Rabbiyal-‘Aẓīm  
Meaning: Glory be to my Lord, the Most Great.

Then rise saying:  
سَمِعَ اللَّهُ لِمَنْ حَمِدَهُ  
رَبَّنَا وَلَكَ الْحَمْدُ
''',
            arabicStyle,
            engStyle,
          ),

          _buildTile(
            "STEP 6 — Sujood (Prostration)",
            "Go down and say three times:",
            '''
سُبْحَانَ رَبِّيَ الأَعْلَى  
Subḥāna Rabbiyal-A‘lā  
Meaning: Glory be to my Lord, the Most High.
''',
            arabicStyle,
            engStyle,
          ),

          _buildTile(
            "STEP 7 — Sitting Between Two Sujoods",
            "Sit upright and say:",
            '''
رَبِّ اغْفِرْ لِي، رَبِّ اغْفِرْ لِي  
Rabbi ighfir lī, Rabbi ighfir lī  
Meaning: My Lord, forgive me; my Lord, forgive me.
''',
            arabicStyle,
            engStyle,
          ),

          _buildTile(
            "STEP 8 — Second Sujood",
            "Repeat Sujood and stand for next Rak‘ah:",
            '''
سُبْحَانَ رَبِّيَ الأَعْلَى ×3  
Then rise saying: اللَّهُ أَكْبَرُ
''',
            arabicStyle,
            engStyle,
          ),

          _buildTile(
            "STEP 9 — At-Tahiyyat (Tashahhud)",
            "Sit and recite:",
            '''
التَّحِيَّاتُ لِلَّهِ، وَالصَّلَوَاتُ وَالطَّيِّبَاتُ،  
السَّلَامُ عَلَيْكَ أَيُّهَا النَّبِيُّ وَرَحْمَةُ اللَّهِ وَبَرَكَاتُهُ،  
السَّلَامُ عَلَيْنَا وَعَلَىٰ عِبَادِ اللَّهِ الصَّالِحِينَ،  
أَشْهَدُ أَنْ لَا إِلٰهَ إِلَّا اللَّهُ،  
وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ.
''',
            arabicStyle,
            engStyle,
          ),

          _buildTile(
            "STEP 10 — Darood Ibrahim",
            "Recite after Tashahhud (in final Rak‘ah):",
            '''
اللَّهُمَّ صَلِّ عَلَىٰ مُحَمَّدٍ وَعَلَىٰ آلِ مُحَمَّدٍ،  
كَمَا صَلَّيْتَ عَلَىٰ إِبْرَاهِيمَ وَعَلَىٰ آلِ إِبْرَاهِيمَ،  
إِنَّكَ حَمِيدٌ مَجِيدٌ.  
اللَّهُمَّ بَارِكْ عَلَىٰ مُحَمَّدٍ وَعَلَىٰ آلِ مُحَمَّدٍ،  
كَمَا بَارَكْتَ عَلَىٰ إِبْرَاهِيمَ وَعَلَىٰ آلِ إِبْرَاهِيمَ،  
إِنَّكَ حَمِيدٌ مَجِيدٌ.
''',
            arabicStyle,
            engStyle,
          ),

          _buildTile(
            "STEP 11 — Final Dua (Before Ending Salah)",
            "You may recite any dua from the Qur’an or Sunnah:",
            '''
رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ  
Meaning: Our Lord! Give us good in this world and good in the Hereafter and save us from the torment of the Fire.
''',
            arabicStyle,
            engStyle,
          ),

          _buildTile(
            "STEP 12 — Tasleem (Ending Salah)",
            "Turn your head to the right and left:",
            '''
السَّلَامُ عَلَيْكُمْ وَرَحْمَةُ اللَّهِ → right  
السَّلَامُ عَلَيْكُمْ وَرَحْمَةُ اللَّهِ → left  
Meaning: Peace and mercy of Allah be upon you.
''',
            arabicStyle,
            engStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildIntro(BuildContext context, TextStyle engStyle) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text('''
Make Wudu (Ablution) — be clean and in a state of purity.

Face Qiblah (towards Ka’bah). Stand upright, feet slightly apart, and focus with khushu (humility).

Make the Intention (Niyyah):  
“I intend to perform two/four Rak‘ah Salah for Allah, facing the Qiblah.”
''', style: engStyle),
      ),
    );
  }

  Widget _buildTile(
    String title,
    String subtitle,
    String body,
    TextStyle arabicStyle,
    TextStyle engStyle,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        title: Text(
          title,
          style: engStyle.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          subtitle,
          style: engStyle.copyWith(color: Colors.grey[700]),
        ),
        childrenPadding: const EdgeInsets.all(12),
        children: [
          SelectableText(body, style: arabicStyle, textAlign: TextAlign.start),
        ],
      ),
    );
  }
}
