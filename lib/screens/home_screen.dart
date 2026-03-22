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

  double get _overallPercentage {
    final attended = mockSubjects.fold(0, (sum, s) => sum + s.attended);
    final total    = mockSubjects.fold(0, (sum, s) => sum + s.total);
    return total == 0 ? 0 : (attended / total) * 100;
  }

  int get _grandTotal => mockSubjects.fold(0, (sum, s) => sum + s.total);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BUNK-O-METER'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            tooltip: 'Bunk Predictor',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.bunkPredictor),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        children: [
          _OverallCard(percentage: _overallPercentage),
          const SizedBox(height: 12),
          _QuickStatsRow(subjects: mockSubjects),
          const SizedBox(height: 20),
          Text('Your Subjects', style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 10),
          ...mockSubjects.map((s) => _SubjectCard(subject: s, grandTotal: _grandTotal)),
          const SizedBox(height: 80),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAddSubjectSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Subject'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.black,
      ),
    );
  }
}

// ── Overall Card ──────────────────────────────────────────────────────────────

class _OverallCard extends StatelessWidget {
  final double percentage;
  const _OverallCard({required this.percentage});

  Color _statusColor(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (percentage >= 80) return cs.primary;
    if (percentage >= 75) return Colors.orange;
    return cs.error;
  }

  String get _statusText {
    if (percentage >= 80) return "You're doing great!";
    if (percentage >= 75) return 'Borderline — attend more classes';
    return 'Danger zone! Stop bunking';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _statusColor(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withOpacity(0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            SizedBox(
              width: 80, height: 80,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: percentage / 100,
                    strokeWidth: 7,
                    backgroundColor: color.withOpacity(0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    strokeCap: StrokeCap.round,
                  ),
                  Center(
                    child: Text(
                      '${percentage.toStringAsFixed(0)}%',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Overall Attendance', style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 6),
                  Text(_statusText,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: color)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.flag_outlined, size: 13,
                          color: theme.textTheme.bodyMedium?.color),
                      const SizedBox(width: 4),
                      Text('Min required: 75%',
                          style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12)),
                    ],
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

// ── Quick Stats Row ───────────────────────────────────────────────────────────

class _QuickStatsRow extends StatelessWidget {
  final List<MockSubject> subjects;
  const _QuickStatsRow({required this.subjects});

  @override
  Widget build(BuildContext context) {
    final cs     = Theme.of(context).colorScheme;
    final total  = subjects.length;
    final safe   = subjects.where((s) => s.percentage >= 80).length;
    final danger = subjects.where((s) => s.percentage < 75).length;

    return Row(
      children: [
        _StatChip(value: '$total',  label: 'Subjects', color: const Color(0xFFE0E0E0)),
        const SizedBox(width: 8),
        _StatChip(value: '$safe',   label: 'Safe',     color: cs.primary),
        const SizedBox(width: 8),
        _StatChip(value: '$danger', label: 'At Risk',  color: cs.error),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String value, label;
  final Color color;
  const _StatChip({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withOpacity(0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            children: [
              Text(value,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
              const SizedBox(height: 2),
              Text(label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Subject Card ──────────────────────────────────────────────────────────────

class _SubjectCard extends StatelessWidget {
  final MockSubject subject;
  final int grandTotal;
  const _SubjectCard({required this.subject, required this.grandTotal});

  Color _statusColor(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (subject.percentage >= 80) return cs.primary;
    if (subject.percentage >= 75) return Colors.orange;
    return cs.error;
  }

  IconData get _icon =>
      subject.type == 'Lab' ? Icons.science_outlined : Icons.menu_book_outlined;

  double get _subjectImpact => subject.total == 0 ? 0 : (1 / subject.total) * 100;
  double get _overallImpact => grandTotal == 0 ? 0 : (1 / grandTotal) * 100;

  Color _badgeColor(BuildContext context, double impact) {
    final cs = Theme.of(context).colorScheme;
    if (impact >= 7) return cs.error;
    if (impact >= 4) return Colors.orange;
    return cs.primary;
  }

  @override
  Widget build(BuildContext context) {
    final theme             = Theme.of(context);
    final color             = _statusColor(context);
    final subjectBadgeColor = _badgeColor(context, _subjectImpact);
    final overallBadgeColor = _badgeColor(context, _overallImpact);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.white.withOpacity(0.08)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.12),
          child: Icon(_icon, color: color, size: 20),
        ),
        title: Text(subject.name,
            style: theme.textTheme.bodyLarge?.copyWith(fontSize: 15)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 3),
            Text(
              '${subject.type}  ·  ${subject.attended}/${subject.total} classes',
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                _ImpactBadge(
                  label: 'Subject',
                  value: '−${_subjectImpact.toStringAsFixed(1)}%',
                  color: subjectBadgeColor,
                ),
                const SizedBox(width: 6),
                _ImpactBadge(
                  label: 'Overall',
                  value: '−${_overallImpact.toStringAsFixed(2)}%',
                  color: overallBadgeColor,
                ),
              ],
            ),
          ],
        ),
        isThreeLine: true,
        trailing: SizedBox(
          width: 64,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${subject.percentage.toStringAsFixed(0)}%',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
              const SizedBox(height: 5),
              LinearProgressIndicator(
                value: subject.percentage / 100,
                backgroundColor: Colors.white.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 4,
                borderRadius: BorderRadius.circular(2),
              ),
            ],
          ),
        ),
        onTap: () => Navigator.pushNamed(
          context,
          AppRoutes.subjectDetail,
          arguments: subject.name,
        ),
      ),
    );
  }
}

// ── Impact Badge ──────────────────────────────────────────────────────────────

class _ImpactBadge extends StatelessWidget {
  final String label, value;
  final Color color;
  const _ImpactBadge({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label  ',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w400, color: color.withOpacity(0.7)),
            ),
            TextSpan(
              text: value,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color),
            ),
          ],
        ),
      ),
    );
  }
}