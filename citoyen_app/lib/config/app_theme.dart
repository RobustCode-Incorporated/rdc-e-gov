import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Couleurs principales
  static const Color primaryBlue = Color(0xFF0095C9);
  static const Color primaryYellow = Color(0xFFFFF24B);
  static const Color primaryRed = Color(0xFFDB3832);
  static const Color primaryGreen = Color(0xFF28A745); // ou la couleur que tu veux

  // Couleurs secondaires / texte
  static const Color darkText = Color(0xFF323230);
  static const Color mediumGray = Color(0xFFAFB8BE);
  static const Color lightBackground = Color(0xFFF9E3D5);
  static const Color brownText = Color(0xFF6B5854);
  static const Color darkBlue = Color(0xFF17418A);
  static const Color accentGreen = Color(0xFF1A806C);
  static const Color lightGreen = Color(0xFF65B32E);
  static const Color orange = Color(0xFFED7016);
  static const Color darkBrown = Color(0xFF63230B);
  static const Color darkPurple = Color(0xFF9C0055);
  static const Color lightBrown = Color(0xFFCBAC7E);
  

  // Ajoute d'autres couleurs si nécessaire selon ta palette
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    primaryColor: AppColors.primaryBlue,
    hintColor: AppColors.primaryYellow,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      color: AppColors.primaryBlue,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    textTheme: GoogleFonts.robotoTextTheme( // CHANGEMENT ICI : Utilise Roboto
      const TextTheme(
        displayLarge: TextStyle(fontSize: 96, fontWeight: FontWeight.bold, color: AppColors.darkText),
        displayMedium: TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: AppColors.darkText),
        displaySmall: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppColors.darkText),
        headlineMedium: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: AppColors.darkText),
        headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.darkText),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.darkText),
        bodyLarge: TextStyle(fontSize: 16, color: AppColors.darkText),
        bodyMedium: TextStyle(fontSize: 14, color: AppColors.darkText),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        bodySmall: TextStyle(fontSize: 12, color: AppColors.darkText),
        labelSmall: TextStyle(fontSize: 10, color: AppColors.darkText),
      ),
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: AppColors.primaryBlue,
      textTheme: ButtonTextTheme.primary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryBlue, // couleur de fond du bouton
        foregroundColor: Colors.white, // couleur du texte
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.bold), // CHANGEMENT ICI : Utilise Roboto
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightBackground.withOpacity(0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide.none,
      ),
      labelStyle: GoogleFonts.roboto(color: AppColors.brownText), // CHANGEMENT ICI : Utilise Roboto
      hintStyle: GoogleFonts.roboto(color: AppColors.mediumGray), // CHANGEMENT ICI : Utilise Roboto
    ),
  );
}
