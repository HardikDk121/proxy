import 'package:flutter/material.dart';
import 'theme.dart';
import 'pie.dart';
void main() {
  runApp(const ProxyApp());
}

class ProxyApp extends StatelessWidget {
  const ProxyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Proxy',
      debugShowCheckedModeBanner: false, // Hides the annoying debug banner
      theme: proxyTheme,                 // <--- THIS IS THE MAGIC LINE
      home: const DashboardScreen(),
      
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
