// lib/screens/home_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
// HomeScreen — fully wired to Hive via ValueListenableBuilder.
// No setState, no StreamBuilder: the box notifies the widget tree directly.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/subject.dart';
import '../routes/app_routes.dart';
import '../services/attendance_service.dart';
import '../widgets/add_subject_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  HOME SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    // ── ValueListenableBuilder listens to the Hive box ────────────────────
    // Every add / update / delete automatically triggers a rebuild here.
    return ValueListenableBuilder<Box<Subject>>(
      valueListenable: AttendanceService.listenable,
      builder: (context, box, _) {
        final subjects = box.values.toList();

        final attended = subjects.fold(0, (s, e) => s + e.attended);
        final total    = subjects.fold(0, (s, e) => s + e.total);
        final overallPct = total == 0 ? 0.0 : (attended / total) * 100;

        return Scaffold(
          body: subjects.isEmpty
              ? _EmptyState(greeting: _greeting)
              : CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // ── Header ───────────────────────────────────────────
                    SliverToBoxAdapter(
                      child: _HeroHeader(
                        greeting: _greeting,
                        overallPct: overallPct,
                      ),
                    ),

                    // ── Quick Stats ──────────────────────────────────────
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                      sliver: SliverToBoxAdapter(
                        child: _QuickStatsRow(subjects: subjects),
                      ),
                    ),

                    // ── Timetable Banner ─────────────────────────────────
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      sliver: SliverToBoxAdapter(child: _TimetableBanner()),
                    ),

                    // ── Section Title ────────────────────────────────────
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                      sliver: SliverToBoxAdapter(
                        child: _SectionHeader(count: subjects.length),
                      ),
                    ),

                    // ── Subject List ─────────────────────────────────────
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _SubjectCard(subject: subjects[index]),
                          ),
                          childCount: subjects.length,
                        ),
                      ),
                    ),
                  ],
                ),

          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => showAddSubjectSheet(context),
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text(
              'Add Subject',
              style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.3),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  EMPTY STATE — shown when the Hive box has no records yet
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String greeting;
  const _EmptyState({required this.greeting});

  @override
  Widget build(BuildContext context) {
    final cs    = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.school_rounded, size: 46, color: cs.onPrimaryContainer),
              ),
              const SizedBox(height: 28),
              Text(
                '$greeting 👋',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              Text(
                'Add your first subject to start\ntracking attendance.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 36),
              FilledButton.icon(
                onPressed: () => showAddSubjectSheet(context),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Subject'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(200, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  SECTION HEADER
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final int count;
  const _SectionHeader({required this.count});

  @override
  Widget build(BuildContext context) {
    final cs    = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 3, height: 18,
          decoration: BoxDecoration(
            color: cs.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'Your Subjects',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: cs.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, color: cs.primary,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  HERO HEADER — Gradient banner with attendance ring
// ─────────────────────────────────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  final String greeting;
  final double overallPct;
  const _HeroHeader({required this.greeting, required this.overallPct});

  Color _statusColor(ColorScheme cs) {
    if (overallPct >= 75) return cs.secondary;
    if (overallPct >= 60) return const Color(0xFFFFB020);
    return cs.error;
  }

  String get _statusMessage {
    if (overallPct >= 80) return "You're doing great! 🎉";
    if (overallPct >= 75) return "On track — keep it up";
    if (overallPct >= 60) return "Borderline — attend more";
    return "Danger zone! Stop bunking";
  }

  IconData get _statusIcon {
    if (overallPct >= 80) return Icons.rocket_launch_rounded;
    if (overallPct >= 75) return Icons.trending_up_rounded;
    if (overallPct >= 60) return Icons.warning_amber_rounded;
    return Icons.error_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final color   = _statusColor(cs);
    final screenW = MediaQuery.of(context).size.width;
    final ringSize = screenW < 360 ? 72.0 : 88.0;
    final ringFont = screenW < 360 ? 18.0 : 22.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primaryContainer,
            cs.primaryContainer.withOpacity(0.6),
            cs.surfaceContainerHigh,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top bar ───────────────────────────────────────────────
              Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [cs.primary, cs.primary.withOpacity(0.7)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text(
                        'P',
                        style: TextStyle(
                          color: Colors.white, fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Proxy',
                          style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w800,
                            color: cs.onSurface, letterSpacing: 0.3,
                          ),
                        ),
                        Text(
                          greeting,
                          style: TextStyle(
                            fontSize: 12, color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _IconBtn(
                    icon: Icons.bar_chart_rounded,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.bunkPredictor),
                    color: cs.onSurfaceVariant,
                    bgColor: cs.surfaceContainerHigh,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── Attendance ring + info ─────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: ringSize, height: ringSize,
                    child: CustomPaint(
                      painter: _RingPainter(
                        progress: overallPct / 100,
                        color: color,
                        trackColor: color.withOpacity(0.12),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${overallPct.toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: ringFont, fontWeight: FontWeight.w900,
                                color: color, height: 1,
                              ),
                            ),
                            Text(
                              'overall',
                              style: TextStyle(
                                fontSize: 10, color: cs.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Overall Attendance',
                          style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w600,
                            color: cs.onSurfaceVariant, letterSpacing: 0.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: color.withOpacity(0.2)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_statusIcon, size: 13, color: color),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  _statusMessage,
                                  style: TextStyle(
                                    fontSize: 11, fontWeight: FontWeight.w600,
                                    color: color,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: overallPct / 100,
                            backgroundColor: color.withOpacity(0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                            minHeight: 5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Min required: 75%',
                          style: TextStyle(
                            fontSize: 10,
                            color: cs.onSurfaceVariant.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  CUSTOM RING PAINTER
// ─────────────────────────────────────────────────────────────────────────────

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;

  const _RingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r      = size.width / 2 - 6;
    const stroke = 7.0;

    canvas.drawCircle(
      center, r,
      Paint()
        ..style      = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color      = trackColor,
    );

    final sweep = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r),
      -pi / 2, sweep, false,
      Paint()
        ..style      = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap  = StrokeCap.round
        ..color      = color,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress || old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
//  QUICK STATS ROW
// ─────────────────────────────────────────────────────────────────────────────

class _QuickStatsRow extends StatelessWidget {
  final List<Subject> subjects;
  const _QuickStatsRow({required this.subjects});

  @override
  Widget build(BuildContext context) {
    final cs     = Theme.of(context).colorScheme;
    final safe   = subjects.where((s) => s.isSafe).length;
    final danger = subjects.where((s) => !s.isSafe).length;

    return Row(
      children: [
        _StatChip(
          icon: Icons.list_alt_rounded,
          value: '${subjects.length}',
          label: 'Total',
          iconColor: cs.primary,
          bgColor: cs.primaryContainer,
        ),
        const SizedBox(width: 8),
        _StatChip(
          icon: Icons.check_circle_rounded,
          value: '$safe',
          label: 'Safe',
          iconColor: cs.secondary,
          bgColor: cs.secondaryContainer,
        ),
        const SizedBox(width: 8),
        _StatChip(
          icon: Icons.warning_rounded,
          value: '$danger',
          label: 'At Risk',
          iconColor: cs.error,
          bgColor: cs.errorContainer,
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value, label;
  final Color iconColor, bgColor;
  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.outlineVariant, width: 0.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 30, height: 30,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 15, color: iconColor),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w800,
                color: cs.onSurface, height: 1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.w500,
                color: cs.onSurfaceVariant,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  SUBJECT CARD — individual subject tile with swipe-to-delete
// ─────────────────────────────────────────────────────────────────────────────

class _SubjectCard extends StatelessWidget {
  final Subject subject;
  const _SubjectCard({required this.subject});

  Color _statusColor(ColorScheme cs) {
    if (subject.percentage >= 75) return cs.secondary;
    if (subject.percentage >= 60) return const Color(0xFFFFB020);
    return cs.error;
  }

  IconData get _typeIcon =>
      subject.type == 'Lab' ? Icons.science_rounded : Icons.menu_book_rounded;

  String _bunkInfo() {
    final margin = subject.bunkMargin;
    if (margin > 0)  return 'Can skip $margin';
    if (margin == 0) return 'No margin left';
    return 'Need ${-margin} more';
  }

  @override
  Widget build(BuildContext context) {
    final cs    = Theme.of(context).colorScheme;
    final color = _statusColor(cs);
    final isLab = subject.type == 'Lab';

    return Dismissible(
      key: ValueKey(subject.key),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: cs.errorContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.delete_rounded, color: cs.onErrorContainer, size: 26),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Subject?'),
            content: Text(
              '"${subject.name}" and all its attendance data will be removed.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: FilledButton.styleFrom(
                  backgroundColor: cs.error,
                  foregroundColor: cs.onError,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => AttendanceService.deleteSubject(subject),
      child: Material(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, AppRoutes.subjectDashboard),
          borderRadius: BorderRadius.circular(16),
          splashColor: cs.primary.withOpacity(0.08),
          highlightColor: cs.primary.withOpacity(0.04),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // ── Icon ────────────────────────────────────────────────
                Container(
                  width: 46, height: 46,
                  decoration: BoxDecoration(
                    color: isLab ? cs.secondaryContainer : cs.primaryContainer,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    _typeIcon, size: 22,
                    color: isLab ? cs.onSecondaryContainer : cs.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 14),

                // ── Info ─────────────────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: isLab ? cs.secondaryContainer : cs.primaryContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              subject.type,
                              style: TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w700,
                                color: isLab ? cs.onSecondaryContainer : cs.onPrimaryContainer,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              '${subject.attended}/${subject.total} classes',
                              style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Bunk margin indicator
                      Row(
                        children: [
                          Container(
                            width: 5, height: 5,
                            decoration: BoxDecoration(
                              color: color, shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              _bunkInfo(),
                              style: TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w600, color: color,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // ── Percentage + Bar ────────────────────────────────────
                SizedBox(
                  width: 60,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: color.withOpacity(0.2), width: 0.5),
                        ),
                        child: Text(
                          '${subject.percentage.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w800, color: color,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: subject.percentage / 100,
                          backgroundColor: color.withOpacity(0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                          minHeight: 4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  TIMETABLE BANNER
// ─────────────────────────────────────────────────────────────────────────────

class _TimetableBanner extends StatelessWidget {
  const _TimetableBanner();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, AppRoutes.timetable),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                cs.primary.withOpacity(0.12),
                cs.primary.withOpacity(0.04),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cs.primary.withOpacity(0.15), width: 0.8),
          ),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  Icons.calendar_month_rounded,
                  color: cs.onPrimaryContainer, size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'View Timetable',
                      style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'See your full weekly schedule',
                      style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded, size: 14,
                color: cs.primary.withOpacity(0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  ICON BUTTON HELPER
// ─────────────────────────────────────────────────────────────────────────────

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final Color bgColor;
  const _IconBtn({
    required this.icon,
    required this.onTap,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 0.5,
          ),
        ),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}