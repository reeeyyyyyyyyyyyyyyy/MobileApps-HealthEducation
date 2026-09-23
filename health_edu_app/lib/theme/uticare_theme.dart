import 'package:flutter/material.dart';

/// UtiCare Design System
/// Warna, tipografi, dan konstanta visual terpusat.
class UtiCareTheme {
  // === Primary Colors ===
  static const Color primary = Color(0xFF7C3AED);       // Violet-600
  static const Color primaryLight = Color(0xFFC4B5FD);  // Violet-300
  static const Color primarySubtle = Color(0xFFF5F3FF); // Violet-50
  static const Color primaryDark = Color(0xFF5B21B6);   // Violet-800

  // === Accent Colors ===
  static const Color accent = Color(0xFFEC4899);        // Pink-500
  static const Color accentLight = Color(0xFFFBCFE8);   // Pink-200

  // === Status Colors ===
  static const Color success = Color(0xFF10B981);       // Emerald-500
  static const Color successLight = Color(0xFFD1FAE5);  // Emerald-100
  static const Color warning = Color(0xFFF59E0B);       // Amber-500
  static const Color warningLight = Color(0xFFFEF3C7);  // Amber-100
  static const Color danger = Color(0xFFEF4444);        // Red-500
  static const Color dangerLight = Color(0xFFFEE2E2);   // Red-100

  // === Neutral Colors ===
  static const Color background = Color(0xFFFAF5FF);    // Lavender tint
  static const Color surface = Color(0xFFFFFFFF);       // White
  static const Color surfaceAlt = Color(0xFFF8F5FF);    // Slight purple tint
  static const Color border = Color(0xFFE9D5FF);        // Purple-200
  static const Color borderLight = Color(0xFFF3E8FF);   // Purple-100

  // === Text Colors ===
  static const Color textPrimary = Color(0xFF1E1B4B);   // Indigo-950
  static const Color textSecondary = Color(0xFF6B7280); // Gray-500
  static const Color textTertiary = Color(0xFF9CA3AF);  // Gray-400
  static const Color textOnPrimary = Color(0xFFFFFFFF); // White

  // === Risk Level Colors ===
  static const Color riskLow = Color(0xFF10B981);
  static const Color riskMedium = Color(0xFFF59E0B);
  static const Color riskHigh = Color(0xFFEF4444);

  // === Gradients ===
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7C3AED), Color(0xFF9333EA)],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF7C3AED), Color(0xFFA855F7), Color(0xFFC084FC)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF5F3FF), Color(0xFFEDE9FE)],
  );

  // === Shadows ===
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: primary.withValues(alpha: 0.08),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: primary.withValues(alpha: 0.15),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  // === Border Radius ===
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusRound = 999.0;

  // === Spacing ===
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacing2xl = 48.0;

  // === Typography ===
  static const String fontFamily = 'PlusJakartaSans';

  static const TextStyle heading1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: -0.3,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: textPrimary,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textSecondary,
  );

  static const TextStyle bodyBold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textTertiary,
  );

  static const TextStyle label = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: textSecondary,
    letterSpacing: 0.5,
  );

  // === ThemeData ===
  static ThemeData get themeData => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: accent,
      surface: surface,
    ),
    scaffoldBackgroundColor: background,
    useMaterial3: true,
    fontFamily: fontFamily,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      iconTheme: IconThemeData(color: textPrimary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: textOnPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        side: const BorderSide(color: primary, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceAlt,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: danger),
      ),
      hintStyle: const TextStyle(color: textTertiary, fontSize: 14),
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLg),
        side: BorderSide(color: border.withValues(alpha: 0.5)),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surface,
      selectedItemColor: primary,
      unselectedItemColor: textTertiary,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
      unselectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
    ),
  );

  // === Helper Methods ===
  static Color getRiskColor(String level) {
    switch (level.toLowerCase()) {
      case 'rendah':
        return riskLow;
      case 'sedang':
        return riskMedium;
      case 'tinggi':
        return riskHigh;
      default:
        return textTertiary;
    }
  }

  static Color getRiskBgColor(String level) {
    switch (level.toLowerCase()) {
      case 'rendah':
        return successLight;
      case 'sedang':
        return warningLight;
      case 'tinggi':
        return dangerLight;
      default:
        return surfaceAlt;
    }
  }

  static String getRiskLabel(int score, int maxScore) {
    final pct = score / maxScore;
    if (pct <= 0.33) return 'RENDAH';
    if (pct <= 0.66) return 'SEDANG';
    return 'TINGGI';
  }
}
