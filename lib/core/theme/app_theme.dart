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
        shadow: Colors.black.withOpacity(0.08),
      ).copyWith(
        primary: kPrimaryColor,
        secondary: kAccentColor,
        surface: kCardBg,
      ),
      dividerColor: Colors.grey.withOpacity(0.2),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.poppins(fontSize: 30, fontWeight: FontWeight.w700, color: kTextPrimary),
        displayMedium: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w700, color: kTextPrimary),
        headlineMedium: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: kTextPrimary),
        headlineSmall: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: kTextPrimary),
        titleLarge: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: kTextPrimary),
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
            bottom: Radius.circular(30),
          ),
        ),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        iconTheme: IconThemeData(color: Colors.white),
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kButtonColor,
          foregroundColor: kButtonText,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 0,
          textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: kPrimaryColor, width: 1.5),
        ),
        prefixIconColor: kTextSecondary,
        hintStyle: GoogleFonts.poppins(color: kTextTertiary, fontSize: 14),
        labelStyle: GoogleFonts.poppins(color: kTextSecondary, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      ),
      cardTheme: CardThemeData(
        color: kCardBg,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
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
    const Color darkScaffold  = kDeepBlack;
    const Color darkCard      = kDarkCard;
    const Color darkCardElev  = kDarkCardElev;
    const Color darkInput     = kDarkInput;
    const Color darkAppBar    = kDeepBlack;
    const Color darkTextPri   = Color(0xFFFFFFFF);
    const Color darkTextSec   = Color(0xFFA0A0A0);
    const Color darkTextTer   = Color(0xFF5C657A);
    const Color darkDivider   = kDarkDivider;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkScaffold,
      primaryColor: kPrimaryTeal,
      colorScheme: ColorScheme.fromSeed(
        seedColor: kPrimaryTeal,
        brightness: Brightness.dark,
      ).copyWith(
        primary: kPrimaryTeal,
        secondary: kAccentColor,
        surface: darkCard,
        surfaceContainerHighest: darkCardElev,
        onSurface: darkTextPri,
      ),
      dividerColor: darkDivider,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.poppins(fontSize: 30, fontWeight: FontWeight.w700, color: darkTextPri),
        displayMedium: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w700, color: darkTextPri),
        headlineMedium: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: darkTextPri),
        headlineSmall: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: darkTextPri),
        titleLarge: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: darkTextPri),
        bodyLarge: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w400, color: darkTextSec),
        bodyMedium: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w400, color: darkTextSec),
        labelLarge: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: darkTextPri),
        labelSmall: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: darkTextTer),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkAppBar,
        elevation: 0,
        centerTitle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
        titleTextStyle: TextStyle(color: darkTextPri, fontSize: 18, fontWeight: FontWeight.bold),
        iconTheme: IconThemeData(color: darkTextPri),
        foregroundColor: darkTextPri,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryTeal,
          foregroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 0,
          textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkInput,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: kPrimaryTeal, width: 1.5),
        ),
        prefixIconColor: darkTextSec,
        hintStyle: GoogleFonts.poppins(color: darkTextTer, fontSize: 14),
        labelStyle: GoogleFonts.poppins(color: darkTextSec, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
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
