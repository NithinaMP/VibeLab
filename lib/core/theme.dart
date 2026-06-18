// ============================================================
// VibeLab — theme.dart (UI Refresh: Dark Aurora Brutalist)
// Lifted dark background, pixel font headings,
// brutalist borders, lime accent pop color.
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VibeLabTheme {
  VibeLabTheme._();

  // ----------------------------------------------------------
  // CORE PALETTE — Lifted dark, more breathable
  // ----------------------------------------------------------
  static const Color cosmicInk = Color(0xFF12121F);        // Lifted background
  static const Color cosmicInkLight = Color(0xFF1A1A2E);   // Surface
  static const Color cosmicInkLighter = Color(0xFF202038); // Card surface
  static const Color cosmicInkCard = Color(0xFF252540);    // Elevated card

  // ----------------------------------------------------------
  // ACCENT COLORS
  // ----------------------------------------------------------
  static const Color auroraPurple = Color(0xFF7B61FF);
  static const Color auroraTeal = Color(0xFF00D4AA);
  static const Color auroraGold = Color(0xFFFFB347);
  static const Color auroraRose = Color(0xFFFF6B9D);
  static const Color auroraCyan = Color(0xFF00E5FF);

  // VibeLab signature lime — the unexpected pop
  // This is our identity color. Inspired by Pollinations'
  // yellow-green but made our own.
  static const Color vibeLime = Color(0xFFC8FF57);
  static const Color vibeLimeDark = Color(0xFF9ED436);

  // ----------------------------------------------------------
  // TEXT COLORS
  // ----------------------------------------------------------
  static const Color textPrimary = Color(0xFFF0F0FF);
  static const Color textSecondary = Color(0xFF9090B0);
  static const Color textHint = Color(0xFF505070);
  static const Color textDark = Color(0xFF0A0A14); // For text on lime bg

  // ----------------------------------------------------------
  // BORDERS — Brutalist style uses visible borders
  // ----------------------------------------------------------
  static const Color borderSubtle = Color(0xFF2A2A45);
  static const Color borderNormal = Color(0xFF3A3A60);
  static const Color borderBold = Color(0xFF7B61FF);
  static const Color borderLime = Color(0xFFC8FF57);

  // ----------------------------------------------------------
  // MOOD → AURORA COLOR MAPPING
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

  static const List<Color> defaultAurora = [
    Color(0xFF7B61FF),
    Color(0xFF00D4AA),
    Color(0xFFC8FF57),
  ];

  // ----------------------------------------------------------
  // TYPOGRAPHY
  // Press Start 2P  → pixel/brutalist font for ALL headings
  // Inter           → clean readable body text
  // ----------------------------------------------------------
  static TextTheme get textTheme => TextTheme(
    // Hero — app name, page titles
    displayLarge: GoogleFonts.pressStart2p(
      fontSize: 32,
      color: textPrimary,
      height: 1.4,
    ),
    // Section headlines
    displayMedium: GoogleFonts.pressStart2p(
      fontSize: 20,
      color: textPrimary,
      height: 1.4,
    ),
    // Card titles, screen names
    displaySmall: GoogleFonts.pressStart2p(
      fontSize: 14,
      color: textPrimary,
      height: 1.5,
    ),
    // Subsection labels
    headlineMedium: GoogleFonts.pressStart2p(
      fontSize: 11,
      color: textPrimary,
      height: 1.6,
    ),
    // Body text — Inter for readability
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
  // BRUTALIST BUTTON STYLE
  // Hard border, sharp corners, flat — no soft shadows
  // ----------------------------------------------------------
  static ButtonStyle brutalistButton({
    Color bg = vibeLime,
    Color fg = textDark,
    Color border = vibeLime,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: bg,
      foregroundColor: fg,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4), // Almost sharp
        side: BorderSide(color: border, width: 2),
      ),
      textStyle: GoogleFonts.pressStart2p(
        fontSize: 11,
        color: fg,
      ),
    );
  }

  // ----------------------------------------------------------
  // BRUTALIST OUTLINED BUTTON
  // ----------------------------------------------------------
  static ButtonStyle brutalistOutlined({
    Color fg = textPrimary,
    Color border = borderNormal,
  }) {
    return OutlinedButton.styleFrom(
      foregroundColor: fg,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(color: border, width: 2),
      ),
      textStyle: GoogleFonts.pressStart2p(
        fontSize: 11,
        color: fg,
      ),
    );
  }

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
        secondary: vibeLime,
        tertiary: auroraTeal,
        onBackground: textPrimary,
        onSurface: textPrimary,
        onPrimary: Colors.white,
        onSecondary: textDark,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cosmicInkLighter,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4), // Sharp — brutalist
          borderSide: const BorderSide(color: borderNormal, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: borderNormal, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: vibeLime, width: 2),
        ),
        hintStyle: GoogleFonts.inter(
          color: textHint,
          fontSize: 14,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),

      cardTheme: CardTheme(
        color: cosmicInkLighter,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: borderSubtle, width: 1),
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: cosmicInk,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.pressStart2p(
          fontSize: 14,
          color: textPrimary,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: brutalistButton(),
      ),

      iconTheme: const IconThemeData(
        color: textSecondary,
        size: 20,
      ),

      dividerTheme: const DividerThemeData(
        color: borderSubtle,
        thickness: 1,
      ),
    );
  }

  // ----------------------------------------------------------
  // HELPER: Get aurora colors for mood
  // ----------------------------------------------------------
  static List<Color> getAuroraForMood(String? moodTag) {
    if (moodTag == null) return defaultAurora;
    return moodAuroraMap[moodTag.toLowerCase()] ?? defaultAurora;
  }
}