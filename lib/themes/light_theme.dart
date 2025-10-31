import 'package:flutter/material.dart';

class LightTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Primary colors from Figma
      primaryColor: const Color(0xFF9810FA),
      scaffoldBackgroundColor: const Color(0xFFF9FAFB),

      // Color scheme
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF9810FA),
        secondary: Color(0xFF8200DB),
        tertiary: Color(0xFF00D9FF),
        surface: Color(0xFFFFFFFF),
        error: Color(0xFFE7000B),
        onPrimary: Color(0xFFFFFFFF),
        onSecondary: Color(0xFFFFFFFF),
        onSurface: Color(0xFF0A0A0A),
        onError: Color(0xFFFFFFFF),
        outline: Color(0xFFE5E7EB),
        shadow: Color(0x1A000000),
      ),

      // AppBar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF9810FA),
        foregroundColor: Color(0xFFFFFFFF),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Arimo',
          fontSize: 24,
          fontWeight: FontWeight.w400,
          color: Color(0xFFFFFFFF),
        ),
      ),

      // Card theme
      cardTheme: CardThemeData(
        color: const Color(0xFFFFFFFF),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0x1A000000), width: 1),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF3F3F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF9810FA), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE7000B), width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF9810FA),
          foregroundColor: const Color(0xFFFFFFFF),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontFamily: 'Arimo',
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF9810FA),
          textStyle: const TextStyle(
            fontFamily: 'Arimo',
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),

      // Outlined button theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF0A0A0A),
          side: const BorderSide(color: Color(0x1A000000), width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontFamily: 'Arimo',
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),

      // Text theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Arimo',
          fontSize: 24,
          fontWeight: FontWeight.w400,
          color: Color(0xFF0A0A0A),
        ),
        displayMedium: TextStyle(
          fontFamily: 'Arimo',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Color(0xFF0A0A0A),
        ),
        titleLarge: TextStyle(
          fontFamily: 'Arimo',
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: Color(0xFF0A0A0A),
        ),
        titleMedium: TextStyle(
          fontFamily: 'Arimo',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Color(0xFF0A0A0A),
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Arimo',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Color(0xFF717182),
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Arimo',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0xFF717182),
        ),
        labelLarge: TextStyle(
          fontFamily: 'Arimo',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0xFF0A0A0A),
        ),
        labelMedium: TextStyle(
          fontFamily: 'Arimo',
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Color(0xFF6A7282),
        ),
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFFFFFFFF),
        selectedItemColor: Color(0xFF155DFC),
        unselectedItemColor: Color(0xFF6A7282),
        selectedLabelStyle: TextStyle(
          fontFamily: 'Arimo',
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Arimo',
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Floating action button theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF00D9FF),
        foregroundColor: Color(0xFFFFFFFF),
        elevation: 6,
      ),

      // Progress indicator theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Color(0xFF9810FA),
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE5E7EB),
        thickness: 1,
      ),
    );
  }
}
