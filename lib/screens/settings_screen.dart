// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  bool _darkMode      = false;
  bool _locationAccess = false;
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          // ── Account Section ──────────────────────────────────────────────
          _SectionHeader(title: 'Account'),
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.indigo,
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: const Text('John Doe'),
            subtitle: const Text('john@example.com'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(),

          // ── Preferences Section ──────────────────────────────────────────
          _SectionHeader(title: 'Preferences'),
          SwitchListTile(
            secondary:
                const Icon(Icons.notifications_outlined, color: Colors.indigo),
            title: const Text('Notifications'),
            subtitle: const Text('Receive push notifications'),
            value: _notifications,
            activeColor: Colors.indigo,
            onChanged: (val) => setState(() => _notifications = val),
          ),
          SwitchListTile(
            secondary:
                const Icon(Icons.dark_mode_outlined, color: Colors.indigo),
            title: const Text('Dark Mode'),
            subtitle: const Text('Switch to dark theme'),
            value: _darkMode,
            activeColor: Colors.indigo,
            onChanged: (val) => setState(() => _darkMode = val),
          ),
          SwitchListTile(
            secondary:
                const Icon(Icons.location_on_outlined, color: Colors.indigo),
            title: const Text('Location Access'),
            subtitle: const Text('Allow app to access location'),
            value: _locationAccess,
            activeColor: Colors.indigo,
            onChanged: (val) => setState(() => _locationAccess = val),
          ),
          const Divider(),

          // ── Language Section ─────────────────────────────────────────────
          _SectionHeader(title: 'Language'),
          ListTile(
            leading: const Icon(Icons.language, color: Colors.indigo),
            title: const Text('App Language'),
            trailing: DropdownButton<String>(
              value: _selectedLanguage,
              underline: const SizedBox(),
              items: ['English', 'Hindi', 'Gujarati', 'French']
                  .map((lang) =>
                      DropdownMenuItem(value: lang, child: Text(lang)))
                  .toList(),
              onChanged: (val) =>
                  setState(() => _selectedLanguage = val ?? 'English'),
            ),
          ),
          const Divider(),

          // ── About Section ────────────────────────────────────────────────
          _SectionHeader(title: 'About'),
          ListTile(
            leading:
                const Icon(Icons.info_outline, color: Colors.indigo),
            title: const Text('App Version'),
            trailing:
                const Text('1.0.0', style: TextStyle(color: Colors.grey)),
          ),
          ListTile(
            leading:
                const Icon(Icons.privacy_tip_outlined, color: Colors.indigo),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout',
                style: TextStyle(color: Colors.red)),
            onTap: () {},
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.indigo.shade400,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}