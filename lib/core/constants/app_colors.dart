import 'package:flutter/material.dart';

/// App Color Palette extracted and refined from the reference design:
/// Deep Navy Blue headers, Warm Ivory/Cream surfaces, Rich Muted Gold accents,
/// and clear self-evaluation feedback tones.
class AppColors {
  // Deep Navy Headers & Primary Surfaces (From Reference UI)
  static const Color headerNavy = Color(0xFF101E33);
  static const Color headerNavyLight = Color(0xFF172B47);
  static const Color navyPrimary = Color(0xFF132238);
  static const Color navyDeep = Color(0xFF0B1422);

  // Warm Ivory & Cream Backgrounds (From Reference UI)
  static const Color creamBackground = Color(0xFFFAF7F2);
  static const Color cardSurface = Color(0xFFFFFFFF);
  static const Color cardWarm = Color(0xFFF7F3EB);
  static const Color cardBorder = Color(0xFFEBE4D8);

  // Rich Muted Gold (From Reference UI "Mezmure Dawit" & Button)
  static const Color goldAccent = Color(0xFFC29B4F);
  static const Color goldDark = Color(0xFFA17C32);
  static const Color goldLight = Color(0xFFF3E8CD);
  static const Color goldBorder = Color(0xFFDFCC9E);

  // Traditional Ethiopian Manuscript Vermilion / Crimson
  static const Color manuscriptCrimson = Color(0xFF8E2838);
  static const Color manuscriptCrimsonLight = Color(0xFFFBF0F2);

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF19222E);
  static const Color textSecondaryLight = Color(0xFF647283);
  static const Color textMutedLight = Color(0xFF93A0B0);

  // Self-Evaluation Button Colors (From Reference UI Screen 4)
  // Easy: Green pill with circle check
  static const Color evalEasyBg = Color(0xFFEAF5EC);
  static const Color evalEasyText = Color(0xFF2E7D32);
  static const Color evalEasyBorder = Color(0xFFC8E6C9);

  // Difficult: Amber/Orange pill with circle question mark
  static const Color evalDiffBg = Color(0xFFFDF3E5);
  static const Color evalDiffText = Color(0xFFB5701E);
  static const Color evalDiffBorder = Color(0xFFFFE0B2);

  // Forgot: Red/Rose pill with circle cross
  static const Color evalForgotBg = Color(0xFFFCEBEB);
  static const Color evalForgotText = Color(0xFFC62828);
  static const Color evalForgotBorder = Color(0xFFFFCDD2);

  // Dark Theme Palette
  static const Color darkBackground = Color(0xFF0C1420);
  static const Color darkSurface = Color(0xFF121D2C);
  static const Color darkCard = Color(0xFF172436);
  static const Color darkCardBorder = Color(0xFF22344C);
  static const Color textPrimaryDark = Color(0xFFF0EBE1);
  static const Color textSecondaryDark = Color(0xFFA5B2C0);
  static const Color textMutedDark = Color(0xFF6F7E91);
}
