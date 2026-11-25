import 'package:flutter/cupertino.dart';

class AppColors {
  AppColors._();

  static const Color backgroundTop = Color(0xFF0B1020);
  static const Color backgroundBottom = Color(0xFF1A1F35);
  static const Color accent = Color(0xFF0A84FF); // iOS blue
  static const Color accentSecondary = Color(0xFF5E5CE6); // iOS indigo
  static const Color success = Color(0xFF30D158);
  static const Color warning = Color(0xFFFF9F0A);
  static const Color danger = Color(0xFFFF453A);

  static const Color glassFill = Color(0x1FFFFFFF); // ~12% white
  static const Color glassFillStrong = Color(0x2EFFFFFF); // ~18%
  static const Color glassBorder = Color(0x33FFFFFF); // ~20%
  static const Color glassBorderSoft = Color(0x1AFFFFFF);

  static const Color textPrimary = Color(0xFFF5F7FF);
  static const Color textSecondary = Color(0xB3F5F7FF);
  static const Color textTertiary = Color(0x80F5F7FF);

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0B1020),
      Color(0xFF151A2E),
      Color(0xFF1C2440),
    ],
    stops: [0.0, 0.55, 1.0],
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF0A84FF), Color(0xFF5E5CE6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  AppTheme._();

  static CupertinoThemeData get cupertinoTheme => const CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: AppColors.accent,
        scaffoldBackgroundColor: AppColors.backgroundTop,
        barBackgroundColor: Color(0x00000000),
        textTheme: CupertinoTextThemeData(
          primaryColor: AppColors.textPrimary,
          textStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            letterSpacing: -0.2,
          ),
          navTitleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
          navLargeTitleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
      );
}
