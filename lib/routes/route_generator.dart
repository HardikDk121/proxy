// lib/routes/route_generator.dart

import 'package:flutter/material.dart';
//import '../screens/splash_screen.dart';
import '../screens/home_screen.dart';
import '../screens/not_found_screen.dart';
import '../screens/time_table_screen.dart';
// import '../screens/add_subject_screen.dart';
// import '../screens/subject_detail_screen.dart';
import '../screens/bunk_predictor_screen.dart';
import 'app_routes.dart';
import '../screens/subject_dashboard_screen.dart';
import '../models/subject.dart';
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

class RouteGenerator {
  RouteGenerator._();
  static final List<_RouteEntry> _routes = [];

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

  static void registerRoutes() {
    //route(AppRoutes.splash, (_) => const SplashScreen());
    route(AppRoutes.home, (_) => const HomeScreen());

    // ── Bunk-O-Meter screens ─────────────────────────────────────────────
    // Replace each _PlaceholderScreen with the real screen as you build it:

    route(AppRoutes.timetable, (_) => const TimetableScreen());

    route(AppRoutes.addSubject,
        (_) => const _PlaceholderScreen(title: 'Add Subject'));

    route(AppRoutes.subjectDetail,
        (_) => const _PlaceholderScreen(title: 'Subject Detail'));
        // Replace with: (s) => SubjectDetailScreen(name: s.arguments as String)

    route(AppRoutes.bunkPredictor,
        (_) => const BunkPredictorScreen());

    route(AppRoutes.subjectDashboard,
      (s) => SubjectDashboardScreen(subject: s.arguments as Subject),
    );
  }

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final path = settings.name ?? AppRoutes.notFound;
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
    return MaterialPageRoute(
      settings: settings,
      builder: (_) => NotFoundScreen(routeName: path),
    );
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => NotFoundScreen(routeName: settings.name ?? 'unknown'),
    );
  }
}

// ── Placeholder until real screen is built ────────────────────────────────────
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title.toUpperCase())),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.construction_rounded, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text('$title — coming soon',
                style: const TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}