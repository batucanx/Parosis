import 'package:flutter/material.dart';
import 'colors.dart';

class Tracking {
  Tracking._();
  static const tighter = -0.05;
  static const tight = -0.025;
  static const normal = 0.0;
  static const wide = 0.025;
  static const wider = 0.05;
  static const widest = 0.1;
}

TextStyle figtree({
  required double size,
  required FontWeight weight,
  Color color = AppColors.ink,
  double tracking = 0,
  double? height,
}) {
  return TextStyle(
    fontFamily: 'Figtree',
    fontSize: size,
    fontWeight: weight,
    color: color,
    letterSpacing: tracking * size,
    height: height,
  );
}

class W {
  W._();
  static const medium = FontWeight.w500;
  static const semibold = FontWeight.w600;
  static const bold = FontWeight.w700;
  static const extrabold = FontWeight.w800;
}
