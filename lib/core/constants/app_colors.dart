import 'package:flutter/material.dart';

// PRIMARY COLOR (Solid)
const Color kPrimaryColor = Color(0xFF03AED2); // The new bright cyan
const Color kPrimaryLight = Color(0xFF4AC2E0); 
const Color kPrimaryDark = Color(0xFF028AA8);

// BACKGROUNDS
const Color kScaffoldBg = Color(0xFFFFFFFF);
const Color kCardBg = Color(0xFFF9FAFB);
const Color kInputBg = Color(0xFFF3F4F6);

// TEXT COLORS
const Color kTextPrimary = Color(0xFF111827); // Very dark gray
const Color kTextSecondary = Color(0xFF4B5563); // Gray
const Color kTextTertiary = Color(0xFF9CA3AF); // Light gray
const Color kTextWhite = Color(0xFFFFFFFF);

// BUTTON COLORS
const Color kButtonColor = kPrimaryColor;
const Color kButtonText = Color(0xFFFFFFFF);

// ACCENT / STATUS
const Color kAccentColor = Color(0xFFEC4899); // Pink for special highlights
const Color kSuccess = Color(0xFF10B981);
const Color kWarning = Color(0xFFF59E0B);
const Color kError = Color(0xFFEF4444);

// DEPRECATED (Kept for compatibility during migration, mapped to new solid colors)
const Gradient kPrimaryGradient = LinearGradient(colors: [kPrimaryColor, kPrimaryColor]);
const Gradient kBgGradient = LinearGradient(colors: [kScaffoldBg, kScaffoldBg]);
const Color kPurpleDark = kPrimaryDark;
const Color kTextWhiteSoft = kTextSecondary;
const Color kTextHint = kTextTertiary;
const Color kAccentPink = kAccentColor;
