import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Style definitions for light theme.
ThemeData lightTheme = ThemeData.light(
  useMaterial3: true,
).copyWith(
  cardColor: const Color(0xffcacbcc),
  dividerColor: Colors.black,
  colorScheme: const ColorScheme.light(
    background: Colors.white,
    primary: Color(0xff009fe3),
  ),
  textTheme: GoogleFonts.montserratTextTheme().apply(
    bodyColor: Colors.black,
    displayColor: Colors.black,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      textStyle: MaterialStateProperty.all<TextStyle>(
        const TextStyle(fontSize: 20.0),
      ),
      backgroundColor: MaterialStateProperty.all<Color>(
        const Color(0xff009fe3),
      ),
      foregroundColor: MaterialStateProperty.all<Color>(
        Colors.white,
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: MaterialStateProperty.all<Color>(
        Colors.black,
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    labelStyle: const TextStyle(color: Colors.black, fontSize: 20.0),
    filled: true,
    fillColor: Colors.white,
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
        color: Color(0xffcacbcc),
      ),
    ),
  ),
);
