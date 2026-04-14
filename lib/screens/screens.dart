// lib/screens/screens.dart
// Placeholder screens for routes not yet built.
// All use Material 3 components and the app's ColorScheme.
// ─────────────────────────────────────────────────────────────────────────────
// ignore_for_file: file_names

import 'package:flutter/material.dart';
import '../routes/app_routes.dart';

// ── Profile Screen ────────────────────────────────────────────────────────────

class ProfileScreen extends StatelessWidget {
  final Map<String, dynamic>? args;
  const ProfileScreen({super.key, this.args});

  @override
  Widget build(BuildContext context) {
    final cs    = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final name  = args?['name'] as String? ?? 'Student';
    final email = args?['email'] as String? ?? 'student@college.edu';
    final initials = name.split(' ').take(2).map((w) => w[0].toUpperCase()).join();

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Avatar + name
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: cs.primaryContainer,
                  child: Text(
                    initials,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: cs.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  name,
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Info cards
          Card(
            elevation: 0,
            color: cs.surfaceContainerLow,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                _InfoTile(icon: Icons.badge_rounded,   label: 'Name',  value: name),
                _InfoTile(icon: Icons.email_rounded,   label: 'Email', value: email),
                _InfoTile(icon: Icons.school_rounded,  label: 'Year',  value: args?['year'] ?? 'Not set'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Sign out
          OutlinedButton.icon(
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Sign Out'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              foregroundColor: cs.error,
              side: BorderSide(color: cs.error.withValues(alpha: 0.5)),
              textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(icon, color: cs.primary, size: 22),
      title: Text(
        label,
        style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        value,
        style: TextStyle(fontSize: 14, color: cs.onSurface, fontWeight: FontWeight.w500),
      ),
      dense: true,
    );
  }
}

// ── Settings Screen ───────────────────────────────────────────────────────────

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section: Attendance
          _SectionHeader('Attendance'),
          Card(
            elevation: 0,
            color: cs.surfaceContainerLow,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.percent_rounded,
                  title: 'Minimum attendance',
                  subtitle: '75% — required by most colleges',
                  onTap: () {},
                ),
                _SettingsTile(
                  icon: Icons.notifications_rounded,
                  title: 'Low attendance alerts',
                  subtitle: 'Notify when below threshold',
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Section: App
          _SectionHeader('App'),
          Card(
            elevation: 0,
            color: cs.surfaceContainerLow,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.dark_mode_rounded,
                  title: 'Theme',
                  subtitle: 'Follow system',
                  onTap: () {},
                ),
                _SettingsTile(
                  icon: Icons.delete_outline_rounded,
                  title: 'Clear all data',
                  subtitle: 'Reset attendance records',
                  onTap: () {},
                  isDestructive: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Version info
          Center(
            child: Text(
              'Proxy v1.0.0',
              style: TextStyle(
                fontSize: 12,
                color: cs.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  final bool isDestructive;
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = isDestructive ? cs.error : cs.onSurface;
    return ListTile(
      leading: Icon(icon, color: isDestructive ? cs.error : cs.primary, size: 22),
      title: Text(
        title,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
      ),
      trailing: Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant, size: 20),
      onTap: onTap,
    );
  }
}

// ── Detail Screen (Subject Detail placeholder) ────────────────────────────────

class DetailScreen extends StatelessWidget {
  final String id;
  const DetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final cs    = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(id),
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.onPrimaryContainer,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.article_rounded, size: 40, color: cs.onPrimaryContainer),
              ),
              const SizedBox(height: 20),
              Text(
                id,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'Subject detail screen coming soon.\nWill show attendance logs here.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              FilledButton.tonal(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(200, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Not Found Screen ──────────────────────────────────────────────────────────
// (Kept here as a duplicate export — the main file is not_found_screen.dart)

class NotFoundScreen extends StatelessWidget {
  final String routeName;
  const NotFoundScreen({super.key, required this.routeName});

  @override
  Widget build(BuildContext context) {
    final cs    = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  color: cs.errorContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.search_off_rounded, size: 48, color: cs.onErrorContainer),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: cs.errorContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '404',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: cs.error,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Page Not Found',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                '"$routeName" doesn\'t exist.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 36),
              FilledButton.icon(
                icon: const Icon(Icons.home_rounded),
                label: const Text('Back to Home'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context, AppRoutes.home, (r) => false,
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Go Back'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}