// lib/routes/route_generator.dart

import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/home_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/detail_screen.dart';
import '../screens/not_found_screen.dart';
import 'app_routes.dart';

/// A single registered route entry.
class _RouteEntry {
  final String path;
  final Widget Function(RouteSettings settings) builder;
  final bool fullscreenDialog;
  final bool maintainState;

  const _RouteEntry({
    required this.path,
    required this.builder,
    this.fullscreenDialog = false,
    this.maintainState = true,
  });
}

/// ─── Route Registry ──────────────────────────────────────────────────────────
/// Add every screen here using the [route()] helper.
/// Order matters: first match wins.
class RouteGenerator {
  RouteGenerator._();

  static final List<_RouteEntry> _routes = [];

  /// Register a route.
  ///
  /// ```dart
  /// route(AppRoutes.home, (s) => const HomeScreen());
  /// route(AppRoutes.detail, (s) => DetailScreen(id: s.arguments as String));
  /// ```
  static void route(
    String path,
    Widget Function(RouteSettings settings) builder, {
    bool fullscreenDialog = false,
    bool maintainState = true,
  }) {
    _routes.add(_RouteEntry(
      path: path,
      builder: builder,
      fullscreenDialog: fullscreenDialog,
      maintainState: maintainState,
    ));
  }

  /// Call once — usually in [main()] or before [runApp()].
  static void registerRoutes() {
    route(AppRoutes.splash,   (_) => const SplashScreen());
    route(AppRoutes.home,     (_) => const HomeScreen());

    route(AppRoutes.settings, (_) => const SettingsScreen());
    route(
      AppRoutes.detail,
      (s) => DetailScreen(id: s.arguments as String? ?? ''),
    );
  }

  // ─── onGenerateRoute handler ─────────────────────────────────────────────
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final String path = settings.name ?? AppRoutes.notFound;

    for (final entry in _routes) {
      if (entry.path == path) {
        return MaterialPageRoute(
          settings: settings,
          fullscreenDialog: entry.fullscreenDialog,
          maintainState: entry.maintainState,
          builder: (_) => entry.builder(settings),
        );
      }
    }

    // ── Fallback: 404 ────────────────────────────────────────────────────
    return MaterialPageRoute(
      settings: settings,
      builder: (_) => NotFoundScreen(routeName: path),
    );
  }

  // ─── onUnknownRoute handler ──────────────────────────────────────────────
  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => NotFoundScreen(routeName: settings.name ?? 'unknown'),
    );
  }
}