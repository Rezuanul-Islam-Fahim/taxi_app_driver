import 'package:flutter/material.dart';

ThemeData get theme {
  return ThemeData(
    primarySwatch: Colors.blueGrey,
    colorScheme: ThemeData().colorScheme.copyWith(
          secondary: Colors.blueGrey,
        ),
    scaffoldBackgroundColor: Colors.white,
    textTheme: ThemeData().textTheme.copyWith(
          bodyText1: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
          bodyText2: const TextStyle(
            fontSize: 15,
            color: Colors.black87,
          ),
          headline1: const TextStyle(
            fontSize: 40,
            color: Colors.black,
            fontWeight: FontWeight.w800,
          ),
        ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueGrey,
        elevation: 0,
        enableFeedback: true,
        shadowColor: Colors.transparent,
      ),
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}
