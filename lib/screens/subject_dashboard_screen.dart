// lib/screens/subject_dashboard_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
// Subject attendance dashboard — driven entirely by a live Hive [Subject]
// object passed from the previous screen.  All mutations call
// [widget.subject.save()] so changes are persisted immediately.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:proxy/models/subject.dart';
import 'package:proxy/themes/theme.dart'; // exposes AttendanceColors

// ── Screen ───────────────────────────────────────────────────────────────────

class SubjectDashboardScreen extends StatefulWidget {
  /// The live Hive [Subject] object injected by the calling screen.
  final Subject subject;

  const SubjectDashboardScreen({super.key, required this.subject});

  @override
  State<SubjectDashboardScreen> createState() => _SubjectDashboardScreenState();
}

class _SubjectDashboardScreenState extends State<SubjectDashboardScreen>
    with TickerProviderStateMixin {

  late AnimationController _progressCtrl;
  late AnimationController _cardCtrl;
  late Animation<double> _progressAnim;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _cardCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _progressAnim = Tween<double>(begin: 0, end: widget.subject.percentage / 100)
        .animate(CurvedAnimation(parent: _progressCtrl, curve: Curves.easeOutCubic));
    _fadeAnim = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOut));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOut));

    _progressCtrl.forward();
    _cardCtrl.forward();
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    _cardCtrl.dispose();
    super.dispose();
  }

  // ── Attendance actions ───────────────────────────────────────────────────

  void _markPresent() {
    HapticFeedback.mediumImpact();
    // Cache previous state for undo
    final prevAttended = widget.subject.attended;
    final prevTotal = widget.subject.total;
    setState(() {
      widget.subject.attended += 1;
      widget.subject.total += 1;
      widget.subject.save(); // persist to Hive box
      _animateProgress();
    });
    _showSnack(
      '✓ Marked Present',
      Theme.of(context).colorScheme.secondary,
      onUndo: () {
        setState(() {
          widget.subject.attended = prevAttended;
          widget.subject.total = prevTotal;
          widget.subject.save();
          _animateProgress();
        });
      },
    );
  }

  void _markAbsent() {
    HapticFeedback.mediumImpact();
    // Cache previous state for undo
    final prevAttended = widget.subject.attended;
    final prevTotal = widget.subject.total;
    setState(() {
      widget.subject.total += 1;
      widget.subject.save(); // persist to Hive box
      _animateProgress();
    });
    _showSnack(
      '✗ Marked Absent',
      Theme.of(context).colorScheme.error,
      onUndo: () {
        setState(() {
          widget.subject.attended = prevAttended;
          widget.subject.total = prevTotal;
          widget.subject.save();
          _animateProgress();
        });
      },
    );
  }

  void _animateProgress() {
    _progressCtrl.reset();
    _progressAnim = Tween<double>(begin: 0, end: widget.subject.percentage / 100)
        .animate(CurvedAnimation(parent: _progressCtrl, curve: Curves.easeOutCubic));
    _progressCtrl.forward();
  }

  void _showSnack(String msg, Color color, {VoidCallback? onUndo}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 4),
      action: onUndo != null
          ? SnackBarAction(
              label: 'UNDO',
              textColor: Colors.white,
              onPressed: onUndo,
            )
          : null,
    ));
  }

  // ── Bunk predictor calculations ──────────────────────────────────────────

  int get _canBunk {
    final maxTotal = (widget.subject.attended / 0.75).floor();
    final canSkip = maxTotal - widget.subject.total;
    return canSkip < 0 ? 0 : canSkip;
  }

  int get _needsToAttend {
    if (widget.subject.percentage >= 75) return 0;
    final needed =
        ((0.75 * widget.subject.total - widget.subject.attended) / 0.25).ceil();
    return needed < 0 ? 0 : needed;
  }

  double _afterPresent(int n) {
    if (widget.subject.total + n == 0) return 0;
    return ((widget.subject.attended + n) / (widget.subject.total + n)) * 100;
  }

  double _afterAbsent(int n) {
    if (widget.subject.total + n == 0) return 0;
    return (widget.subject.attended / (widget.subject.total + n)) * 100;
  }

  // ── Computed stats ───────────────────────────────────────────────────────

  double get _hoursAttended => widget.subject.attended * widget.subject.durationHours;
  double get _totalHours    => widget.subject.total    * widget.subject.durationHours;
  int    get _missed        => widget.subject.total - widget.subject.attended;

  // ── Theming helpers ──────────────────────────────────────────────────────

  Color _statusColor(BuildContext context) =>
      AttendanceColors.forPercentage(widget.subject.percentage);

  String get _statusLabel {
    final p = widget.subject.percentage;
    if (p >= 85) return 'Safe Zone';
    if (p >= 75) return 'On Track';
    return 'Danger Zone';
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 20),
                FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: Column(
                      children: [
                        _buildProgressCard(context),
                        const SizedBox(height: 16),
                        _buildStatsRow(context),
                        const SizedBox(height: 16),
                        _buildStatusBanner(context),
                        const SizedBox(height: 16),
                        _buildMarkAttendanceCard(context),
                        const SizedBox(height: 16),
                        _buildBunkPredictorCard(context),
                        const SizedBox(height: 16),
                        _buildSubjectInfoCard(context),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ── Sliver App Bar ───────────────────────────────────────────────────────

  SliverAppBar _buildAppBar(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: cs.surface,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        color: cs.onSurface,
      ),
      actions: [
        IconButton(
          onPressed: _showOptionsSheet,
          icon: const Icon(Icons.more_vert_rounded),
          color: cs.onSurfaceVariant,
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsetsDirectional.only(
          start: 56,
          bottom: 14,
          end: 16,
        ),
        centerTitle: false,
        title: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.bottomLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                widget.subject.name,
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _TypeChip(type: widget.subject.type),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      '${widget.subject.attended}/${widget.subject.total} classes',
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
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


  // ── Progress Card ────────────────────────────────────────────────────────

  Widget _buildProgressCard(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final statusColor = _statusColor(context);
    return _Card(
      child: Row(
        children: [
          SizedBox(
            width: 110,
            height: 110,
            child: AnimatedBuilder(
              animation: _progressAnim,
              builder: (context, _) => Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox.expand(
                    child: CircularProgressIndicator(
                      value: _progressAnim.value,
                      strokeWidth: 10,
                      backgroundColor: cs.outline,
                      valueColor: AlwaysStoppedAnimation(statusColor),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${widget.subject.percentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1,
                        ),
                      ),
                      Text(
                        _statusLabel,
                        style: TextStyle(
                          color: statusColor.withValues(alpha: 0.7),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(
                  icon: Icons.check_circle_outline_rounded,
                  label: 'Attended',
                  value: '${widget.subject.attended} classes',
                  color: cs.secondary,
                ),
                const SizedBox(height: 12),
                _InfoRow(
                  icon: Icons.cancel_outlined,
                  label: 'Missed',
                  value: '$_missed classes',
                  color: cs.error,
                ),
                const SizedBox(height: 12),
                _InfoRow(
                  icon: Icons.event_note_rounded,
                  label: 'Total',
                  value: '${widget.subject.total} classes',
                  color: cs.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Stats Row ────────────────────────────────────────────────────────────

  Widget _buildStatsRow(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.access_time_rounded,
            label: 'Hrs\nAttended',
            value: '${_hoursAttended.toStringAsFixed(1)}h',
            color: cs.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.hourglass_bottom_rounded,
            label: 'Total\nHours',
            value: '${_totalHours.toStringAsFixed(1)}h',
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.timer_outlined,
            label: 'Per\nClass',
            value: '${widget.subject.durationHours}h',
            color: AttendanceColors.borderline,
          ),
        ),
      ],
    );
  }

  // ── Status Banner ────────────────────────────────────────────────────────

  Widget _buildStatusBanner(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final safe = widget.subject.percentage >= 75;
    final icon = safe
        ? (_canBunk > 0 ? Icons.check_circle_rounded : Icons.warning_amber_rounded)
        : Icons.error_rounded;

    final Color color;
    if (!safe) {
      color = cs.error;
    } else if (_canBunk > 0) {
      color = cs.secondary;
    } else {
      color = AttendanceColors.borderline;
    }

    final text = safe
        ? (_canBunk > 0
            ? 'You can bunk $_canBunk more class${_canBunk > 1 ? 'es' : ''}'
            : 'You\'re at the edge! Don\'t miss any class')
        : 'Attend $_needsToAttend more class${_needsToAttend > 1 ? 'es' : ''} to reach 75%';
    final subtext = safe
        ? (_canBunk > 0
            ? 'Attendance stays ≥ 75% after bunking'
            : 'One absence drops you below 75%')
        : 'Your attendance is below the required threshold';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text,
                    style: TextStyle(
                        color: color, fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(subtext,
                    style: TextStyle(
                        color: color.withValues(alpha: 0.7),
                        fontSize: 11,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Mark Attendance Card ─────────────────────────────────────────────────

  Widget _buildMarkAttendanceCard(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mark Today\'s Attendance',
              style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 15,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Update attendance for the last conducted class',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _AttendanceButton(
                  label: 'Present',
                  icon: Icons.check_rounded,
                  color: cs.secondary,
                  onTap: _markPresent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _AttendanceButton(
                  label: 'Absent',
                  icon: Icons.close_rounded,
                  color: cs.error,
                  onTap: _markAbsent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Bunk Predictor Card ──────────────────────────────────────────────────

  Widget _buildBunkPredictorCard(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final rows = [
      ('After +1 present', _afterPresent(1)),
      ('After +3 present', _afterPresent(3)),
      ('After +1 absent',  _afterAbsent(1)),
      ('After +3 absent',  _afterAbsent(3)),
    ];

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_graph_rounded, color: cs.primary, size: 18),
              const SizedBox(width: 8),
              Text('Bunk Predictor',
                  style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 15,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 16),
          ...rows.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildPredictorRow(context, r.$1, r.$2),
              )),
        ],
      ),
    );
  }

  Widget _buildPredictorRow(BuildContext context, String label, double percentage) {
    final cs = Theme.of(context).colorScheme;
    final color = percentage >= 75 ? cs.secondary : cs.error;
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(label,
              style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
        ),
        Expanded(
          flex: 4,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (percentage / 100).clamp(0.0, 1.0),
              backgroundColor: cs.outline,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 44,
          child: Text(
            '${percentage.toStringAsFixed(1)}%',
            textAlign: TextAlign.right,
            style: TextStyle(
                color: color, fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  // ── Subject Info Card ────────────────────────────────────────────────────

  Widget _buildSubjectInfoCard(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Subject Info',
              style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 15,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          _DetailRow(label: 'Subject Name',     value: widget.subject.name),
          _DetailRow(label: 'Type',             value: widget.subject.type),
          _DetailRow(label: 'Class Duration',   value: '${widget.subject.durationHours} hours'),
          _DetailRow(label: 'Classes Attended', value: '${widget.subject.attended}'),
          _DetailRow(label: 'Classes Held',     value: '${widget.subject.total}'),
          _DetailRow(label: 'Required Minimum', value: '75%', isLast: true),
        ],
      ),
    );
  }

  // ── Bottom Sheet ─────────────────────────────────────────────────────────

  void _showOptionsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: null,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        final cs = Theme.of(context).colorScheme;
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.edit_rounded, color: cs.primary),
                title: Text('Edit Subject',
                    style: TextStyle(color: cs.onSurface)),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: Icon(Icons.refresh_rounded,
                    color: AttendanceColors.borderline),
                title: Text('Reset Attendance',
                    style: TextStyle(color: AttendanceColors.borderline)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    widget.subject.attended = 0;
                    widget.subject.total = 0;
                    widget.subject.save(); // persist reset to Hive
                    _animateProgress();
                  });
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_outline_rounded, color: cs.error),
                title: Text('Delete Subject',
                    style: TextStyle(color: cs.error)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pop(context); // go back to list
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Reusable sub-widgets (all private, file-scoped)
// ═══════════════════════════════════════════════════════════════════════════

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outline),
      ),
      child: child,
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String type;
  const _TypeChip({required this.type});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLab = type == 'Lab';
    final color = isLab ? cs.primary : AttendanceColors.borderline;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        type,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _InfoRow(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(
                color: cs.onSurfaceVariant,
                fontSize: 11,
                fontWeight: FontWeight.w500)),
        const Spacer(),
        Text(value,
            style: TextStyle(
                color: color, fontSize: 13, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatCard(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 10,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _AttendanceButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _AttendanceButton(
      {required this.label,
      required this.icon,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2)),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;
  const _DetailRow(
      {required this.label, required this.value, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Text(label,
                  style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
              const Spacer(),
              Text(value,
                  style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        if (!isLast) Divider(color: cs.outline, height: 1, thickness: 1),
      ],
    );
  }
}
