import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';

class KanakTheme {
  // --- 1. LIGHT THEME (Kanak Design Identity) ---
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: KanakColors.primary,
        onPrimary: Colors.white,
        secondary: KanakColors.secondary,
        onSecondary: Colors.white,
        error: KanakColors.error,
        onError: Colors.white,
        background: KanakColors.background,
        onBackground: KanakColors.textPrimary,
        surface: KanakColors.surface,
        onSurface: KanakColors.textPrimary,
        surfaceVariant: KanakColors.surfaceContainerLow,
        onSurfaceVariant: KanakColors.textSecondary,
        outline: KanakColors.outline,
      ),
      scaffoldBackgroundColor: KanakColors.background,
      
      // Card Theme
      cardTheme: CardThemeData(
        color: KanakColors.surface,
        elevation: 2,
        shadowColor: KanakColors.textPrimary.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: KanakColors.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: KanakColors.surfaceContainerLow.withOpacity(0.5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: KanakColors.outline.withOpacity(0.5), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: KanakColors.outline.withOpacity(0.5), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: KanakColors.secondary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: KanakColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: KanakColors.error, width: 2),
        ),
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: KanakColors.textSecondary,
        ),
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          color: KanakColors.textMuted,
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: KanakColors.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.manrope(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: KanakColors.primary,
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: KanakColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: KanakColors.textPrimary.withOpacity(0.05),
        centerTitle: true,
        titleTextStyle: GoogleFonts.manrope(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: KanakColors.textPrimary,
        ),
        iconTheme: const IconThemeData(
          color: KanakColors.textPrimary,
        ),
      ),

      // Typographic Hierarchy
      textTheme: TextTheme(
        displayLarge: GoogleFonts.manrope(
          fontSize: 48,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.02,
          color: KanakColors.textPrimary,
        ),
        headlineLarge: GoogleFonts.manrope(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: KanakColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.manrope(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: KanakColors.textPrimary,
        ),
        titleLarge: GoogleFonts.manrope(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: KanakColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: KanakColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: KanakColors.textSecondary,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: KanakColors.textMuted,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.05,
          color: KanakColors.textSecondary,
        ),
      ),
    );
  }

  // --- 2. DARK THEME (Midnight Indigo) ---
  static ThemeData get darkTheme {
    const Color darkBg = Color(0xFF0B1326);          // Midnight Navy Blue Floor
    const Color darkSurface = Color(0xFF171F33);     // Raised Slate Card
    const Color darkPrimary = Color(0xFF818CF8);     // Bright Indigo Accent
    const Color darkSecondary = Color(0xFF3C4A5E);   // Recessed secondary
    const Color darkText = Color(0xFFDAE2FD);        // Muted Zinc White
    const Color darkTextMuted = Color(0xFF908F9E);   // Slate Gray Muted
    const Color darkOutline = Color(0xFF454653);     // Dark Borders

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: darkPrimary,
        onPrimary: Colors.white,
        secondary: KanakColors.secondary,
        onSecondary: Colors.white,
        error: Color(0xFFFFB4AB),
        onError: Color(0xFF690005),
        background: darkBg,
        onBackground: darkText,
        surface: darkSurface,
        onSurface: darkText,
        surfaceVariant: Color(0xFF131B2E),
        onSurfaceVariant: darkTextMuted,
        outline: darkOutline,
      ),
      scaffoldBackgroundColor: darkBg,
      
      // Card Theme
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: darkOutline.withOpacity(0.4),
            width: 1,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF131B2E),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkOutline, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkOutline, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFFB4AB), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFFB4AB), width: 2),
        ),
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: darkText,
        ),
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          color: darkTextMuted,
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimary,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.manrope(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: darkPrimary,
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF131B2E),
        foregroundColor: darkText,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black.withOpacity(0.2),
        centerTitle: true,
        titleTextStyle: GoogleFonts.manrope(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: darkText,
        ),
        iconTheme: const IconThemeData(
          color: darkText,
        ),
      ),

      // Typographic Hierarchy
      textTheme: TextTheme(
        displayLarge: GoogleFonts.manrope(
          fontSize: 48,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.02,
          color: darkText,
        ),
        headlineLarge: GoogleFonts.manrope(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: darkText,
        ),
        headlineMedium: GoogleFonts.manrope(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: darkText,
        ),
        titleLarge: GoogleFonts.manrope(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: darkText,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: darkText,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: darkText,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: darkTextMuted,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.05,
          color: darkTextMuted,
        ),
      ),
    );
  }

  // Helper styles for numerical layouts and custom badges
  static TextStyle get numericStyle => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get capsLabelStyle => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.08,
      );
}
