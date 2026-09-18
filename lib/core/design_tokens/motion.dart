import 'package:flutter/material.dart';

class AppMotion {
  // Durations
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration slower = Duration(milliseconds: 750);

  // Curves
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve easeOutCubic = Curves.easeOutCubic;
  static const Curve decelerate = Curves.decelerate;
  static const Curve fastOutSlowIn = Curves.fastOutSlowIn;
  static const Curve standard = Curves.easeInOut;
  static const Curve reduceMotion = Curves.linear;

  // Common animation specs
  static const double dragThreshold = 10.0;
  static const Duration windowAnimationDuration = Duration(milliseconds: 250);
  static const Duration fadeDuration = Duration(milliseconds: 200);
  static const Duration scaleDuration = Duration(milliseconds: 150);

  AppMotion._();
}
