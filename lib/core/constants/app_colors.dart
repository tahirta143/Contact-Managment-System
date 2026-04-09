import 'package:flutter/material.dart';

// PRIMARY COLOR (Solid)
const Color kPrimaryColor = Color(0xFF03AED2); // Existing cyan
const Color kPrimaryTeal  = Color(0xFF79D7D4); // New Mint/Teal for dark mode accents
const Color kPrimaryLight = Color(0xFF68D3E8); 
const Color kPrimaryDark = Color(0xFF027B96);

// DEEP DARK PALETTE
const Color kDeepBlack    = Color(0xFF000000);
const Color kDarkCard     = Color(0xFF12141C);
const Color kDarkCardElev = Color(0xFF1C1F26);
const Color kDarkInput    = Color(0xFF1C1F26);
const Color kDarkDivider  = Color(0xFF232833);
const Color kDarkTextPri  = Color(0xFFFFFFFF);
const Color kDarkTextSec  = Color(0xFFA0A0A0);

// BACKGROUNDS
const Color kScaffoldBg = Color(0xFFF4F6F9); // Light grey-blue for better card contrast
const Color kCardBg      = Color(0xFFFFFFFF); // Pure white cards
const Color kInputBg     = Color(0xFFFFFFFF); // White inputs with border

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

// - [x] Update `kScaffoldBg` in `lib/core/constants/app_colors.dart`
// - [x] Refine `lightTheme` colors and shadows in `lib/core/theme/app_theme.dart`
