import 'dart:ui';

import 'package:flutter/material.dart';

class StarPainter extends CustomPainter {
  final List<Offset> stars;
  final double scrollOffset;

  StarPainter(this.stars, this.scrollOffset);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.8);
    for (var offset in stars) {
      canvas.drawCircle(
        Offset(offset.dx, offset.dy + scrollOffset * 0.05),
        1.2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
