import 'package:flutter/material.dart';
import 'colors.dart';

class AppTypography {
  // Font families
  static const String primary = 'Inter';
  static const String display = 'Inter';
  static const String mono = 'JetBrains Mono';

  // Display
  static const TextStyle displayLarge = TextStyle(
    fontFamily: display,
    fontSize: 57,
    fontWeight: FontWeight.w400,
    height: 1.1,
    color: AppColors.textPrimary,
    letterSpacing: -0.25,
  );
  static const TextStyle displayMedium = TextStyle(
    fontFamily: display,
    fontSize: 45,
    fontWeight: FontWeight.w400,
    height: 1.1,
    color: AppColors.textPrimary,
    letterSpacing: 0.0,
  );
  static const TextStyle displaySmall = TextStyle(
    fontFamily: display,
    fontSize: 36,
    fontWeight: FontWeight.w400,
    height: 1.15,
    color: AppColors.textPrimary,
    letterSpacing: 0.0,
  );

  // Headline
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: display,
    fontSize: 32,
    fontWeight: FontWeight.w500,
    height: 1.2,
    color: AppColors.textPrimary,
    letterSpacing: 0.0,
  );
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: display,
    fontSize: 28,
    fontWeight: FontWeight.w500,
    height: 1.2,
    color: AppColors.textPrimary,
    letterSpacing: 0.0,
  );
  static const TextStyle headlineSmall = TextStyle(
    fontFamily: display,
    fontSize: 24,
    fontWeight: FontWeight.w500,
    height: 1.25,
    color: AppColors.textPrimary,
    letterSpacing: 0.0,
  );

  // Body
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: primary,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
  );
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: primary,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.43,
    color: AppColors.textSecondary,
    letterSpacing: 0.25,
  );
  static const TextStyle bodySmall = TextStyle(
    fontFamily: primary,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.33,
    color: AppColors.textSecondary,
    letterSpacing: 0.4,
  );

  // Label
  static const TextStyle labelLarge = TextStyle(
    fontFamily: primary,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.43,
    color: AppColors.textPrimary,
    letterSpacing: 0.1,
  );
  static const TextStyle labelMedium = TextStyle(
    fontFamily: primary,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.33,
    color: AppColors.textSecondary,
    letterSpacing: 0.1,
  );
  static const TextStyle labelSmall = TextStyle(
    fontFamily: primary,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.33,
    color: AppColors.textHint,
    letterSpacing: 0.1,
  );

  // Mono
  static const TextStyle monoMedium = TextStyle(
    fontFamily: mono,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.43,
    color: AppColors.textPrimary,
    letterSpacing: 0.25,
  );

  AppTypography._();
}
