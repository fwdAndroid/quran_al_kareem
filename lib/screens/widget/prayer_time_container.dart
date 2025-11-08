import 'package:flutter/material.dart';
import 'package:quran_al_kareem/screens/widget/arabic_text_widget.dart';
import 'package:quran_al_kareem/utils/colors.dart';

class PrayingTimeContainer extends StatelessWidget {
  final String icon;
  final String title;
  final String time;
  PrayingTimeContainer({
    required this.icon,
    required this.title,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Container(
        height: 70,
        width: 330,
        color: mainColor,
        child: Row(
          children: [
            SizedBox(width: 10),
            Image.asset('$icon', width: 40),
            Padding(
              padding: EdgeInsets.only(left: 25),
              child: ArabicText('$title', style: TextStyle(fontSize: 20)),
            ),
            Spacer(),
            Padding(
              padding: EdgeInsets.only(right: 15),
              child: ArabicText('$time', style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}
