// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import '../widgets/add_subject_screen.dart';

// ── Static mock data ──────────────────────────────────────────────────────────
class MockSubject {
  final String name;
  final String type;
  final int attended;
  final int total;
  const MockSubject({
    required this.name,
    required this.type,
    required this.attended,
    required this.total,
  });
  double get percentage => total == 0 ? 0 : (attended / total) * 100;
}

const mockSubjects = [
  MockSubject(name: 'Data Structures',   type: 'Theory', attended: 22, total: 27),
  MockSubject(name: 'Operating Systems', type: 'Theory', attended: 14, total: 20),
  MockSubject(name: 'OS Lab',            type: 'Lab',    attended: 9,  total: 13),
  MockSubject(name: 'Computer Networks', type: 'Theory', attended: 10, total: 16),
  MockSubject(name: 'DBMS',              type: 'Theory', attended: 18, total: 22),
  MockSubject(name: 'DBMS Lab',          type: 'Lab',    attended: 7,  total: 10),
];
// ─────────────────────────────────────────────────────────────────────────────

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  double get _overallPct {
    final attended = mockSubjects.fold(0, (s, e) => s + e.attended);
    final total    = mockSubjects.fold(0, (s, e) => s + e.total);
    return total == 0 ? 0 : (attended / total) * 100;
  }

  // Friendly greeting based on time of day
  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning 👋';
    if (h < 17) return 'Good afternoon 👋';
    return 'Good evening 👋';
  }

  @override
  Widget build(BuildContext context) {
    final cs    = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          // ── Large app bar with greeting ───────────────────────────────
          SliverAppBar(
            expandedHeight: 160,
            floating: false,
            pinned: true,
            backgroundColor: cs.primaryContainer,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
              title: Text(
                'Proxy',
                style: TextStyle(
                  color: cs.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
              background: Padding(
                padding: const EdgeInsets.fromLTRB(20, 56, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting,
                      style: TextStyle(
                        color: cs.onPrimaryContainer.withOpacity(0.75),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Here\'s your attendance',
                      style: TextStyle(
                        color: cs.onPrimaryContainer,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.bar_chart_rounded, color: cs.onPrimaryContainer),
                tooltip: 'Bunk Predictor',
                onPressed: () => Navigator.pushNamed(context, AppRoutes.bunkPredictor),
              ),
              const SizedBox(width: 4),
            ],
          ),

          // ── Body content ──────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Overall attendance card
                _OverallCard(percentage: _overallPct),
                const SizedBox(height: 12),

                // Quick stats: Total / Safe / At Risk
                _QuickStatsRow(subjects: mockSubjects),
                const SizedBox(height: 12),

                // ── Timetable shortcut ────────────────────────────────
                _TimetableBanner(),
                const SizedBox(height: 24),

                // Section label
                Row(
                  children: [
                    Text(
                      'Your Subjects',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text(
                        '${mockSubjects.length}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: cs.onSecondaryContainer,
                        ),
                      ),
                      backgroundColor: cs.secondaryContainer,
                      side: BorderSide.none,
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // ── Single card with ListTiles + Dividers ─────────────
                Card(
                  elevation: 0,
                  color: cs.surfaceContainerLow,
                  shape:  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      for (int i = 0; i < mockSubjects.length; i++) ...[
                        _SubjectListTile(subject: mockSubjects[i]),
                        if (i < mockSubjects.length - 1)
                          Divider(
                            height: 1,
                            indent: 72,
                            endIndent: 16,
                            color: cs.outlineVariant.withOpacity(0.5),
                          ),
                      ],
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),

      // ── FAB ──────────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAddSubjectSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Subject',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

// ── Overall Attendance Card ───────────────────────────────────────────────────

class _OverallCard extends StatelessWidget {
  final double percentage;
  const _OverallCard({required this.percentage});

  _StatusInfo _info(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (percentage >= 80) {
      return _StatusInfo(
        color: cs.primary,
        containerColor: cs.primaryContainer,
        onContainerColor: cs.onPrimaryContainer,
        icon: Icons.sentiment_very_satisfied_rounded,
        message: "You're doing great! Keep it up 🎉",
      );
    }
    if (percentage >= 75) {
      return _StatusInfo(
        color: const Color(0xFF7C5800),
        containerColor: const Color(0xFFFFDEA8),
        onContainerColor: const Color(0xFF261900),
        icon: Icons.sentiment_neutral_rounded,
        message: 'Borderline — attend a few more classes',
      );
    }
    return _StatusInfo(
      color: cs.error,
      containerColor: cs.errorContainer,
      onContainerColor: cs.onErrorContainer,
      icon: Icons.sentiment_very_dissatisfied_rounded,
      message: 'Danger zone! Stop bunking now',
    );
  }

  @override
  Widget build(BuildContext context) {
    final info = _info(context);

    return Card(
      elevation: 0,
      color: info.containerColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Circular progress ring
            SizedBox(
              width: 80, height: 80,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: percentage / 100,
                    strokeWidth: 7,
                    backgroundColor: info.color.withOpacity(0.18),
                    valueColor: AlwaysStoppedAnimation<Color>(info.color),
                    strokeCap: StrokeCap.round,
                  ),
                  Center(
                    child: Text(
                      '${percentage.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: info.color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Overall Attendance',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: info.onContainerColor.withOpacity(0.65),
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(info.icon, size: 18, color: info.color),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          info.message,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: info.onContainerColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Mini progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: info.color.withOpacity(0.18),
                      valueColor: AlwaysStoppedAnimation<Color>(info.color),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Minimum required: 75%',
                    style: TextStyle(
                      fontSize: 11,
                      color: info.onContainerColor.withOpacity(0.55),
                    ),
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

class _StatusInfo {
  final Color color, containerColor, onContainerColor;
  final IconData icon;
  final String message;
  const _StatusInfo({
    required this.color,
    required this.containerColor,
    required this.onContainerColor,
    required this.icon,
    required this.message,
  });
}

// ── Quick Stats Row ───────────────────────────────────────────────────────────

class _QuickStatsRow extends StatelessWidget {
  final List<MockSubject> subjects;
  const _QuickStatsRow({required this.subjects});

  @override
  Widget build(BuildContext context) {
    final cs     = Theme.of(context).colorScheme;
    final safe   = subjects.where((s) => s.percentage >= 75).length;
    final danger = subjects.where((s) => s.percentage < 75).length;

    return Row(
      children: [
        _StatTile(
          value: '${subjects.length}',
          label: 'Total',
          icon: Icons.list_alt_rounded,
          bgColor: cs.surfaceContainerHighest,
          fgColor: cs.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        _StatTile(
          value: '$safe',
          label: 'Safe',
          icon: Icons.check_circle_rounded,
          bgColor: cs.primaryContainer,
          fgColor: cs.onPrimaryContainer,
        ),
        const SizedBox(width: 8),
        _StatTile(
          value: '$danger',
          label: 'At Risk',
          icon: Icons.warning_rounded,
          bgColor: cs.errorContainer,
          fgColor: cs.onErrorContainer,
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final Color bgColor, fgColor;
  const _StatTile({
    required this.value,
    required this.label,
    required this.icon,
    required this.bgColor,
    required this.fgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 0,
        color: bgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          child: Column(
            children: [
              Icon(icon, color: fgColor, size: 20),
              const SizedBox(height: 5),
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: fgColor,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: fgColor.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Subject List Tile ─────────────────────────────────────────────────────────

class _SubjectListTile extends StatelessWidget {
  final MockSubject subject;
  const _SubjectListTile({required this.subject});

  Color _accentColor(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (subject.percentage >= 80) return cs.primary;
    if (subject.percentage >= 75) return const Color(0xFF7C5800);
    return cs.error;
  }

  Color _accentBg(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (subject.percentage >= 80) return cs.primaryContainer;
    if (subject.percentage >= 75) return const Color(0xFFFFDEA8);
    return cs.errorContainer;
  }

  IconData get _statusIcon {
    if (subject.percentage >= 80) return Icons.check_circle_rounded;
    if (subject.percentage >= 75) return Icons.warning_rounded;
    return Icons.error_rounded;
  }

  String _bunkInfo() {
    final margin = subject.attended - (0.75 * subject.total).ceil();
    if (margin > 0) return 'Can bunk $margin more';
    if (margin == 0) return 'Attend to stay safe';
    return 'Need ${-margin} more classes';
  }

  @override
  Widget build(BuildContext context) {
    final cs     = Theme.of(context).colorScheme;
    final color  = _accentColor(context);
    final bg     = _accentBg(context);
    final isLab  = subject.type == 'Lab';
    final iconBg = isLab ? const Color(0xFFFFDEA8) : cs.primaryContainer;
    final iconFg = isLab ? const Color(0xFF7C5800) : cs.onPrimaryContainer;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.subjectDashboard
        
      ),

      // ── Leading: rounded icon ─────────────────────────────────────────
      leading: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: iconBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          isLab ? Icons.science_rounded : Icons.menu_book_rounded,
          color: iconFg,
          size: 22,
        ),
      ),

      // ── Title + subtitle ──────────────────────────────────────────────
      title: Text(
        subject.name,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: cs.onSurface,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 3),
          // Type chip + class count
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isLab
                      ? const Color(0xFFFFDEA8)
                      : cs.secondaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  subject.type,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isLab
                        ? const Color(0xFF7C5800)
                        : cs.onSecondaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${subject.attended}/${subject.total} classes',
                style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 5),
          // Bunk info row
          Row(
            children: [
              Icon(_statusIcon, size: 12, color: color),
              const SizedBox(width: 4),
              Text(
                _bunkInfo(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
      isThreeLine: true,

      // ── Trailing: % + progress bar + chevron ─────────────────────────
      trailing: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${subject.percentage.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: subject.percentage / 100,
                backgroundColor: color.withOpacity(0.15),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Timetable Banner ──────────────────────────────────────────────────────────

class _TimetableBanner extends StatelessWidget {
  const _TimetableBanner();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: cs.secondaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: () => Navigator.pushNamed(context, AppRoutes.timetable),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: cs.onSecondaryContainer.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.calendar_month_rounded,
            color: cs.onSecondaryContainer,
            size: 22,
          ),
        ),
        title: Text(
          'View Timetable',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: cs.onSecondaryContainer,
          ),
        ),
        subtitle: Text(
          'See your full weekly schedule',
          style: TextStyle(
            fontSize: 12,
            color: cs.onSecondaryContainer.withOpacity(0.7),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: cs.onSecondaryContainer.withOpacity(0.6),
        ),
      ),
    );
  }
}