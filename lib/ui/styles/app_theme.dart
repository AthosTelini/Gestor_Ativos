import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color darkBlue = Color(0xFF0F2027);
  static const Color royalBlue = Color(0xFF203A43);
  static const Color mintNeon = Color(0xFF00F260);
  static const Color cyanNeon = Color(0xFF0575E6);
  static const Color offWhite = Color(0xFFF4F7F6);
  static const Color glassWhite = Color(0x26FFFFFF);

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkBlue, royalBlue],
  );

  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x4DFFFFFF),
      Color(0x1AFFFFFF),
    ],
  );

  static final ThemeData theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: offWhite,
    primaryColor: darkBlue,
    textTheme: GoogleFonts.outfitTextTheme().apply(
      bodyColor: darkBlue,
      displayColor: darkBlue,
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: royalBlue,
      primary: darkBlue,
      secondary: cyanNeon,
    ),
  );
}