import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  THEME — "Catch Me If You Can"
//
//  Inspired by the film's iconic visual identity:
//  · Saul Bass–style opening title sequence
//  · Pan Am midnight navy + cerulean blue
//  · Warm amber & gold — silk ties, forged cheques, runway lights
//  · Cream ivory typography on deep dark surfaces
//  · 1960s mod elegance: confident, slick, never loud
// ─────────────────────────────────────────────────────────────────────────────

// ── Raw color tokens ──────────────────────────────────────────────────────────
class _C {
  // Backgrounds
  static const midnight   = Color(0xFF0D1B2A); // deepest background
  static const navy       = Color(0xFF1A2E44); // card / sheet surface
  static const navyDeep   = Color(0xFF142438); // elevated surface variant

  // Brand
  static const panAmBlue  = Color(0xFF1E6FA8); // primary — Pan Am cerulean
  static const amber      = Color(0xFFF4A228); // accent / CTA — golden amber
  static const gold       = Color(0xFFE8C874); // highlight / secondary accent

  // Typography
  static const cream      = Color(0xFFF5ECD7); // primary text on dark
  static const mutedBlue  = Color(0xFF8BA3B8); // secondary / hint text
  static const outline    = Color(0xFF3A5C7A); // borders, dividers

  // Attendance semantic — muted to match the film's restrained palette
  static const safe       = Color(0xFF2E7D4F); // ≥ 75%  — deep confident green
  static const borderline = Color(0xFFC47A1E); // 60–74% — warm amber-brown
  static const danger     = Color(0xFFB03030); // < 60%  — deep crimson
}

// ── Attendance color helper ───────────────────────────────────────────────────
class AttendanceColors {
  static const Color safe       = _C.safe;
  static const Color borderline = _C.borderline;
  static const Color danger     = _C.danger;

  static Color forPercentage(double percent) {
    if (percent >= 75) return safe;
    if (percent >= 60) return borderline;
    return danger;
  }
}

// ── Theme ─────────────────────────────────────────────────────────────────────
final ThemeData proxyTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,

  colorScheme: const ColorScheme(
    brightness: Brightness.dark,

    // Primary — Pan Am blue
    primary:              _C.panAmBlue,
    onPrimary:            _C.cream,
    primaryContainer:     Color(0xFF0F3D5C),
    onPrimaryContainer:   _C.cream,

    // Secondary — amber / gold
    secondary:            _C.amber,
    onSecondary:          _C.midnight,
    secondaryContainer:   Color(0xFF3D2A08),
    onSecondaryContainer: _C.gold,

    // Tertiary — gold highlight
    tertiary:             _C.gold,
    onTertiary:           _C.midnight,
    tertiaryContainer:    Color(0xFF3D3008),
    onTertiaryContainer:  _C.gold,

    // Surface
    surface:              _C.navy,
    onSurface:            _C.cream,
    surfaceContainerHighest: _C.navyDeep,
    surfaceContainerHigh:    Color(0xFF1E3650),
    surfaceContainer:        _C.navy,
    surfaceContainerLow:     _C.midnight,
    surfaceContainerLowest:  _C.midnight,
    surfaceTint:             _C.panAmBlue,

    // Background
    // ignore: deprecated_member_use
    background:           _C.midnight,
    // ignore: deprecated_member_use
    onBackground:         _C.cream,

    // Inverse
    inverseSurface:       _C.cream,
    onInverseSurface:     _C.midnight,
    inversePrimary:       _C.panAmBlue,

    // Semantic
    error:                Color(0xFFCF6679),
    onError:              _C.midnight,
    errorContainer:       Color(0xFF4A0010),
    onErrorContainer:     Color(0xFFFFB3C1),

    // Outline
    outline:              _C.outline,
    outlineVariant:       Color(0xFF243D52),
    shadow:               Color(0xFF000000),
    scrim:                Color(0xFF000000),
  ),

  scaffoldBackgroundColor: _C.midnight,

  // ── AppBar ──────────────────────────────────────────────────────────────────
  appBarTheme: const AppBarTheme(
    centerTitle: true,
    backgroundColor: _C.navy,
    foregroundColor: _C.cream,
    elevation: 0,
    scrolledUnderElevation: 3.0,
    titleTextStyle: TextStyle(
      fontFamily: 'serif',             // swap for your chosen retro serif
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: _C.cream,
      letterSpacing: 1.2,
    ),
  ),

  // ── Cards ───────────────────────────────────────────────────────────────────
  cardTheme: CardThemeData(
    color: _C.navy,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: _C.outline, width: 0.5),
    ),
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  ),

  // ── FAB — amber, punchy ──────────────────────────────────────────────────────
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: _C.amber,
    foregroundColor: _C.midnight,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
  ),

  // ── Elevated button — Pan Am blue ────────────────────────────────────────────
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _C.panAmBlue,
      foregroundColor: _C.cream,
      elevation: 0,
      textStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    ),
  ),

  // ── Outlined button — amber border ──────────────────────────────────────────
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: _C.amber,
      side: const BorderSide(color: _C.amber, width: 1.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    ),
  ),

  // ── Text button ──────────────────────────────────────────────────────────────
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: _C.amber,
      textStyle: const TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.4),
    ),
  ),

  // ── Input fields ─────────────────────────────────────────────────────────────
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: _C.navyDeep,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: _C.outline),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: _C.outline, width: 0.8),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: _C.amber, width: 1.8),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFB03030), width: 1.2),
    ),
    labelStyle: const TextStyle(color: _C.mutedBlue),
    hintStyle: const TextStyle(color: _C.mutedBlue),
    prefixIconColor: _C.mutedBlue,
    suffixIconColor: _C.mutedBlue,
  ),

  // ── Bottom navigation ────────────────────────────────────────────────────────
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: _C.navy,
    selectedItemColor: _C.amber,
    unselectedItemColor: _C.mutedBlue,
    showUnselectedLabels: true,
    elevation: 0,
    type: BottomNavigationBarType.fixed,
  ),

  // ── NavigationBar (M3) ───────────────────────────────────────────────────────
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: _C.navy,
    indicatorColor: const Color(0xFF0F3D5C),
    iconTheme: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const IconThemeData(color: _C.amber);
      }
      return const IconThemeData(color: _C.mutedBlue);
    }),
    labelTextStyle: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const TextStyle(color: _C.amber, fontWeight: FontWeight.w600, fontSize: 12);
      }
      return const TextStyle(color: _C.mutedBlue, fontSize: 12);
    }),
  ),

  // ── Divider ──────────────────────────────────────────────────────────────────
  dividerTheme: const DividerThemeData(
    color: _C.outline,
    thickness: 0.5,
    space: 1,
  ),

  // ── Chip ─────────────────────────────────────────────────────────────────────
  chipTheme: ChipThemeData(
    backgroundColor: _C.navyDeep,
    selectedColor: const Color(0xFF0F3D5C),
    labelStyle: const TextStyle(color: _C.cream, fontSize: 13),
    side: const BorderSide(color: _C.outline, width: 0.5),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  ),

  // ── Switch & Checkbox ────────────────────────────────────────────────────────
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      return states.contains(WidgetState.selected) ? _C.amber : _C.mutedBlue;
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      return states.contains(WidgetState.selected)
          ? const Color(0xFF3D2A08)
          : const Color(0xFF243D52);
    }),
  ),
  checkboxTheme: CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith((states) {
      return states.contains(WidgetState.selected) ? _C.panAmBlue : Colors.transparent;
    }),
    checkColor: WidgetStateProperty.all(_C.cream),
    side: const BorderSide(color: _C.outline, width: 1.2),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
  ),

  // ── SnackBar ─────────────────────────────────────────────────────────────────
  snackBarTheme: SnackBarThemeData(
    backgroundColor: _C.navy,
    contentTextStyle: const TextStyle(color: _C.cream, fontSize: 14),
    actionTextColor: _C.amber,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
      side: const BorderSide(color: _C.outline, width: 0.5),
    ),
    behavior: SnackBarBehavior.floating,
    elevation: 0,
  ),

  // ── Progress indicator ───────────────────────────────────────────────────────
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: _C.amber,
    circularTrackColor: Color(0xFF243D52),
    linearTrackColor: Color(0xFF243D52),
  ),

  // ── Typography ───────────────────────────────────────────────────────────────
  textTheme: const TextTheme(
    // Display — large headings, dashboard hero numbers
    displayLarge:  TextStyle(fontSize: 57, fontWeight: FontWeight.w300, color: _C.cream, letterSpacing: -0.5),
    displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.w300, color: _C.cream),
    displaySmall:  TextStyle(fontSize: 36, fontWeight: FontWeight.w400, color: _C.cream),

    // Headline — screen titles, section headers
    headlineLarge:  TextStyle(fontSize: 32, fontWeight: FontWeight.w600, color: _C.cream, letterSpacing: 0.5),
    headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: _C.cream),
    headlineSmall:  TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: _C.cream),

    // Title — card titles, list headers
    titleLarge:  TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: _C.cream, letterSpacing: 0.3),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: _C.cream),
    titleSmall:  TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _C.cream, letterSpacing: 0.2),

    // Body — subject names, descriptions
    bodyLarge:   TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: _C.cream, height: 1.6),
    bodyMedium:  TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: _C.mutedBlue, height: 1.5),
    bodySmall:   TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: _C.mutedBlue),

    // Label — buttons, chips, stats
    labelLarge:  TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _C.cream, letterSpacing: 0.6),
    labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _C.mutedBlue, letterSpacing: 0.4),
    labelSmall:  TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: _C.mutedBlue, letterSpacing: 0.5),
  ),

  iconTheme: const IconThemeData(color: _C.mutedBlue, size: 24),
  primaryIconTheme: const IconThemeData(color: _C.amber, size: 24),
);