import 'dart:math';
import 'package:flutter/material.dart';

class Treemap {
  double value;
  String? label;
  Color color;

  Treemap({required this.value, this.label, Color? color})
    : color = color ?? _getRandomColor();

  static Color _getRandomColor() {
    final Random random = Random();

    // generate values in the lighter range (150–255)
    int r = 150 + random.nextInt(106); // 150–255
    int g = 150 + random.nextInt(106);
    int b = 150 + random.nextInt(106);

    return Color.fromARGB(255, r, g, b);
  }
}
