import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Style definitions for dark theme.
ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  cardColor: const Color(0xff2a313d),
  dividerColor: Colors.white,
  colorScheme: const ColorScheme.dark(
    background: Color(0xff191D24),
    primary: Color(0xFF009fe3),
  ),
  textTheme: GoogleFonts.montserratTextTheme().apply(
    bodyColor: Colors.white,
    displayColor: Colors.white,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      textStyle: MaterialStateProperty.all<TextStyle>(
        const TextStyle(fontSize: 20.0),
      ),
      backgroundColor: MaterialStateProperty.all<Color>(
        const Color(0xFF009fe3),
      ),
      foregroundColor: MaterialStateProperty.all<Color>(
        Colors.white,
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: MaterialStateProperty.all<Color>(
        Colors.white,
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    labelStyle: const TextStyle(color: Colors.white, fontSize: 20.0),
    filled: true,
    fillColor: const Color(0xff191D24),
    focusedBorder: UnderlineInputBorder(
      borderRadius: BorderRadius.circular(0.0),
      borderSide: const BorderSide(
        width: 2,
        color: Color(0xff009fe3),
      ),
    ),
    enabledBorder: UnderlineInputBorder(
      borderRadius: BorderRadius.circular(0),
      borderSide: const BorderSide(
        width: 2,
        color: Color(0xff2a313d),
      ),
    ),
  ),
);
