import 'package:flutter/material.dart';
import 'package:quran_al_kareem/model/qari_model.dart';
import 'package:quran_al_kareem/screens/widget/arabic_text_widget.dart';

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
    return GestureDetector(
      onTap: widget.ontap,
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white24,
              child: ArabicText(
                '${widget.index + 1}', // show 1,2,3,...
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ArabicText(
              widget.qari.name!,
              // 'Res',
              style: const TextStyle(color: Colors.white, fontSize: 14),
              overflow: TextOverflow.fade,
            ),
          ),
        ],
      ),
    );
  }
}
