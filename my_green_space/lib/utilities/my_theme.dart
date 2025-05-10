import 'package:flutter/material.dart';

final ThemeData myTheme = ThemeData(
  useMaterial3: false, 

  // Main colors of my theme.
  colorScheme: ColorScheme(
    brightness: Brightness.light,

    primary: Colors.green.shade600,
    onPrimary: Colors.white,

    secondary: Colors.brown.shade600,
    onSecondary: Colors.white,

    surface: Colors.brown.shade50,
    onSurface: Colors.green.shade900,

    error: Colors.red.shade700,
    onError: Colors.white,
  ),
);
