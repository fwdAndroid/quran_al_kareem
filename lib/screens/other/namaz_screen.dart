import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_al_kareem/screens/widget/arabic_text_widget.dart';
import 'package:quran_al_kareem/utils/colors.dart';

class NamazGuideScreen extends StatelessWidget {
  const NamazGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textStyle = GoogleFonts.notoNaskhArabic(fontSize: 18, height: 1.6);

    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: mainColor,
        title: const ArabicText(
          'Complete Salah (Namaz) Guide',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ArabicText(
              '''
          🕌 **Make Wudu (Ablution)** — be clean and in a state of purity.
          
          **Face Qiblah (towards Ka’bah)**  
          Stand upright, feet slightly apart, and focus with khushu (humility).
          
          **Make the Intention (Niyyah)**  
          Say silently in your heart:  
          “I intend to perform two/four Rak‘ah Salah for Allah, facing the Qiblah.”
          
          ---
          
          ## 🕋 STEP-BY-STEP PRAYER GUIDE
          
          ### 🕐 STEP 1 — Takbeer al-Ihraam
          Raise both hands up to ears and say:  
          **اللَّهُ أَكْبَرُ**  
          *Allāhu Akbar* — Allah is the Greatest.
          
          ---
          
          ### 🕑 STEP 2 — Qiyaam (Standing)
          Place your right hand over your left hand — on the chest (for women) or above the navel (for men).
          
          **Dua al-Istiftah:**
          سُبْحَانَكَ اللَّهُمَّ وَبِحَمْدِكَ، وَتَبَارَكَ اسْمُكَ، وَتَعَالَى جَدُّكَ، وَلَا إِلٰهَ غَيْرُكَ  
          *Subhānaka Allāhumma wa biḥamdika, wa tabāraka ismuka, wa ta‘ālā jadduka, wa lā ilāha ghayruk*  
          Meaning: Glory be to You, O Allah, and praise. Blessed is Your name, exalted is Your majesty, and there is no god besides You.
          
          ---
          
          ### 🕒 STEP 3 — Recite Surah Al-Fātiḥah
          بِسْمِ اللَّهِ الرَّحْمَـٰنِ الرَّحِيمِ  
          ٱلْـحَمْدُ لِلَّهِ رَبِّ ٱلْعَـٰلَمِينَ  
          ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ  
          مَـٰلِكِ يَوْمِ ٱلدِّينِ  
          إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ  
          ٱهْدِنَا ٱلصِّرَٰطَ ٱلْمُسْتَقِيمَ  
          صِرَٰطَ ٱلَّذِينَ أَنْعَمْتَ عَلَيْهِمْ  
          غَيْرِ ٱلْمَغْضُوبِ عَلَيْهِمْ وَلَا ٱلضَّآلِّينَ  
          **آمِينَ**
          
          Meaning: In the name of Allah, the Most Gracious, the Most Merciful... (etc.)
          
          ---
          
          ### 🕓 STEP 4 — Recite Another Surah (e.g. Al-Ikhlas)
          قُلْ هُوَ اللَّهُ أَحَدٌ  
          اللَّهُ الصَّمَدُ  
          لَمْ يَلِدْ وَلَمْ يُولَدْ  
          وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ  
          Meaning: Say, He is Allah, the One and Only... (etc.)
          
          ---
          
          ### 🕔 STEP 5 — Rukoo‘ (Bowing)
          Bend forward, hands on knees, and say 3 times:  
          سُبْحَانَ رَبِّيَ الْعَظِيمِ  
          *Subḥāna Rabbiyal-‘Aẓīm* — Glory be to my Lord, the Most Great.
          
          Then rise saying:  
          سَمِعَ اللَّهُ لِمَنْ حَمِدَهُ  
          رَبَّنَا وَلَكَ الْحَمْدُ
          
          ---
          
          ### 🕕 STEP 6 — Sujood (Prostration)
          Go down and say 3 times:  
          سُبْحَانَ رَبِّيَ الأَعْلَى  
          *Subḥāna Rabbiyal-A‘lā* — Glory be to my Lord, the Most High.
          
          ---
          
          ### 🕖 STEP 7 — Sit Between Two Sujoods
          رَبِّ اغْفِرْ لِي، رَبِّ اغْفِرْ لِي  
          *Rabbi ighfir lī, Rabbi ighfir lī* — My Lord, forgive me; my Lord, forgive me.
          
          ---
          
          ### 🕗 STEP 8 — Second Sujood
          Repeat:  
          سُبْحَانَ رَبِّيَ الأَعْلَى ×3  
          Then stand up for the next Rak‘ah saying: **اللَّهُ أَكْبَرُ**
          
          ---
          
          ### 🔁 2nd Rak‘ah
          Repeat Steps 2–8.  
          After second Sujood, sit for **Tashahhud**.
          
          ---
          
          ### 🕘 STEP 9 — At-Tahiyyat (Tashahhud)
          التَّحِيَّاتُ لِلَّهِ، وَالصَّلَوَاتُ وَالطَّيِّبَاتُ،  
          السَّلَامُ عَلَيْكَ أَيُّهَا النَّبِيُّ وَرَحْمَةُ اللَّهِ وَبَرَكَاتُهُ،  
          السَّلَامُ عَلَيْنَا وَعَلَىٰ عِبَادِ اللَّهِ الصَّالِحِينَ،  
          أَشْهَدُ أَنْ لَا إِلٰهَ إِلَّا اللَّهُ،  
          وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ.
          
          ---
          
          ### 🕙 STEP 10 — For 3 or 4 Rak‘ah Salah
          After Tashahhud in 2nd Rak‘ah, stand up and complete the remaining Rak‘ahs.  
          In the last Rak‘ah, sit and recite Darood Ibrahim.
          
          ---
          
          ### 🕚 STEP 11 — Darood Ibrahim
          اللَّهُمَّ صَلِّ عَلَىٰ مُحَمَّدٍ وَعَلَىٰ آلِ مُحَمَّدٍ...  
          (O Allah, send Your mercy upon Muhammad and his family...)
          
          ---
          
          ### 🕛 STEP 12 — Final Dua
          رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ  
          Meaning: Our Lord, give us good in this world and in the Hereafter...
          
          ---
          
          ### 🕐 STEP 13 — Tasleem (Ending Salah)
          السَّلَامُ عَلَيْكُمْ وَرَحْمَةُ اللَّهِ → right  
          السَّلَامُ عَلَيْكُمْ وَرَحْمَةُ اللَّهِ → left  
          Meaning: Peace and mercy of Allah be upon you.
          ''',
              style: textStyle,
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }
}
