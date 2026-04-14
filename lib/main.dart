// lib/main.dart
// ─────────────────────────────────────────────────────────────────────────────
// Entry point — initialises Hive BEFORE runApp so the Box is always available.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:proxy/themes/theme.dart'; // AppTheme.lightTheme / darkTheme
import 'models/subject.dart';
import 'models/timetable_slot.dart';
import 'routes/app_routes.dart';
import 'routes/route_generator.dart';
import 'services/attendance_service.dart';
import 'services/timetable_service.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

// ── Global theme-mode notifier ───────────────────────────────────────────────
// Any widget in the tree can read/toggle this without a full state-management
// package.  Pass it down via an InheritedWidget wrapper (ThemeModeProvider).
final ValueNotifier<ThemeMode> themeModeNotifier =
    ValueNotifier(ThemeMode.system);

Future<void> main() async {
  // 1️⃣  Must be the very first line — required by async main & plugins.
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // 2️⃣  Keep the native splash visible while we initialise.
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // 3️⃣  Initialise Hive with the Flutter path helper (finds the correct
  //     documents directory on every platform).
  await Hive.initFlutter();

  // 4️⃣  Register every TypeAdapter BEFORE opening boxes that use it.
  Hive.registerAdapter(SubjectAdapter());          // typeId 0
  Hive.registerAdapter(TimetableSlotAdapter());    // typeId 1

  // 5️⃣  Open boxes through their services so we have one owner each.
  await AttendanceService.init();
  await TimetableService.init();

  // 6️⃣  Register named routes.
  RouteGenerator.registerRoutes();

  // 7️⃣  Splash can be removed — everything is ready.
  FlutterNativeSplash.remove();

  runApp(const ProxyApp());
}

// ─────────────────────────────────────────────────────────────────────────────

class ProxyApp extends StatelessWidget {
  const ProxyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'Proxy',
          debugShowCheckedModeBanner: false,
          // ── Dual-theme setup ──────────────────────────────────────────────
          theme:      AppTheme.lightTheme,
          darkTheme:  AppTheme.darkTheme,
          themeMode:  mode,             // controlled by themeModeNotifier
          // ─────────────────────────────────────────────────────────────────
          initialRoute: AppRoutes.home,
          onGenerateRoute: RouteGenerator.onGenerateRoute,
          onUnknownRoute: RouteGenerator.onUnknownRoute,
        );
      },
    );
  }
}
