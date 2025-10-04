import 'dart:math';
import 'package:flutter/material.dart';

class Treemap {
  String title;
  double value;
  Widget? child;
  Color color;

  Treemap({required this.title, required this.value, this.child, Color? color})
    : color = color ?? _getRandomColor();

  static Color _getRandomColor() {
    final Random random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }
}
