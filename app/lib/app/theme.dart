import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData buildAppTheme() {
  final baseTextTheme = GoogleFonts.spaceGroteskTextTheme();

  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFFF7F8F2),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF245C4E),
      primary: const Color(0xFF245C4E),
      secondary: const Color(0xFFED8B00),
      surface: Colors.white,
    ),
    textTheme: baseTextTheme.copyWith(
      displayLarge: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700),
      headlineMedium: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700),
      titleLarge: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600),
      bodyLarge: GoogleFonts.manrope(),
      bodyMedium: GoogleFonts.manrope(),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: Color(0xFF245C4E), width: 1.5),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    cardTheme: const CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
      ),
      margin: EdgeInsets.zero,
    ),
  );
}
