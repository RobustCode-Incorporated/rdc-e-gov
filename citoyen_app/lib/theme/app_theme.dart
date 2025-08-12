import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static Color primaryBlue = const Color(0xFF003DA5);
  static Color secondaryBlue = const Color(0xFF104B71);
  static Color lightGray = const Color(0xFFF4F4F4);

  static ThemeData lightTheme = ThemeData(
    primaryColor: primaryBlue,
    scaffoldBackgroundColor: lightGray,
    appBarTheme: AppBarTheme(
      backgroundColor: primaryBlue,
      titleTextStyle: GoogleFonts.ebGaramond(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    textTheme: TextTheme(
      bodyLarge: GoogleFonts.roboto(fontSize: 16, color: Colors.black87),
      bodyMedium: GoogleFonts.roboto(fontSize: 14, color: Colors.black87),
      titleLarge: GoogleFonts.ebGaramond(fontSize: 22, fontWeight: FontWeight.bold, color: primaryBlue),
      labelMedium: GoogleFonts.dancingScript(fontSize: 18, color: secondaryBlue),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: secondaryBlue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: secondaryBlue),
      ),
    ),
  );
}