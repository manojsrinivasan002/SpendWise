import 'package:flutter/material.dart';

class AppTheme {
  // global typography

  // static const TextTheme appTextTheme = TextTheme(
  //   headlineLarge: TextStyle(
  //     fontSize: 32,
  //     fontWeight: FontWeight.bold,
  //   ), // For big Dashboard numbers
  //   titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600), // For AppBars and Card Titles
  //   bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500), // For Expense Titles
  //   bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal), // For Dates and Subtitles
  //   bodySmall: TextStyle(fontSize: 14, fontWeight: FontWeight.bold), // For Buttons
  // );

  // light mode

  static ThemeData lightMode = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      surface: Colors.grey.shade100,
      onSurface: Colors.black,
      inverseSurface: Colors.grey.shade200,
      primary: Colors.blue.shade700, // Brand color (Highlights, active buttons)
      onPrimary: Colors.white,
      secondary: Colors.white, // Card backgrounds
      onSecondary: Colors.black,
      inversePrimary: Colors.grey.shade500,
      error: Colors.red.shade700,
      onError: Colors.white,
    ),
  );

  static ThemeData darkMode = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      surface: const Color(0xFF121212), // Premium soft dark background
      onSurface: Colors.white,
      inverseSurface: const Color(0xFF2C2C2E), // For subtle highlights/borders
      primary: Colors.blue.shade400, // Lighter blue for better contrast
      onPrimary: Colors.black, // Black text on blue buttons looks incredibly sharp
      secondary: const Color(0xFF1E1E1E), // Elevated card backgrounds (Instagram style)
      onSecondary: Colors.white,
      inversePrimary: Colors.grey.shade400, // Muted text and inactive icons
      error: Colors.red.shade400, // Softer red so it doesn't strain the eyes
      onError: Colors.black,
    ),
  );

  //   // global component design
  //   scaffoldBackgroundColor: Colors.grey.shade100,
  //   appBarTheme: AppBarTheme(
  //     backgroundColor: Colors.grey.shade100,
  //     elevation: 0,
  //     centerTitle: true,
  //     foregroundColor: Colors.black, // Makes back buttons and titles black
  //   ),

  //   inputDecorationTheme: InputDecorationTheme(
  //     filled: true,
  //     fillColor: Colors.white,
  //     hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16),
  //     border: OutlineInputBorder(
  //       borderRadius: BorderRadius.circular(16), // Smooth modern rounded corners
  //       borderSide: BorderSide(color: Colors.grey.shade200), // Removes the harsh black line
  //     ),
  //     focusedBorder: OutlineInputBorder(
  //       borderRadius: BorderRadius.circular(16),
  //       borderSide: BorderSide(color: Colors.grey.shade200),
  //     ),
  //     contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  //   ),
  // );

  // PREMIUM OLED DARK MODE
  // static ThemeData darkMode = ThemeData(
  //   useMaterial3: true,
  //   brightness: Brightness.dark,
  //   textTheme: appTextTheme.apply(
  //     bodyColor: const Color(0xFFF2F2F2), // Soft white to prevent eye strain
  //     displayColor: const Color(0xFFF2F2F2),
  //   ),
  //   colorScheme: const ColorScheme.dark(
  //     surface: Color(0xFF000000), // Pure OLED Black
  //     onSurface: Color(0xFFF2F2F2),
  //     primary: Color(0xFFECEFF4), // Stark contrast for active elements
  //     onPrimary: Color(0xFF000000), // Black text on white chips
  //     secondary: Color(0xFF141414), // Elevated card color
  //     error: Color(0xFFFF4C4C), // Neon glowing red
  //     inversePrimary: Color(0xFF262626), // Subtle borders and dividers
  //   ),

  //   scaffoldBackgroundColor: const Color(0xFF000000), // Pure OLED Black

  //   appBarTheme: const AppBarTheme(
  //     backgroundColor: Colors.transparent,
  //     elevation: 0,
  //     centerTitle: true,
  //     foregroundColor: Color(0xFFF2F2F2),
  //   ),

  //   inputDecorationTheme: InputDecorationTheme(
  //     filled: true,
  //     fillColor: const Color(0xFF141414), // Matches the cards
  //     hintStyle: const TextStyle(color: Color(0xFF666666), fontSize: 16),
  //     border: OutlineInputBorder(
  //       borderRadius: BorderRadius.circular(30),
  //       borderSide: const BorderSide(color: Color(0xFF262626), width: 1),
  //     ),
  //     enabledBorder: OutlineInputBorder(
  //       borderRadius: BorderRadius.circular(30),
  //       borderSide: const BorderSide(color: Color(0xFF262626), width: 1),
  //     ),
  //     focusedBorder: OutlineInputBorder(
  //       borderRadius: BorderRadius.circular(30),
  //       // A glowing white border when they tap to type
  //       borderSide: const BorderSide(color: Color(0xFFECEFF4), width: 2),
  //     ),
  //     contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
  //   ),
  // );
}
