// 🌠 Floating Stars Painter
import 'dart:math';

import 'package:flutter/material.dart';

class StarFieldPainter extends CustomPainter {
  final Random random = Random();
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.8);
    for (int i = 0; i < 50; i++) {
      final dx = random.nextDouble() * size.width;
      final dy = random.nextDouble() * size.height * 0.6;
      final radius = random.nextDouble() * 1.5;
      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
