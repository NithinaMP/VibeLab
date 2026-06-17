// ============================================================
// VibeLab — theme.dart
// The "Aurora Liquid Canvas" design system.
// Every color, font, and style decision lives here.
// Nothing is hardcoded in the widgets — always reference this.
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VibeLabTheme {
  VibeLabTheme._();

  // ----------------------------------------------------------
  // CORE PALETTE
  // Not pure black — cosmic ink with life in it.
  // Aurora colors shift based on the active vibe mood.
  // ----------------------------------------------------------
  static const Color cosmicInk = Color(0xFF0A0A14);       // Background
  static const Color cosmicInkLight = Color(0xFF12121F);  // Surface
  static const Color cosmicInkLighter = Color(0xFF1A1A2E); // Card surface

  // Aurora accent colors — these shift per mood
  static const Color auroraPurple = Color(0xFF7B61FF);
  static const Color auroraTeal = Color(0xFF00D4AA);
  static const Color auroraGold = Color(0xFFFFB347);
  static const Color auroraRose = Color(0xFFFF6B9D);
  static const Color auroraCyan = Color(0xFF00E5FF);
  static const Color auroraGreen = Color(0xFF69FF47);

  // Text colors
  static const Color textPrimary = Color(0xFFF0F0FF);     // Nearly white with blue tint
  static const Color textSecondary = Color(0xFF9090B0);   // Muted purple-gray
  static const Color textHint = Color(0xFF505070);        // Very muted

  // Border colors
  static const Color borderSubtle = Color(0xFF1E1E35);
  static const Color borderGlow = Color(0xFF7B61FF);

  // ----------------------------------------------------------
  // MOOD → COLOR MAPPING
  // When Gemini returns a mood_tag, we map it to aurora colors
  // This is what makes the background "feel" the vibe
  // ----------------------------------------------------------
  static const Map<String, List<Color>> moodAuroraMap = {
    'chill': [Color(0xFF4A90D9), Color(0xFF00D4AA), Color(0xFF7B61FF)],
    'hype': [Color(0xFFFF6B35), Color(0xFFFFB347), Color(0xFFFF1744)],
    'dark': [Color(0xFF1A0A2E), Color(0xFF4A0080), Color(0xFF000814)],
    'retro': [Color(0xFFFF6EC7), Color(0xFFFFE135), Color(0xFF00FFFF)],
    'nature': [Color(0xFF56AB2F), Color(0xFF00D4AA), Color(0xFF96C93D)],
    'cyberpunk': [Color(0xFF00FF88), Color(0xFF7B61FF), Color(0xFF00E5FF)],
    'romantic': [Color(0xFFFF6B9D), Color(0xFFFF8E53), Color(0xFFC850C0)],
    'corporate': [Color(0xFF2196F3), Color(0xFF00BCD4), Color(0xFF3F51B5)],
  };

  // Default aurora when no mood is detected
  static const List<Color> defaultAurora = [
    Color(0xFF7B61FF),
    Color(0xFF00D4AA),
    Color(0xFFFF6B9D),
  ];

  // ----------------------------------------------------------
  // TYPOGRAPHY
  // Display font: Space Grotesk — bold, confident, modern
  // Body font: Inter — clean, readable, professional
  // ----------------------------------------------------------
  static TextTheme get textTheme => TextTheme(
    // Hero headline — the app title, vibe result titles
    displayLarge: GoogleFonts.spaceGrotesk(
      fontSize: 48,
      fontWeight: FontWeight.w700,
      color: textPrimary,
      letterSpacing: -1.5,
    ),
    // Section headlines
    displayMedium: GoogleFonts.spaceGrotesk(
      fontSize: 32,
      fontWeight: FontWeight.w600,
      color: textPrimary,
      letterSpacing: -0.5,
    ),
    // Card titles
    displaySmall: GoogleFonts.spaceGrotesk(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: textPrimary,
    ),
    // Subsection labels
    headlineMedium: GoogleFonts.spaceGrotesk(
      fontSize: 20,
      fontWeight: FontWeight.w500,
      color: textPrimary,
    ),
    // Body text
    bodyLarge: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: textPrimary,
      height: 1.6,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: textSecondary,
      height: 1.5,
    ),
    // Captions, tags, labels
    labelLarge: GoogleFonts.inter(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: textSecondary,
      letterSpacing: 0.5,
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: textHint,
      letterSpacing: 1.0,
    ),
  );

  // ----------------------------------------------------------
  // MAIN THEME
  // ----------------------------------------------------------
  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: cosmicInk,
      textTheme: textTheme,
      colorScheme: const ColorScheme.dark(
        background: cosmicInk,
        surface: cosmicInkLight,
        primary: auroraPurple,
        secondary: auroraTeal,
        tertiary: auroraGold,
        onBackground: textPrimary,
        onSurface: textPrimary,
        onPrimary: Colors.white,
      ),

      // Input field styling
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cosmicInkLighter,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderSubtle, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderSubtle, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: auroraPurple, width: 1.5),
        ),
        hintStyle: GoogleFonts.inter(
          color: textHint,
          fontSize: 15,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),

      // Card styling
      cardTheme: CardTheme(
        color: cosmicInkLighter,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: borderSubtle, width: 1),
        ),
      ),

      // AppBar styling
      appBarTheme: AppBarTheme(
        backgroundColor: cosmicInk,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),

      // Elevated button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: auroraPurple,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Icon theme
      iconTheme: const IconThemeData(
        color: textSecondary,
        size: 22,
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: borderSubtle,
        thickness: 1,
      ),
    );
  }

  // ----------------------------------------------------------
  // HELPER: Get aurora colors for a mood tag
  // Used by AuroraBackground widget to shift colors
  // ----------------------------------------------------------
  static List<Color> getAuroraForMood(String? moodTag) {
    if (moodTag == null) return defaultAurora;
    return moodAuroraMap[moodTag.toLowerCase()] ?? defaultAurora;
  }
}