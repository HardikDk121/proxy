import 'package:flutter/material.dart';

// The official "Proxy" Desaturated Pastel Theme
final ThemeData proxyTheme = ThemeData(
  brightness: Brightness.dark, // Forces dark mode text behaviors
  
  // 1. Backgrounds
  scaffoldBackgroundColor: const Color(0xFF121212), // Deep Charcoal
  cardColor: const Color(0xFF1E1E1E),               // Dark Surface
  
  // 2. The Color Palette from your link
  colorScheme: const ColorScheme.dark(
    primary: Colors.green,    // The Sage Green (Safe)
    error: Colors.red,      // The Brick Red (Danger)
    surface: Color(0xFF1E1E1E),
  ),
  
  // 3. Text Colors
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Color(0xFFE0E0E0), fontSize: 18, fontWeight: FontWeight.bold),
    bodyMedium: TextStyle(color: Color(0xFFA0A0A0), fontSize: 14), // Slightly dimmer for subtitles
  ),
  
  // 4. App Bar Styling (Clean, flat look)
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF121212),
    elevation: 0, 
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: Color(0xFFE0E0E0),
      fontSize: 22,
      fontWeight: FontWeight.w800,
      letterSpacing: 2.0, 
    ),
  ),
);