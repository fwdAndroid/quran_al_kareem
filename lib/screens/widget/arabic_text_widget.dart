import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_al_kareem/provider/font_provider.dart';

class ArabicText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ArabicText(
    this.text, {
    super.key,
    this.style,
    this.textAlign = TextAlign.left,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final fontProvider = Provider.of<FontSettingsProvider>(context);

    return Text(
      text,
      textDirection: TextDirection.rtl,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style:
          style?.copyWith(
            fontFamily: fontProvider.arabicFontFamily,
            fontSize: fontProvider.fontSize,
          ) ??
          TextStyle(
            fontFamily: fontProvider.arabicFontFamily,
            fontSize: fontProvider.fontSize,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
    );
  }
}
