import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Constants {
  static Color darkBlue = const Color(0xFF00325A);

  static List<String> taskCategoryList = [
    'Business',
    'Programming',
    'Information Technology',
    'Human resources',
    'Marketing',
    'Design',
    'Accounting',
  ];

  static List<String> jobsList = [
    'Manager',
    'Team Leader',
    'Designer',
    'Web designer',
    'Full stack developer',
    'Mobile developer',
    'Marketing',
    'Digital marketing',
  ];
}

class AppTheme {
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color secondaryColor = Color(0xFF1976D2);
  static const Color accentColor = Color(0xFF64B5F6);
  static const Color backgroundColor = Colors.white;
  static const Color textColor = Color(0xFF333333);
  static const Color lightTextColor = Color(0xFF757575);
  static const Color errorColor = Colors.red;
  static const Color successColor = Colors.green;
  static const Color warningColor = Colors.orange;

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      textTheme: GoogleFonts.ralewayTextTheme(
        ThemeData.light().textTheme,
      ).apply(
        bodyColor: textColor,
        displayColor: primaryColor,
      ),
      appBarTheme: AppBarTheme(
        color: primaryColor,
        elevation: 0,
        titleTextStyle: GoogleFonts.raleway(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: accentColor,
          textStyle: TextStyle(
            fontFamily: GoogleFonts.raleway().fontFamily,
            fontWeight: FontWeight.w600,
          ),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: textColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: accentColor),
        ),
        labelStyle: TextStyle(color: textColor),
      ),
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: accentColor,
        surface: Colors.white,
        background: backgroundColor,
        error: errorColor,
      ),
    );
  }
}
