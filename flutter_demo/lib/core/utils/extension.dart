import 'package:flutter/material.dart';

extension HexColorExtension on String {
  Color toColor() {
    String hex = replaceAll("#", "").toUpperCase();
    if (hex.length == 6) {
      hex = "FF$hex"; // Add alpha if not provided
    }
    return Color(int.parse(hex, radix: 16));
  }
}
