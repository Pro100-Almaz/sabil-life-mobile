import 'package:flutter/material.dart';

abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
}

abstract final class AppRadius {
  static const double button = 10;
  static const double card = 12;
  static const double image = 12;
  static const double chip = 999;
  static const double sheet = 16;
}

abstract final class AppShadow {
  /// The single soft shadow token used across the app (~8% black).
  static const List<BoxShadow> soft = [
    BoxShadow(offset: Offset(0, 2), blurRadius: 12, color: Color(0x14000000)),
  ];
}
