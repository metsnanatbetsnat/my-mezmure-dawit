import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static const String fontFamilySans = 'Noto Sans Ethiopic';
  static const String fontFamilySerif = 'Noto Serif Ethiopic';

  static ThemeData lightTheme({double fontScale = 1.05}) {
    final baseTextTheme = ThemeData.light().textTheme;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.navyPrimary,
      scaffoldBackgroundColor: AppColors.ivoryBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.navyPrimary,
        onPrimary: Colors.white,
        secondary: AppColors.goldMuted,
        onSecondary: Colors.white,
        surface: AppColors.parchmentSurface,
        onSurface: AppColors.textPrimaryLight,
        error: AppColors.manuscriptCrimson,
      ),
      cardTheme: CardTheme(
        color: AppColors.parchmentSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.warmCardBorder, width: 0.8),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.ivoryBackground,
        foregroundColor: AppColors.navyDeep,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: fontFamilySerif,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.navyDeep,
          letterSpacing: 0.1,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.parchmentSurface,
        selectedItemColor: AppColors.navyPrimary,
        unselectedItemColor: AppColors.textMutedLight,
        selectedLabelStyle: TextStyle(
          fontFamily: fontFamilySerif,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: fontFamilySans,
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.warmCardBorder,
        thickness: 0.7,
      ),
      textTheme: _buildTextTheme(
        baseTextTheme,
        AppColors.textPrimaryLight,
        AppColors.textSecondaryLight,
        fontScale,
      ),
    );
  }

  static ThemeData darkTheme({double fontScale = 1.05}) {
    final baseTextTheme = ThemeData.dark().textTheme;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.goldMuted,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.goldMuted,
        onPrimary: AppColors.navyDeep,
        secondary: AppColors.goldLight,
        onSecondary: AppColors.navyDeep,
        surface: AppColors.darkSurface,
        onSurface: AppColors.textPrimaryDark,
        error: AppColors.dangerRose,
      ),
      cardTheme: CardTheme(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.darkCardBorder, width: 0.8),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.textPrimaryDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: fontFamilySerif,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryDark,
          letterSpacing: 0.1,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.goldMuted,
        unselectedItemColor: AppColors.textMutedDark,
        selectedLabelStyle: TextStyle(
          fontFamily: fontFamilySerif,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: fontFamilySans,
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkCardBorder,
        thickness: 0.7,
      ),
      textTheme: _buildTextTheme(
        baseTextTheme,
        AppColors.textPrimaryDark,
        AppColors.textSecondaryDark,
        fontScale,
      ),
    );
  }

  static TextTheme _buildTextTheme(
    TextTheme base,
    Color primaryColor,
    Color secondaryColor,
    double scale,
  ) {
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: fontFamilySerif,
        fontSize: 26 * scale,
        fontWeight: FontWeight.w700,
        color: primaryColor,
        height: 1.45,
      ),
      displayMedium: TextStyle(
        fontFamily: fontFamilySerif,
        fontSize: 21 * scale,
        fontWeight: FontWeight.w700,
        color: primaryColor,
        height: 1.45,
      ),
      titleLarge: TextStyle(
        fontFamily: fontFamilySerif,
        fontSize: 18 * scale,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        height: 1.45,
      ),
      titleMedium: TextStyle(
        fontFamily: fontFamilySerif,
        fontSize: 16 * scale,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        height: 1.4,
      ),
      bodyLarge: TextStyle(
        fontFamily: fontFamilySerif, // Ge'ez reads most gracefully in serif
        fontSize: 16.5 * scale,
        fontWeight: FontWeight.w400,
        color: primaryColor,
        height: 1.75, // Comfortable line spacing for daily reading
      ),
      bodyMedium: TextStyle(
        fontFamily: fontFamilySans,
        fontSize: 14 * scale,
        fontWeight: FontWeight.w400,
        color: secondaryColor,
        height: 1.55,
      ),
      labelLarge: TextStyle(
        fontFamily: fontFamilySans,
        fontSize: 13.5 * scale,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
    );
  }
}
