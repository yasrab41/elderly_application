import 'package:flutter/material.dart';

// Custom Colors
final Color _primaryColor = const Color(0xFF48352A); // Dark Brown
final Color _secondaryColor = const Color(0xFF8D6E63); // Medium Brown

// App Theme Data
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      // --- FIX: Explicitly set background colors to white ---
      // This ensures the main screen background (Scaffold) is white
      scaffoldBackgroundColor: Colors.white,
      // This ensures cards (like your reminder card) and other surfaces are white
      cardColor: Colors.white,
      // This ensures dialogs and modal bottom sheets are white
      dialogBackgroundColor: Colors.white,
      // ------------------------------------------------------

      colorScheme: ColorScheme.light(
        primary: _primaryColor,
        secondary: _secondaryColor,
        surface: Colors.white, // Already correctly set for surface
        onPrimary: Colors.white,
        onSurface: Colors.black,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _secondaryColor,
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _secondaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primaryColor, width: 2),
        ),
        labelStyle: TextStyle(color: _primaryColor),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _secondaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
