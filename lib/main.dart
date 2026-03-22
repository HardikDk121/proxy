import 'package:flutter/material.dart';
import 'package:proxy/themes/theme.dart';
import 'pie.dart';
import 'routes/app_routes.dart';
import 'routes/route_generator.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart'; 
void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding); // keep splash visible
  RouteGenerator.registerRoutes();
  FlutterNativeSplash.remove(); 
  runApp(const ProxyApp());
}

class ProxyApp extends StatelessWidget {
  const ProxyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Proxy',
      debugShowCheckedModeBanner: false, 
      theme: proxyTheme,                 
      initialRoute: AppRoutes.home,
 
      // ── Route generation ─────────────────────────────────────────────────
      onGenerateRoute: RouteGenerator.onGenerateRoute,
 
      // ── Fallback for truly unknown routes ────────────────────────────────
      onUnknownRoute: RouteGenerator.onUnknownRoute,
    );
  }
}
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Attendance Dashboard',)),
      body: AttendancePieChart(attendedClasses: 75, bunkedClasses: 25),
      backgroundColor: Theme.of(context).colorScheme.surface,);
  }
}
