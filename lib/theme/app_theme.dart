import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const primaryColor = Color(0xFF6C63FF); // Modern purple
  static const secondaryColor = Color(0xFF03DAC6);

  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      primary: primaryColor,
      secondary: secondaryColor,
      surface: const Color(0xFFF8F9FA),
      onSurface: const Color(0xFF212529),
    ),
    scaffoldBackgroundColor: const Color(0xFFF8F9FA),
    cardTheme: CardThemeData(
      color: const Color.fromARGB(75, 170, 173, 176),
      surfaceTintColor: Colors.transparent,
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: const Color(0xFF212529).withValues(alpha: 0.06),
          width: 1,
        ),
      ),
    ),
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme).apply(
      bodyColor: const Color(0xFF212529),
      displayColor: const Color(0xFF212529),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Color(0xFF212529)),
      titleTextStyle: TextStyle(
        color: Color(0xFF212529),
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    dividerTheme: const DividerThemeData(color: Colors.black12),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
    ),
    iconTheme: const IconThemeData(color: Color(0xFF212529)),
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
      primary: primaryColor,
      secondary: secondaryColor,
      surface: const Color(0xFF1E1E2C),
      onSurface: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFF12121A),
    cardTheme: CardThemeData(
      color: const Color.fromARGB(255, 39, 39, 61),
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    textTheme: GoogleFonts.poppinsTextTheme(
      ThemeData.dark().textTheme,
    ).apply(bodyColor: Colors.white, displayColor: Colors.white),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    dividerTheme: const DividerThemeData(color: Colors.white12),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
    ),
    iconTheme: const IconThemeData(color: Colors.white),
  );
}
