import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

extension ColorExt on Color {
  Color withAlphaSafe(double opacity) {
    return withAlpha((opacity * 255).round());
  }
}

class AppColors {
  // ── Backgrounds — Deep Space Aurora ────────────────────────
  static const bg1 = Color(0xFF030510);
  static const bg2 = Color(0xFF07091C);
  static const bg3 = Color(0xFF0B0F28);
  static const bgCard = Color(0xFF0E1230);

  // ── Primary Accents ─────────────────────────────────────────
  static const cyan    = Color(0xFF00D4FF);
  static const cyanDim = Color(0xFF0086A8);
  static const cyanGlow = Color(0xFF00F0FF);
  static const purple  = Color(0xFF8B5CF6);
  static const purpleLight = Color(0xFFB47FFF);
  static const pink    = Color(0xFFEC4899);
  static const pinkGlow = Color(0xFFFF6EC7);
  static const amber   = Color(0xFFF59E0B);
  static const amberGlow = Color(0xFFFFD000);
  static const green   = Color(0xFF10B981);
  static const greenGlow = Color(0xFF00FF9D);
  static const orange  = Color(0xFFF97316);
  static const red     = Color(0xFFEF4444);
  static const redGlow = Color(0xFFFF6B6B);

  // ── Glass layers ────────────────────────────────────────────
  static Color get glass     => Colors.white.withAlphaSafe(0.04);
  static Color get glassMid  => Colors.white.withAlphaSafe(0.07);
  static Color get glassHigh => Colors.white.withAlphaSafe(0.12);
  static Color get glassTop  => Colors.white.withAlphaSafe(0.18);
  static Color get border    => Colors.white.withAlphaSafe(0.08);
  static Color get borderHi  => Colors.white.withAlphaSafe(0.20);
  static Color get borderGlow => cyan.withAlphaSafe(0.30);

  // ── Text ────────────────────────────────────────────────────
  static const textPrimary = Color(0xFFF0F6FF);
  static const textSub     = Color(0xFF8899CC);
  static const textMuted   = Color(0xFF3D4F7A);
  static const textAccent  = Color(0xFF00D4FF);

  // ── Spacing & Radius ────────────────────────────────────────
  static const double radiusSm = 8.0;
  static const double radiusMd = 14.0;
  static const double radiusLg = 22.0;
  static const double radiusXl = 32.0;

  // ── Weather condition gradients ─────────────────────────────
  static const gradSunny  = [Color(0xFF0F0500), Color(0xFF1E0800), Color(0xFF0A0E22)];
  static const gradCloudy = [Color(0xFF080C1A), Color(0xFF101528), Color(0xFF0B0F22)];
  static const gradRainy  = [Color(0xFF02061A), Color(0xFF060E2C), Color(0xFF04091A)];
  static const gradStormy = [Color(0xFF050010), Color(0xFF0A0320), Color(0xFF030010)];
  static const gradSnowy  = [Color(0xFF060C1C), Color(0xFF0C1526), Color(0xFF08101E)];
  static const gradNight  = [Color(0xFF020310), Color(0xFF060918), Color(0xFF040712)];
  static const gradDawn   = [Color(0xFF0D0420), Color(0xFF180830), Color(0xFF0A0618)];

  // ── Gradient presets ────────────────────────────────────────
  static const gradCyan   = [Color(0xFF00D4FF), Color(0xFF0086A8)];
  static const gradPurple = [Color(0xFF8B5CF6), Color(0xFF5B21B6)];
  static const gradPink   = [Color(0xFFEC4899), Color(0xFFA21CAF)];
  static const gradAmber  = [Color(0xFFF59E0B), Color(0xFFB45309)];
  static const gradGreen  = [Color(0xFF10B981), Color(0xFF047857)];
  static const gradFire   = [Color(0xFFEF4444), Color(0xFFF97316)];
  static const gradAurora = [Color(0xFF00D4FF), Color(0xFF8B5CF6), Color(0xFFEC4899)];
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bg1,
      primaryColor: AppColors.cyan,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.cyan,
        secondary: AppColors.purple,
        surface: AppColors.bg2,
        error: AppColors.red,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withAlphaSafe(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.white.withAlphaSafe(0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.white.withAlphaSafe(0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.cyan, width: 1.5),
        ),
        hintStyle: const TextStyle(color: AppColors.textMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.bg2,
        contentTextStyle: const TextStyle(color: AppColors.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
