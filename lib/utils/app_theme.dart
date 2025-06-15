import 'package:flutter/material.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    primaryColor: const Color(0xFF6BBAAD),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF6BBAAD),
      foregroundColor: Colors.black,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    canvasColor: Colors.white,
    scaffoldBackgroundColor: Colors.grey[50],
  );

  // add darkTheme.
  static final darkTheme = ThemeData();
}

const horizontalPadding = 24.0;
