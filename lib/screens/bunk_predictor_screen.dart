// lib/screens/bunk_predictor_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
// Bunk Predictor Screen — reads Subject data from Hive and calculates:
//   • How many classes can be safely skipped (bunkMargin > 0)
//   • How many classes must be attended to recover to 75% (bunkMargin < 0)
//
// No new Hive box needed — uses AttendanceService.listenable (Subject box).
// All math delegates to Subject.bunkMargin, Subject.isSafe, Subject.percentage.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/subject.dart';
import '../services/attendance_service.dart';

class BunkPredictorScreen extends StatelessWidget {
  const BunkPredictorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<Subject>>(
      valueListenable: AttendanceService.listenable,
      builder: (context, box, _) {
        final subjects = box.values.toList();
        return _BunkPredictorView(subjects: subjects);
      },
    );
  }
}

// ── Main view (StatelessWidget so it rebuilds cleanly on box changes) ─────────

class _BunkPredictorView extends StatelessWidget {
  final List<Subject> subjects;
  const _BunkPredictorView({required this.subjects});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final safeCount = subjects.where((s) => s.isSafe).length;
    final dangerCount = subjects.where((s) => !s.isSafe).length;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: cs.surface,
      body: subjects.isEmpty
          ? _EmptyState()
          : CustomScrollView(
              slivers: [
                // ── Collapsing header ──────────────────────────────────────
                _BunkAppBar(
                  safeCount: safeCount,
                  totalCount: subjects.length,
                ),

                // ── Summary cards row ─────────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  sliver: SliverToBoxAdapter(
                    child: _SummaryRow(
                      safeCount: safeCount,
                      dangerCount: dangerCount,
                    ),
                  ),
                ),

                // ── Section label ─────────────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 10),
                  sliver: SliverToBoxAdapter(
                    child: _SectionLabel(
                      icon: Icons.analytics_rounded,
                      title: 'Subject Breakdown',
                    ),
                  ),
                ),

                // ── Per-subject cards ─────────────────────────────────────
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPad + 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _SubjectBunkCard(subject: subjects[i]),
                      ),
                      childCount: subjects.length,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

// ── Collapsing App Bar ────────────────────────────────────────────────────────

class _BunkAppBar extends StatelessWidget {
  final int safeCount;
  final int totalCount;
  const _BunkAppBar({required this.safeCount, required this.totalCount});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final statusH = MediaQuery.of(context).padding.top;

    return SliverAppBar(
      expandedHeight: 180 + statusH,
      pinned: true,
      backgroundColor: cs.primaryContainer,
      surfaceTintColor: Colors.transparent,
      foregroundColor: cs.onPrimaryContainer,
      title: Text(
        'Bunk Predictor',
        style: TextStyle(
          color: cs.onPrimaryContainer,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
      centerTitle: false,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                cs.primaryContainer,
                cs.primaryContainer.withValues(alpha: 0.7),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Attendance Analysis',
                    style: TextStyle(
                      color: cs.onPrimaryContainer.withValues(alpha: 0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    totalCount == 0
                        ? 'No subjects yet'
                        : safeCount == totalCount
                            ? 'All subjects are safe ✅'
                            : '$safeCount of $totalCount subjects at 75%+',
                    style: TextStyle(
                      color: cs.onPrimaryContainer,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Overall progress bar
                  if (totalCount > 0)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: safeCount / totalCount,
                        backgroundColor:
                            cs.onPrimaryContainer.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(cs.secondary),
                        minHeight: 5,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Summary Row ───────────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  final int safeCount;
  final int dangerCount;
  const _SummaryRow({required this.safeCount, required this.dangerCount});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        _SummaryCard(
          icon: Icons.check_circle_rounded,
          iconColor: cs.secondary,
          bg: cs.secondaryContainer,
          fg: cs.onSecondaryContainer,
          value: '$safeCount',
          label: 'Safe to skip',
          sublabel: '≥75% attendance',
        ),
        const SizedBox(width: 12),
        _SummaryCard(
          icon: Icons.warning_amber_rounded,
          iconColor: cs.error,
          bg: cs.errorContainer,
          fg: cs.onErrorContainer,
          value: '$dangerCount',
          label: 'Need recovery',
          sublabel: '<75% attendance',
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor, bg, fg;
  final String value, label, sublabel;

  const _SummaryCard({
    required this.icon,
    required this.iconColor,
    required this.bg,
    required this.fg,
    required this.value,
    required this.label,
    required this.sublabel,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cs.outlineVariant, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 22, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: cs.onSurface,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    sublabel,
                    style: TextStyle(
                      fontSize: 10,
                      color: cs.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section Label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionLabel({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: cs.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Icon(icon, size: 16, color: cs.primary),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
      ],
    );
  }
}

// ── Per-Subject Bunk Card ─────────────────────────────────────────────────────

class _SubjectBunkCard extends StatelessWidget {
  final Subject subject;
  const _SubjectBunkCard({required this.subject});

  // ── Attendance-based color ─────────────────────────────────────────────────
  Color _statusColor(ColorScheme cs) {
    if (subject.percentage >= 75) return cs.secondary;
    if (subject.percentage >= 60) return const Color(0xFFFFB020);
    return cs.error;
  }

  // ── Bunk / recovery message ────────────────────────────────────────────────

  /// Classes the user can still skip while staying ≥ 75%.
  int get _canSkip => max(0, subject.bunkMargin);

  /// Classes needed to recover to 75% from below.
  /// Formula: ceil((0.75*(total+x) - attended)) where 0.75*(total+x) ≤ attended+x
  /// Simplifies to: ceil((3*total - 4*attended) / 1) when bunkMargin < 0.
  int get _mustAttend {
    if (subject.bunkMargin >= 0) return 0;
    // Need attended+x >= 0.75*(total+x)  →  x >= (0.75t - a) / 0.25
    return ((0.75 * subject.total - subject.attended) / 0.25).ceil();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = _statusColor(cs);
    final pct = subject.percentage;
    final isSafe = subject.isSafe;
    final isLab = subject.type == 'Lab';

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: icon + name + percentage badge ──────────────────────
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isLab ? cs.secondaryContainer : cs.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isLab ? Icons.science_rounded : Icons.menu_book_rounded,
                  size: 22,
                  color: isLab
                      ? cs.onSecondaryContainer
                      : cs.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        _TypeChip(
                          label: subject.type,
                          bg: isLab
                              ? cs.secondaryContainer
                              : cs.primaryContainer,
                          fg: isLab
                              ? cs.onSecondaryContainer
                              : cs.onPrimaryContainer,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${subject.attended}/${subject.total} classes',
                          style: TextStyle(
                            fontSize: 11,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Percentage badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: color.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Text(
                  '${pct.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Progress bar ─────────────────────────────────────────────────
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: (pct / 100).clamp(0.0, 1.0),
                  backgroundColor: color.withValues(alpha: 0.10),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 10,
                ),
              ),
              // 75% marker
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (ctx, bc) => Stack(
                    children: [
                      Positioned(
                        left: bc.maxWidth * 0.75 - 1,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: 2,
                          decoration: BoxDecoration(
                            color: cs.onSurface.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '0%',
                style: TextStyle(fontSize: 9, color: cs.onSurfaceVariant),
              ),
              Text(
                '75% required',
                style: TextStyle(fontSize: 9, color: cs.onSurfaceVariant),
              ),
              Text(
                '100%',
                style: TextStyle(fontSize: 9, color: cs.onSurfaceVariant),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Verdict banner ───────────────────────────────────────────────
          isSafe
              ? _VerdictBanner(
                  icon: Icons.beach_access_rounded,
                  iconColor: cs.secondary,
                  bg: cs.secondaryContainer.withValues(alpha: 0.6),
                  fg: cs.onSecondaryContainer,
                  title: _canSkip == 0
                      ? 'Just at the limit — no margin left'
                      : 'You can skip $_canSkip more class${_canSkip != 1 ? "es" : ""}',
                  subtitle: _canSkip == 0
                      ? 'Attend every class to stay safe.'
                      : 'Skipping more than $_canSkip will drop you below 75%.',
                )
              : _VerdictBanner(
                  icon: Icons.local_fire_department_rounded,
                  iconColor: cs.error,
                  bg: cs.errorContainer.withValues(alpha: 0.6),
                  fg: cs.onErrorContainer,
                  title: 'Attend $_mustAttend more class${_mustAttend != 1 ? "es" : ""} to recover',
                  subtitle:
                      'You are ${(75 - pct).toStringAsFixed(1)}% below the required 75%.',
                ),

          // ── Future projection chips ──────────────────────────────────────
          const SizedBox(height: 12),
          _ProjectionRow(subject: subject),
        ],
      ),
    );
  }
}

// ── Verdict Banner ────────────────────────────────────────────────────────────

class _VerdictBanner extends StatelessWidget {
  final IconData icon;
  final Color iconColor, bg, fg;
  final String title, subtitle;

  const _VerdictBanner({
    required this.icon,
    required this.iconColor,
    required this.bg,
    required this.fg,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: fg,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: fg.withValues(alpha: 0.8),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Projection Row ────────────────────────────────────────────────────────────
// Shows what attendance looks like after attending N more consecutive classes.

class _ProjectionRow extends StatelessWidget {
  final Subject subject;
  const _ProjectionRow({required this.subject});

  double _projectedPct(int extra) {
    if (subject.total + extra == 0) return 0;
    return ((subject.attended + extra) / (subject.total + extra)) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'If you attend next…',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: cs.onSurfaceVariant,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [1, 3, 5, 10].map((n) {
            final proj = _projectedPct(n);
            final isSafe = proj >= 75;
            final color = isSafe ? cs.secondary : cs.error;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: color.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '+$n',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${proj.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: color,
                        ),
                      ),
                      Icon(
                        isSafe
                            ? Icons.check_rounded
                            : Icons.close_rounded,
                        size: 12,
                        color: color,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ── Type Chip ─────────────────────────────────────────────────────────────────

class _TypeChip extends StatelessWidget {
  final String label;
  final Color bg, fg;
  const _TypeChip({required this.label, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bunk Predictor'),
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.onPrimaryContainer,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.bar_chart_rounded,
                  size: 44,
                  color: cs.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No subjects yet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Add subjects on the Home screen first.\nThe predictor will calculate your bunk margins automatically.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: cs.onSurfaceVariant,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 32),
              OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Go back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
