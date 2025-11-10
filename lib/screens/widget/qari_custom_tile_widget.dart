import 'package:flutter/material.dart';
import 'package:quran_al_kareem/model/qari_model.dart';
import 'package:quran_al_kareem/screens/widget/arabic_text_widget.dart';
import 'package:quran_al_kareem/utils/colors.dart';

class QariCustomTile extends StatefulWidget {
  const QariCustomTile({
    Key? key,
    required this.qari,
    required this.ontap,
    required this.index, // 👈 Pass from parent list
  }) : super(key: key);

  final Qari qari;
  final VoidCallback ontap;
  final int index; // 👈 Add this

  @override
  _QariCustomTileState createState() => _QariCustomTileState();
}

class _QariCustomTileState extends State<QariCustomTile> {
  @override
  Widget build(BuildContext context) {
    final imagePath = "assets/qari_images/${widget.qari.name}.jpg";

    return GestureDetector(
      onTap: widget.ontap,
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage(imagePath),
              onBackgroundImageError: (_, __) {
                // Optional fallback image
                print("Image not found: $imagePath");
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ArabicText(
              widget.qari.name!,
              // 'Res',
              style: TextStyle(color: primaryText, fontSize: 14),
              overflow: TextOverflow.fade,
            ),
          ),
        ],
      ),
    );
  }
}
