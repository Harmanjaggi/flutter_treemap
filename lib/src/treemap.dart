import 'package:flutter/material.dart';

class Treemap {
  String title;
  double value;
  Widget? child;
  Color? color;
  Treemap({required this.title, required this.value, this.child, this.color});
}
