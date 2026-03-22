// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../routes/app_routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'onGenerateRoute Demo',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

     
            _NavButton(
              label: 'Go to Unknown Route (404)',
              icon: Icons.error_outline,
              color: Colors.red,
              onTap: () => Navigator.pushNamed(context, '/does-not-exist'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _NavButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.color = Colors.indigo,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ElevatedButton.icon(
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: onTap,
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// lib/screens/login_screen.dart
// ignore_for_file: file_names
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login'), backgroundColor: Colors.indigo, foregroundColor: Colors.white),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 64, color: Colors.indigo),
              SizedBox(height: 16),
              Text('Login Screen', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Arguments: none', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// lib/screens/profile_screen.dart
class ProfileScreen extends StatelessWidget {
  final Map<String, dynamic>? args;
  const ProfileScreen({super.key, this.args});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), backgroundColor: Colors.indigo, foregroundColor: Colors.white),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(radius: 40, backgroundColor: Colors.indigo, child: Icon(Icons.person, size: 40, color: Colors.white)),
              const SizedBox(height: 16),
              Text(args?['name'] ?? 'Unknown', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(args?['email'] ?? '', style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              Text('Arguments received: $args', style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
            ],
          ),
        ),
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// lib/screens/settings_screen.dart
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), backgroundColor: Colors.indigo, foregroundColor: Colors.white),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.settings, size: 64, color: Colors.indigo),
            SizedBox(height: 16),
            Text('Settings Screen', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// lib/screens/detail_screen.dart
class DetailScreen extends StatelessWidget {
  final String id;
  const DetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail'), backgroundColor: Colors.indigo, foregroundColor: Colors.white),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.article, size: 64, color: Colors.indigo),
            const SizedBox(height: 16),
            const Text('Detail Screen', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('ID: $id', style: const TextStyle(fontSize: 16, color: Colors.indigo)),
            ),
          ],
        ),
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// lib/screens/not_found_screen.dart
class NotFoundScreen extends StatelessWidget {
  final String routeName;
  const NotFoundScreen({super.key, required this.routeName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('404'), backgroundColor: Colors.red, foregroundColor: Colors.white),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 72, color: Colors.red),
            const SizedBox(height: 16),
            const Text('404 — Page Not Found', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('"$routeName" does not exist', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.home),
              label: const Text('Back to Home'),
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.home,
                (route) => false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}