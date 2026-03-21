// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../routes/app_routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ProxyHome'),
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
              label: 'Go to Settings',
              icon: Icons.settings,
              onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
            ),
            _NavButton(
              label: 'Go to Detail (with ID)',
              icon: Icons.article,
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.detail,
                arguments: 'item-42',
              ),
            ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: onTap,
      ),
    );
  }
}