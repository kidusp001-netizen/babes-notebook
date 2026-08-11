import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Soft queen pink palette
  static const Color background = Color(0xFFFFF5F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color primary = Color(0xFFEC4899);
  static const Color primaryDark = Color(0xFFDB2777);
  static const Color primaryLight = Color(0xFFFCE7F3);
  static const Color roseGold = Color(0xFFE8B4BC);
  static const Color blush = Color(0xFFFDF2F8);
  static const Color textDark = Color(0xFF4A1942);
  static const Color textMuted = Color(0xFFA67B8A);
  static const Color navDark = Color(0xFF4C1D3D);
  static const Color border = Color(0xFFFBCFE8);
  static const Color success = Color(0xFF22C55E);

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: primary.withValues(alpha: 0.08),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get primaryShadow => [
        BoxShadow(
          color: primary.withValues(alpha: 0.35),
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
      ];

  static TextStyle _sans({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
    FontStyle? fontStyle,
  }) {
    if (kIsWeb) {
      return TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
        fontStyle: fontStyle,
      );
    }
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      fontStyle: fontStyle,
    );
  }

  static TextStyle _serif({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    FontStyle? fontStyle,
  }) {
    if (kIsWeb) {
      return TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        fontStyle: fontStyle ?? FontStyle.italic,
        fontFamily: 'Georgia',
      );
    }
    return GoogleFonts.playfairDisplay(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      fontStyle: fontStyle,
    );
  }

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primary,
        onPrimary: Colors.white,
        surface: surface,
        onSurface: textDark,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: textDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: _sans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: textDark,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: _sans(color: textMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: _sans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: _sans(fontWeight: FontWeight.w600),
        ),
      ),
    );

    return base.copyWith(textTheme: _textTheme());
  }

  static TextTheme _textTheme() {
    return TextTheme(
      displayLarge: _sans(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: textDark,
        height: 1.15,
        letterSpacing: -0.5,
      ),
      displayMedium: _sans(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        color: textDark,
        height: 1.2,
        letterSpacing: -0.3,
      ),
      headlineMedium: _serif(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textDark,
        fontStyle: FontStyle.italic,
      ),
      titleLarge: _sans(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: textDark,
      ),
      titleMedium: _sans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textDark,
      ),
      bodyLarge: _sans(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: textDark,
        height: 1.55,
      ),
      bodyMedium: _sans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textMuted,
        height: 1.5,
      ),
      labelLarge: _sans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: textMuted,
      ),
    );
  }
}
