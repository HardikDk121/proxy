import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  PROXY THEME — Strict 3-Color Dark System
//
//  Base:      OLED black (#0A0A0F) + lifted charcoal (#14141F)
//  Primary:   Electric Indigo (#6C63FF) — brand actions, active states
//  Secondary: Emerald Green (#2DD4A8) — status, highlights, secondary CTA
//
//  Rule: Every visual element must derive from one of these three families.
// ─────────────────────────────────────────────────────────────────────────────

// ── Raw color tokens ────────────────────────────────────────────────────────
class _C {
  _C._(); // prevent instantiation

  // ── Base (dark family) ──────────────────────────────────────────────────
  static const bg            = Color(0xFF0A0A0F); // scaffold — near OLED
  static const surface       = Color(0xFF14141F); // cards, sheets
  static const surfaceHigh   = Color(0xFF1C1C2A); // elevated containers
  static const surfaceHigher = Color(0xFF242436); // modals, drawers

  // ── Primary — Electric Indigo ──────────────────────────────────────────
  static const indigo        = Color(0xFF6C63FF); // main brand
  static const indigoLight   = Color(0xFF9B94FF); // hover / highlight
  static const indigoDark    = Color(0xFF1A1640); // container bg
  static const onIndigo      = Color(0xFFFFFFFF); // text on indigo

  // ── Secondary — Emerald Green ─────────────────────────────────────────
  static const emerald       = Color(0xFF2DD4A8); // secondary brand
  static const emeraldLight  = Color(0xFF6EECD0); // hover / highlight
  static const emeraldDark   = Color(0xFF0D2E26); // container bg
  static const onEmerald     = Color(0xFF0A0A0F); // text on emerald

  // ── Neutrals ──────────────────────────────────────────────────────────
  static const textPrimary   = Color(0xFFE8E8F0); // high-emphasis text
  static const textSecondary = Color(0xFF9393A8); // body / hint text
  static const outline       = Color(0xFF2E2E40); // borders, dividers
  static const outlineLight  = Color(0xFF3A3A52); // subtle separators

  // ── Semantic — Attendance ─────────────────────────────────────────────
  static const safe          = Color(0xFF2DD4A8); // ≥ 75% (= emerald)
  static const borderline    = Color(0xFFFFB020); // 60-74%
  static const danger        = Color(0xFFFF5C5C); // < 60%
}

// ── Attendance color helper ─────────────────────────────────────────────────
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

// ── Theme ───────────────────────────────────────────────────────────────────
final ThemeData proxyTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,

  // ── Color Scheme ────────────────────────────────────────────────────────
  colorScheme: const ColorScheme(
    brightness: Brightness.dark,

    // Primary — Electric Indigo
    primary:              _C.indigo,
    onPrimary:            _C.onIndigo,
    primaryContainer:     _C.indigoDark,
    onPrimaryContainer:   _C.indigoLight,

    // Secondary — Emerald Green
    secondary:            _C.emerald,
    onSecondary:          _C.onEmerald,
    secondaryContainer:   _C.emeraldDark,
    onSecondaryContainer: _C.emeraldLight,

    // Tertiary — reuse indigo-light for subtle accents
    tertiary:             _C.indigoLight,
    onTertiary:           _C.bg,
    tertiaryContainer:    _C.indigoDark,
    onTertiaryContainer:  _C.indigoLight,

    // Surface
    surface:                   _C.surface,
    onSurface:                 _C.textPrimary,
    onSurfaceVariant:          _C.textSecondary,
    surfaceContainerHighest:   _C.surfaceHigher,
    surfaceContainerHigh:      _C.surfaceHigh,
    surfaceContainer:          _C.surface,
    surfaceContainerLow:       _C.bg,
    surfaceContainerLowest:    _C.bg,
    surfaceTint:               _C.indigo,

    // Inverse
    inverseSurface:       _C.textPrimary,
    onInverseSurface:     _C.bg,
    inversePrimary:       _C.indigoDark,

    // Error
    error:                _C.danger,
    onError:              _C.bg,
    errorContainer:       Color(0xFF3D0D0D),
    onErrorContainer:     Color(0xFFFFB3B3),

    // Outline
    outline:              _C.outline,
    outlineVariant:       _C.outlineLight,
    shadow:               Color(0xFF000000),
    scrim:                Color(0xFF000000),
  ),

  scaffoldBackgroundColor: _C.bg,

  // ── AppBar ──────────────────────────────────────────────────────────────
  appBarTheme: const AppBarTheme(
    centerTitle: true,
    backgroundColor: _C.surface,
    foregroundColor: _C.textPrimary,
    elevation: 0,
    scrolledUnderElevation: 2.0,
    surfaceTintColor: _C.indigo,
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: _C.textPrimary,
      letterSpacing: 0.5,
    ),
  ),

  // ── Cards ───────────────────────────────────────────────────────────────
  cardTheme: CardThemeData(
    color: _C.surface,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: _C.outline, width: 0.5),
    ),
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  ),

  // ── FAB — Emerald, punchy ─────────────────────────────────────────────
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: _C.emerald,
    foregroundColor: _C.onEmerald,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
  ),

  // ── Elevated button — Indigo ──────────────────────────────────────────
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _C.indigo,
      foregroundColor: _C.onIndigo,
      elevation: 0,
      textStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    ),
  ),

  // ── Outlined button — Emerald border ──────────────────────────────────
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: _C.emerald,
      side: const BorderSide(color: _C.emerald, width: 1.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    ),
  ),

  // ── Text button ───────────────────────────────────────────────────────
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: _C.indigo,
      textStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    ),
  ),

  // ── Input fields ──────────────────────────────────────────────────────
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: _C.surfaceHigh,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _C.outline),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _C.outline, width: 0.8),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _C.indigo, width: 1.8),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _C.danger, width: 1.2),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _C.danger, width: 1.8),
    ),
    labelStyle: const TextStyle(color: _C.textSecondary),
    hintStyle: const TextStyle(color: _C.textSecondary),
    prefixIconColor: _C.textSecondary,
    suffixIconColor: _C.textSecondary,
  ),

  // ── Bottom navigation ─────────────────────────────────────────────────
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: _C.surface,
    selectedItemColor: _C.indigo,
    unselectedItemColor: _C.textSecondary,
    showUnselectedLabels: true,
    elevation: 0,
    type: BottomNavigationBarType.fixed,
  ),

  // ── NavigationBar (M3) ────────────────────────────────────────────────
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: _C.surface,
    indicatorColor: _C.indigoDark,
    iconTheme: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const IconThemeData(color: _C.indigo);
      }
      return const IconThemeData(color: _C.textSecondary);
    }),
    labelTextStyle: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const TextStyle(
          color: _C.indigo,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        );
      }
      return const TextStyle(color: _C.textSecondary, fontSize: 12);
    }),
  ),

  // ── Divider ───────────────────────────────────────────────────────────
  dividerTheme: const DividerThemeData(
    color: _C.outline,
    thickness: 0.5,
    space: 1,
  ),

  // ── Chip ──────────────────────────────────────────────────────────────
  chipTheme: ChipThemeData(
    backgroundColor: _C.surfaceHigh,
    selectedColor: _C.indigoDark,
    labelStyle: const TextStyle(color: _C.textPrimary, fontSize: 13),
    side: const BorderSide(color: _C.outline, width: 0.5),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  ),

  // ── Switch & Checkbox ─────────────────────────────────────────────────
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      return states.contains(WidgetState.selected)
          ? _C.emerald
          : _C.textSecondary;
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      return states.contains(WidgetState.selected)
          ? _C.emeraldDark
          : _C.outline;
    }),
  ),
  checkboxTheme: CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith((states) {
      return states.contains(WidgetState.selected)
          ? _C.indigo
          : Colors.transparent;
    }),
    checkColor: WidgetStateProperty.all(_C.onIndigo),
    side: const BorderSide(color: _C.outline, width: 1.2),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
  ),

  // ── SnackBar ──────────────────────────────────────────────────────────
  snackBarTheme: SnackBarThemeData(
    backgroundColor: _C.surfaceHigh,
    contentTextStyle: const TextStyle(color: _C.textPrimary, fontSize: 14),
    actionTextColor: _C.emerald,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: _C.outline, width: 0.5),
    ),
    behavior: SnackBarBehavior.floating,
    elevation: 0,
  ),

  // ── Progress indicator ────────────────────────────────────────────────
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: _C.indigo,
    circularTrackColor: _C.outline,
    linearTrackColor: _C.outline,
  ),

  // ── Dialog ────────────────────────────────────────────────────────────
  dialogTheme: DialogThemeData(
    backgroundColor: _C.surfaceHigh,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    titleTextStyle: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: _C.textPrimary,
    ),
    contentTextStyle: const TextStyle(
      fontSize: 14,
      color: _C.textSecondary,
      height: 1.5,
    ),
  ),

  // ── Bottom Sheet ──────────────────────────────────────────────────────
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: _C.surfaceHigh,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    dragHandleColor: _C.outlineLight,
    dragHandleSize: Size(36, 4),
  ),

  // ── Typography ────────────────────────────────────────────────────────
  textTheme: const TextTheme(
    // Display — dashboard hero numbers
    displayLarge:  TextStyle(fontSize: 57, fontWeight: FontWeight.w300, color: _C.textPrimary, letterSpacing: -0.5),
    displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.w300, color: _C.textPrimary),
    displaySmall:  TextStyle(fontSize: 36, fontWeight: FontWeight.w400, color: _C.textPrimary),

    // Headline — screen titles
    headlineLarge:  TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: _C.textPrimary, letterSpacing: 0.3),
    headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: _C.textPrimary),
    headlineSmall:  TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: _C.textPrimary),

    // Title — card titles
    titleLarge:  TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: _C.textPrimary, letterSpacing: 0.2),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _C.textPrimary),
    titleSmall:  TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _C.textPrimary, letterSpacing: 0.1),

    // Body — descriptions
    bodyLarge:   TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: _C.textPrimary, height: 1.6),
    bodyMedium:  TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: _C.textSecondary, height: 1.5),
    bodySmall:   TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: _C.textSecondary),

    // Label — buttons, chips
    labelLarge:  TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _C.textPrimary, letterSpacing: 0.4),
    labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _C.textSecondary, letterSpacing: 0.3),
    labelSmall:  TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: _C.textSecondary, letterSpacing: 0.4),
  ),

  iconTheme: const IconThemeData(color: _C.textSecondary, size: 24),
  primaryIconTheme: const IconThemeData(color: _C.indigo, size: 24),
);
