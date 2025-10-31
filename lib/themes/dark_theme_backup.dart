import 'package:flutter/material.dart';

class DarkTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Primary colors from Figma dark mode
      primaryColor: const Color(0xFF00D9FF), // Cyan
      scaffoldBackgroundColor: const Color(
        0xFF1A1625,
      ), // Dark purple background
      // Color scheme
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF00D9FF), // Cyan - main accent
        secondary: Color(0xFF7B3FF2), // Purple - reading
        tertiary: Color(0xFFB967FF), // Light purple - completed
        surface: Color(0xFF231832), // Card background
        error: Color(0xFFFB2C36), // Red error
        onPrimary: Color(0xFF0D0711), // Text on cyan
        onSecondary: Color(0xFFFFFFFF), // Text on purple
        onSurface: Color(0xFFFFFFFF), // Text on cards
        onError: Color(0xFFFFFFFF), // Text on error
        outline: Color(0x3300D9FF), // Cyan 20% for borders
        shadow: Color(0x4000D9FF), // Cyan shadow
      ),

      // AppBar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1A1625),
        foregroundColor: Color(0xFF00D9FF), // Cyan text
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Arimo',
          fontSize: 24,
          fontWeight: FontWeight.w400,
          color: Color(0xFF00D9FF), // Cyan
        ),
      ),

      // Card theme
      cardTheme: CardThemeData(
        color: const Color(0xFF231832), // Dark purple card
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(
            color: Color(0x3300D9FF),
            width: 1.162,
          ), // Cyan 20% border
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF231832), // Dark purple
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Color(0x3300D9FF),
            width: 1.162,
          ), // Cyan 20%
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0x3300D9FF), width: 1.162),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Color(0xFF00D9FF),
            width: 2,
          ), // Cyan
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFFB2C36), width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        hintStyle: const TextStyle(color: Color(0x9900D9FF)), // Cyan 60%
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00D9FF), // Cyan
          foregroundColor: const Color(0xFF0D0711), // Dark text
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
          foregroundColor: const Color(0xFF00D9FF), // Cyan
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
          foregroundColor: const Color(0xFF00D9FF), // Cyan text
          backgroundColor: const Color(0xFF1A0F2E), // Very dark purple
          side: const BorderSide(
            color: Color(0x6600D9FF),
            width: 1.162,
          ), // Cyan 40%
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
          color: Color(0xFF00D9FF), // Cyan for headers
        ),
        displayMedium: TextStyle(
          fontFamily: 'Arimo',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Color(0xFF00D9FF), // Cyan for headers
        ),
        titleLarge: TextStyle(
          fontFamily: 'Arimo',
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: Color(0xFFFFFFFF), // White
        ),
        titleMedium: TextStyle(
          fontFamily: 'Arimo',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Color(0xFF00D9FF), // Cyan
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Arimo',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Color(0xFFFFFFFF), // White
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Arimo',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0x9900D9FF), // Cyan 60%
        ),
        labelLarge: TextStyle(
          fontFamily: 'Arimo',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0xFF00D9FF), // Cyan
        ),
        labelMedium: TextStyle(
          fontFamily: 'Arimo',
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Color(0xFF99A1AF), // Gray
        ),
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1A0F2E), // Very dark purple
        selectedItemColor: Color(0xFF00D9FF), // Cyan when selected
        unselectedItemColor: Color(0xFF99A1AF), // Gray when unselected
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
        elevation: 0,
      ),

      // Floating action button theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF00D9FF), // Cyan
        foregroundColor: Color(0xFF0D0711), // Dark text
        elevation: 6,
      ),

      // Progress indicator theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Color(0xFF00D9FF), // Cyan
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: Color(0x3300D9FF), // Cyan 20%
        thickness: 1.162,
      ),
    );
  }
}
