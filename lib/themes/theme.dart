import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  PROXY — AppTheme
//
//  Provides two production-ready Material 3 themes:
//    • AppTheme.darkTheme  — OLED-black base, Electric Indigo + Emerald accents
//    • AppTheme.lightTheme — Crisp-white base, same Indigo + Emerald accents
//
//  Usage in MaterialApp:
//    theme:      AppTheme.lightTheme,
//    darkTheme:  AppTheme.darkTheme,
//    themeMode:  ThemeMode.system,       // follows OS preference
//
//  Backward-compat alias:
//    proxyTheme  →  AppTheme.darkTheme   (no widget changes needed)
// ─────────────────────────────────────────────────────────────────────────────

// ── Raw color palette ────────────────────────────────────────────────────────

/// Shared accent tokens — identical in both themes.
abstract final class _Accent {
  // Primary — Electric Indigo
  static const indigo       = Color(0xFF6C63FF);
  static const indigoLight  = Color(0xFF9B94FF); // lighter tint
  static const indigoDark   = Color(0xFF1A1640); // dark container (dark theme)
  static const indigoTint   = Color(0xFFEDECFF); // light container (light theme)
  static const onIndigo     = Color(0xFFFFFFFF);

  // Secondary — Emerald Green
  static const emerald      = Color(0xFF2DD4A8);
  static const emeraldLight = Color(0xFF6EECD0);
  static const emeraldDark  = Color(0xFF0D2E26); // dark container (dark theme)
  static const emeraldTint  = Color(0xFFDFFAF4); // light container (light theme)
  static const onEmeraldDk  = Color(0xFF0A0A0F); // text on emerald — dark theme
  static const onEmeraldLt  = Color(0xFF003328); // text on emerald — light theme

  // Semantic
  static const safe         = Color(0xFF2DD4A8); // ≥ 75%
  static const borderline   = Color(0xFFFFB020); // 60–74%
  static const danger       = Color(0xFFFF5C5C); // < 60%
}

/// Dark-theme background/surface tokens.
abstract final class _Dark {
  static const bg            = Color(0xFF0A0A0F); // scaffold (near-OLED)
  static const surface       = Color(0xFF14141F); // cards, sheets
  static const surfaceHigh   = Color(0xFF1C1C2A); // elevated containers
  static const surfaceHigher = Color(0xFF242436); // modals, drawers
  static const textPrimary   = Color(0xFFE8E8F0);
  static const textSecondary = Color(0xFF9393A8);
  static const outline       = Color(0xFF2E2E40);
  static const outlineLight  = Color(0xFF3A3A52);
}

/// Light-theme background/surface tokens.
abstract final class _Light {
  static const bg            = Color(0xFFF5F5FA); // scaffold — cool-white
  static const surface       = Color(0xFFFFFFFF); // cards, sheets
  static const surfaceHigh   = Color(0xFFF0F0F8); // elevated containers
  static const surfaceHigher = Color(0xFFE8E8F5); // modals, drawers
  static const textPrimary   = Color(0xFF1A1A2E); // near-black slate
  static const textSecondary = Color(0xFF5C5C78); // cool gray
  static const outline       = Color(0xFFDDDDEE); // subtle border
  static const outlineLight  = Color(0xFFEBEBF5); // even softer separator
}

// ── Shared attendance-color helper ───────────────────────────────────────────
/// Use this to color-code attendance widgets without hardcoding hex values.
class AttendanceColors {
  const AttendanceColors._();

  static const Color safe       = _Accent.safe;
  static const Color borderline = _Accent.borderline;
  static const Color danger     = _Accent.danger;

  static Color forPercentage(double percent) {
    if (percent >= 75) return safe;
    if (percent >= 60) return borderline;
    return danger;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  AppTheme
// ─────────────────────────────────────────────────────────────────────────────
abstract final class AppTheme {
  // ── Dark Theme ─────────────────────────────────────────────────────────────
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    // ── Color scheme ──────────────────────────────────────────────────────
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,

      // Primary — Electric Indigo
      primary:              _Accent.indigo,
      onPrimary:            _Accent.onIndigo,
      primaryContainer:     _Accent.indigoDark,
      onPrimaryContainer:   _Accent.indigoLight,

      // Secondary — Emerald Green
      secondary:            _Accent.emerald,
      onSecondary:          _Accent.onEmeraldDk,
      secondaryContainer:   _Accent.emeraldDark,
      onSecondaryContainer: _Accent.emeraldLight,

      // Tertiary — subtle indigo tint
      tertiary:             _Accent.indigoLight,
      onTertiary:           _Dark.bg,
      tertiaryContainer:    _Accent.indigoDark,
      onTertiaryContainer:  _Accent.indigoLight,

      // Surfaces
      surface:                   _Dark.surface,
      onSurface:                 _Dark.textPrimary,
      onSurfaceVariant:          _Dark.textSecondary,
      surfaceContainerHighest:   _Dark.surfaceHigher,
      surfaceContainerHigh:      _Dark.surfaceHigh,
      surfaceContainer:          _Dark.surface,
      surfaceContainerLow:       _Dark.bg,
      surfaceContainerLowest:    _Dark.bg,
      surfaceTint:               _Accent.indigo,

      // Inverse
      inverseSurface:       _Dark.textPrimary,
      onInverseSurface:     _Dark.bg,
      inversePrimary:       _Accent.indigoDark,

      // Error
      error:                _Accent.danger,
      onError:              _Dark.bg,
      errorContainer:       Color(0xFF3D0D0D),
      onErrorContainer:     Color(0xFFFFB3B3),

      // Outline
      outline:              _Dark.outline,
      outlineVariant:       _Dark.outlineLight,
      shadow:               Color(0xFF000000),
      scrim:                Color(0xFF000000),
    ),

    scaffoldBackgroundColor: _Dark.bg,

    // ── AppBar ────────────────────────────────────────────────────────────
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      backgroundColor: _Dark.surface,
      foregroundColor: _Dark.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 2.0,
      surfaceTintColor: _Accent.indigo,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: _Dark.textPrimary,
        letterSpacing: 0.5,
      ),
    ),

    // ── Card ──────────────────────────────────────────────────────────────
    cardTheme: CardThemeData(
      color: _Dark.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: _Dark.outline, width: 0.5),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // ── FAB ───────────────────────────────────────────────────────────────
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _Accent.emerald,
      foregroundColor: _Accent.onEmeraldDk,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),

    // ── Elevated button ───────────────────────────────────────────────────
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _Accent.indigo,
        foregroundColor: _Accent.onIndigo,
        elevation: 0,
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),

    // ── Outlined button ───────────────────────────────────────────────────
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _Accent.emerald,
        side: const BorderSide(color: _Accent.emerald, width: 1.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),

    // ── Text button ───────────────────────────────────────────────────────
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _Accent.indigo,
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    ),

    // ── Input fields ──────────────────────────────────────────────────────
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _Dark.surfaceHigh,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _Dark.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _Dark.outline, width: 0.8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _Accent.indigo, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _Accent.danger, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _Accent.danger, width: 1.8),
      ),
      labelStyle: const TextStyle(color: _Dark.textSecondary),
      hintStyle: const TextStyle(color: _Dark.textSecondary),
      prefixIconColor: _Dark.textSecondary,
      suffixIconColor: _Dark.textSecondary,
    ),

    // ── Bottom navigation bar ─────────────────────────────────────────────
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: _Dark.surface,
      selectedItemColor: _Accent.indigo,
      unselectedItemColor: _Dark.textSecondary,
      showUnselectedLabels: true,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),

    // ── NavigationBar (M3) ────────────────────────────────────────────────
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: _Dark.surface,
      indicatorColor: _Accent.indigoDark,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: _Accent.indigo);
        }
        return const IconThemeData(color: _Dark.textSecondary);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            color: _Accent.indigo,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          );
        }
        return const TextStyle(color: _Dark.textSecondary, fontSize: 12);
      }),
    ),

    // ── Divider ───────────────────────────────────────────────────────────
    dividerTheme: const DividerThemeData(
      color: _Dark.outline,
      thickness: 0.5,
      space: 1,
    ),

    // ── Chip ──────────────────────────────────────────────────────────────
    chipTheme: ChipThemeData(
      backgroundColor: _Dark.surfaceHigh,
      selectedColor: _Accent.indigoDark,
      labelStyle: const TextStyle(color: _Dark.textPrimary, fontSize: 13),
      side: const BorderSide(color: _Dark.outline, width: 0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    ),

    // ── Switch & Checkbox ─────────────────────────────────────────────────
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) => states
              .contains(WidgetState.selected)
          ? _Accent.emerald
          : _Dark.textSecondary),
      trackColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected)
              ? _Accent.emeraldDark
              : _Dark.outline),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected)
              ? _Accent.indigo
              : Colors.transparent),
      checkColor: WidgetStateProperty.all(_Accent.onIndigo),
      side: const BorderSide(color: _Dark.outline, width: 1.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),

    // ── SnackBar ──────────────────────────────────────────────────────────
    snackBarTheme: SnackBarThemeData(
      backgroundColor: _Dark.surfaceHigh,
      contentTextStyle:
          const TextStyle(color: _Dark.textPrimary, fontSize: 14),
      actionTextColor: _Accent.emerald,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: _Dark.outline, width: 0.5),
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 0,
    ),

    // ── Progress indicator ────────────────────────────────────────────────
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: _Accent.indigo,
      circularTrackColor: _Dark.outline,
      linearTrackColor: _Dark.outline,
    ),

    // ── Dialog ────────────────────────────────────────────────────────────
    dialogTheme: DialogThemeData(
      backgroundColor: _Dark.surfaceHigh,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: _Dark.textPrimary,
      ),
      contentTextStyle: const TextStyle(
        fontSize: 14,
        color: _Dark.textSecondary,
        height: 1.5,
      ),
    ),

    // ── Bottom sheet ──────────────────────────────────────────────────────
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: _Dark.surfaceHigher,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      dragHandleColor: _Dark.outlineLight,
      dragHandleSize: Size(36, 4),
    ),

    // ── Typography ────────────────────────────────────────────────────────
    textTheme: const TextTheme(
      displayLarge:  TextStyle(fontSize: 57, fontWeight: FontWeight.w300, color: _Dark.textPrimary, letterSpacing: -0.5),
      displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.w300, color: _Dark.textPrimary),
      displaySmall:  TextStyle(fontSize: 36, fontWeight: FontWeight.w400, color: _Dark.textPrimary),

      headlineLarge:  TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: _Dark.textPrimary, letterSpacing: 0.3),
      headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: _Dark.textPrimary),
      headlineSmall:  TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: _Dark.textPrimary),

      titleLarge:  TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: _Dark.textPrimary, letterSpacing: 0.2),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _Dark.textPrimary),
      titleSmall:  TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _Dark.textPrimary, letterSpacing: 0.1),

      bodyLarge:   TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: _Dark.textPrimary, height: 1.6),
      bodyMedium:  TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: _Dark.textSecondary, height: 1.5),
      bodySmall:   TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: _Dark.textSecondary),

      labelLarge:  TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _Dark.textPrimary, letterSpacing: 0.4),
      labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _Dark.textSecondary, letterSpacing: 0.3),
      labelSmall:  TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: _Dark.textSecondary, letterSpacing: 0.4),
    ),

    iconTheme: const IconThemeData(color: _Dark.textSecondary, size: 24),
    primaryIconTheme: const IconThemeData(color: _Accent.indigo, size: 24),
  );

  // ── Light Theme ────────────────────────────────────────────────────────────
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // ── Color scheme ──────────────────────────────────────────────────────
    colorScheme: const ColorScheme(
      brightness: Brightness.light,

      // Primary — Electric Indigo
      primary:              _Accent.indigo,
      onPrimary:            _Accent.onIndigo,
      primaryContainer:     _Accent.indigoTint,
      onPrimaryContainer:   Color(0xFF2D1FA3), // dark indigo for contrast

      // Secondary — Emerald Green
      secondary:            _Accent.emerald,
      onSecondary:          _Accent.onEmeraldLt,
      secondaryContainer:   _Accent.emeraldTint,
      onSecondaryContainer: Color(0xFF00513E),

      // Tertiary — soft indigo accent
      tertiary:             _Accent.indigoLight,
      onTertiary:           _Accent.onIndigo,
      tertiaryContainer:    _Accent.indigoTint,
      onTertiaryContainer:  Color(0xFF2D1FA3),

      // Surfaces
      surface:                   _Light.surface,
      onSurface:                 _Light.textPrimary,
      onSurfaceVariant:          _Light.textSecondary,
      surfaceContainerHighest:   _Light.surfaceHigher,
      surfaceContainerHigh:      _Light.surfaceHigh,
      surfaceContainer:          _Light.surfaceHigh,
      surfaceContainerLow:       _Light.bg,
      surfaceContainerLowest:    _Light.surface,
      surfaceTint:               _Accent.indigo,

      // Inverse (dark surface for light-on-dark use)
      inverseSurface:       Color(0xFF1A1A2E),
      onInverseSurface:     Color(0xFFEEEEFA),
      inversePrimary:       _Accent.indigoLight,

      // Error
      error:                Color(0xFFD32F2F),
      onError:              Color(0xFFFFFFFF),
      errorContainer:       Color(0xFFFFDAD6),
      onErrorContainer:     Color(0xFF7B0000),

      // Outline
      outline:              _Light.outline,
      outlineVariant:       _Light.outlineLight,
      shadow:               Color(0xFF000000),
      scrim:                Color(0xFF000000),
    ),

    scaffoldBackgroundColor: _Light.bg,

    // ── AppBar ────────────────────────────────────────────────────────────
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      backgroundColor: _Light.surface,
      foregroundColor: _Light.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 1.0,
      surfaceTintColor: _Accent.indigo,
      shadowColor: Color(0x14000000),
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: _Light.textPrimary,
        letterSpacing: 0.5,
      ),
    ),

    // ── Card ──────────────────────────────────────────────────────────────
    cardTheme: CardThemeData(
      color: _Light.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: _Light.outline, width: 0.8),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // ── FAB ───────────────────────────────────────────────────────────────
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _Accent.emerald,
      foregroundColor: _Accent.onEmeraldLt,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),

    // ── Elevated button ───────────────────────────────────────────────────
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _Accent.indigo,
        foregroundColor: _Accent.onIndigo,
        elevation: 0,
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),

    // ── Outlined button ───────────────────────────────────────────────────
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _Accent.emerald,
        side: const BorderSide(color: _Accent.emerald, width: 1.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),

    // ── Text button ───────────────────────────────────────────────────────
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _Accent.indigo,
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    ),

    // ── Input fields ──────────────────────────────────────────────────────
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _Light.surfaceHigh,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _Light.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _Light.outline, width: 0.8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _Accent.indigo, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 1.8),
      ),
      labelStyle: const TextStyle(color: _Light.textSecondary),
      hintStyle: const TextStyle(color: _Light.textSecondary),
      prefixIconColor: _Light.textSecondary,
      suffixIconColor: _Light.textSecondary,
    ),

    // ── Bottom navigation bar ─────────────────────────────────────────────
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: _Light.surface,
      selectedItemColor: _Accent.indigo,
      unselectedItemColor: _Light.textSecondary,
      showUnselectedLabels: true,
      elevation: 2,
      type: BottomNavigationBarType.fixed,
    ),

    // ── NavigationBar (M3) ────────────────────────────────────────────────
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: _Light.surface,
      indicatorColor: _Accent.indigoTint,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: _Accent.indigo);
        }
        return const IconThemeData(color: _Light.textSecondary);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            color: _Accent.indigo,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          );
        }
        return const TextStyle(color: _Light.textSecondary, fontSize: 12);
      }),
    ),

    // ── Divider ───────────────────────────────────────────────────────────
    dividerTheme: const DividerThemeData(
      color: _Light.outline,
      thickness: 0.8,
      space: 1,
    ),

    // ── Chip ──────────────────────────────────────────────────────────────
    chipTheme: ChipThemeData(
      backgroundColor: _Light.surfaceHigh,
      selectedColor: _Accent.indigoTint,
      labelStyle: const TextStyle(color: _Light.textPrimary, fontSize: 13),
      side: const BorderSide(color: _Light.outline, width: 0.8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    ),

    // ── Switch & Checkbox ─────────────────────────────────────────────────
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected)
              ? _Accent.emerald
              : _Light.textSecondary),
      trackColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected)
              ? _Accent.emeraldTint
              : _Light.outline),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected)
              ? _Accent.indigo
              : Colors.transparent),
      checkColor: WidgetStateProperty.all(_Accent.onIndigo),
      side: const BorderSide(color: _Light.outline, width: 1.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),

    // ── SnackBar ──────────────────────────────────────────────────────────
    snackBarTheme: SnackBarThemeData(
      backgroundColor: _Light.textPrimary,       // dark snackbar on light bg
      contentTextStyle:
          const TextStyle(color: Color(0xFFEEEEFA), fontSize: 14),
      actionTextColor: _Accent.emeraldLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
      elevation: 4,
    ),

    // ── Progress indicator ────────────────────────────────────────────────
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: _Accent.indigo,
      circularTrackColor: _Light.outline,
      linearTrackColor: _Light.outline,
    ),

    // ── Dialog ────────────────────────────────────────────────────────────
    dialogTheme: DialogThemeData(
      backgroundColor: _Light.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: _Light.textPrimary,
      ),
      contentTextStyle: const TextStyle(
        fontSize: 14,
        color: _Light.textSecondary,
        height: 1.5,
      ),
    ),

    // ── Bottom sheet ──────────────────────────────────────────────────────
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: _Light.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      dragHandleColor: _Light.outline,
      dragHandleSize: Size(36, 4),
    ),

    // ── Typography ────────────────────────────────────────────────────────
    textTheme: const TextTheme(
      displayLarge:  TextStyle(fontSize: 57, fontWeight: FontWeight.w300, color: _Light.textPrimary, letterSpacing: -0.5),
      displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.w300, color: _Light.textPrimary),
      displaySmall:  TextStyle(fontSize: 36, fontWeight: FontWeight.w400, color: _Light.textPrimary),

      headlineLarge:  TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: _Light.textPrimary, letterSpacing: 0.3),
      headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: _Light.textPrimary),
      headlineSmall:  TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: _Light.textPrimary),

      titleLarge:  TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: _Light.textPrimary, letterSpacing: 0.2),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _Light.textPrimary),
      titleSmall:  TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _Light.textPrimary, letterSpacing: 0.1),

      bodyLarge:   TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: _Light.textPrimary, height: 1.6),
      bodyMedium:  TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: _Light.textSecondary, height: 1.5),
      bodySmall:   TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: _Light.textSecondary),

      labelLarge:  TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _Light.textPrimary, letterSpacing: 0.4),
      labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _Light.textSecondary, letterSpacing: 0.3),
      labelSmall:  TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: _Light.textSecondary, letterSpacing: 0.4),
    ),

    iconTheme: const IconThemeData(color: _Light.textSecondary, size: 24),
    primaryIconTheme: const IconThemeData(color: _Accent.indigo, size: 24),
  );
}

// ── Backward-compatibility alias ─────────────────────────────────────────────
/// Previously the single exported theme. Now delegates to the dark variant.
/// Widgets referencing `proxyTheme` continue to compile without changes.
final ThemeData proxyTheme = AppTheme.darkTheme;
