import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: kScaffoldBg,
      primaryColor: kPrimaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: kPrimaryColor,
      ).copyWith(
        primary: kPrimaryColor,
        secondary: kAccentColor,
        surface: kScaffoldBg,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.poppins(fontSize: 30, fontWeight: FontWeight.w700, color: kTextPrimary),
        displayMedium: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w700, color: kTextPrimary),
        headlineMedium: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: kTextPrimary),
        headlineSmall: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: kTextPrimary),
        titleLarge: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500, color: kTextPrimary),
        bodyLarge: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w400, color: kTextSecondary),
        bodyMedium: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w400, color: kTextSecondary),
        labelLarge: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: kTextPrimary),
        labelSmall: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: kTextTertiary),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: kPrimaryColor,
        elevation: 0,
        centerTitle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(24),
          ),
        ),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kButtonColor,
          foregroundColor: kButtonText,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
          textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: kInputBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: kPrimaryColor, width: 1.5),
        ),
        prefixIconColor: kTextSecondary,
        hintStyle: GoogleFonts.poppins(color: kTextTertiary, fontSize: 14),
        labelStyle: GoogleFonts.poppins(color: kTextSecondary, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      cardTheme: CardThemeData(
        color: kCardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  // ── Dark theme ─────────────────────────────────────────────────────────────
  // Reference: deep dark UI like the screenshot — near-black bg, dark cards,
  // dark AppBar, dark bottom nav, buttons keep their cyan color.
  static ThemeData get darkTheme {
    const Color darkScaffold  = Color(0xFF0A0C14); // Very deep dark navy-black
    const Color darkCard      = Color(0xFF13161F); // Dark card surface
    const Color darkCardElev  = Color(0xFF1C1F2E); // Slightly raised card
    const Color darkInput     = Color(0xFF1C1F2E); // Input bg
    const Color darkAppBar    = Color(0xFF13161F); // AppBar dark (not cyan)
    const Color darkTextPri   = Color(0xFFF0F4FF); // Near-white
    const Color darkTextSec   = Color(0xFFB0B8CC); // Muted blue-gray
    const Color darkTextTer   = Color(0xFF5C657A); // Tertiary
    const Color darkDivider   = Color(0xFF1E2236); // Subtle divider

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkScaffold,
      primaryColor: kPrimaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: kPrimaryColor,
        brightness: Brightness.dark,
      ).copyWith(
        primary: kPrimaryColor,
        secondary: kAccentColor,
        surface: darkCard,
        surfaceContainerHighest: darkCardElev,
        onSurface: darkTextPri,
      ),
      dividerColor: darkDivider,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.poppins(fontSize: 30, fontWeight: FontWeight.w700, color: darkTextPri),
        displayMedium: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w700, color: darkTextPri),
        headlineMedium: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: darkTextPri),
        headlineSmall: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: darkTextPri),
        titleLarge: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500, color: darkTextPri),
        bodyLarge: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w400, color: darkTextSec),
        bodyMedium: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w400, color: darkTextSec),
        labelLarge: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: darkTextPri),
        labelSmall: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: darkTextTer),
      ),
      // ── Dark AppBar: dark card color, NOT cyan ──────────────────────────────
      appBarTheme: const AppBarTheme(
        backgroundColor: darkAppBar,
        elevation: 0,
        centerTitle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(24),
          ),
          side: BorderSide(color: darkDivider, width: 0.5),
        ),
        titleTextStyle: TextStyle(color: darkTextPri, fontSize: 18, fontWeight: FontWeight.bold),
        iconTheme: IconThemeData(color: darkTextPri),
        foregroundColor: darkTextPri,
      ),
      // ── Buttons keep their cyan accent color ────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kButtonColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
          textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkInput,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: kPrimaryColor, width: 1.5),
        ),
        prefixIconColor: darkTextSec,
        hintStyle: GoogleFonts.poppins(color: darkTextTer, fontSize: 14),
        labelStyle: GoogleFonts.poppins(color: darkTextSec, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
