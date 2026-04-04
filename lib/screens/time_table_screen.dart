// lib/screens/timetable_screen.dart
import 'package:flutter/material.dart';

// ── Mock data ─────────────────────────────────────────────────────────────────

class TimetableSlot {
  final String subjectName;
  final String type; // 'Theory' | 'Lab' | 'Elective'
  final String time;
  final String duration;
  final int attended;
  final int total;

  const TimetableSlot({
    required this.subjectName,
    required this.type,
    required this.time,
    required this.duration,
    required this.attended,
    required this.total,
  });

  double get percentage => total == 0 ? 0 : (attended / total) * 100;
}

const Map<int, List<TimetableSlot>> mockTimetable = {
  1: [
    TimetableSlot(
      subjectName: 'Data Structures',
      type: 'Theory',
      time: '9:00 AM',
      duration: '1h',
      attended: 38,
      total: 46,
    ),
    TimetableSlot(
      subjectName: 'Java Lab',
      type: 'Lab',
      time: '11:00 AM',
      duration: '2h',
      attended: 27,
      total: 39,
    ),
    TimetableSlot(
      subjectName: 'DBMS',
      type: 'Theory',
      time: '1:00 PM',
      duration: '1h',
      attended: 31,
      total: 41,
    ),
    TimetableSlot(
      subjectName: 'Software Engg',
      type: 'Theory',
      time: '3:00 PM',
      duration: '1h',
      attended: 44,
      total: 48,
    ),
  ],
  2: [
    TimetableSlot(
      subjectName: 'Computer Networks',
      type: 'Theory',
      time: '10:00 AM',
      duration: '1h',
      attended: 29,
      total: 38,
    ),
    TimetableSlot(
      subjectName: 'DBMS',
      type: 'Theory',
      time: '12:00 PM',
      duration: '1h',
      attended: 31,
      total: 41,
    ),
    TimetableSlot(
      subjectName: 'OS Lab',
      type: 'Lab',
      time: '2:00 PM',
      duration: '2h',
      attended: 22,
      total: 32,
    ),
  ],
  3: [
    TimetableSlot(
      subjectName: 'Data Structures',
      type: 'Theory',
      time: '9:00 AM',
      duration: '1h',
      attended: 38,
      total: 46,
    ),
    TimetableSlot(
      subjectName: 'Software Engg',
      type: 'Theory',
      time: '10:00 AM',
      duration: '1h',
      attended: 44,
      total: 48,
    ),
    TimetableSlot(
      subjectName: 'Operating Systems',
      type: 'Theory',
      time: '12:00 PM',
      duration: '1h',
      attended: 14,
      total: 20,
    ),
    TimetableSlot(
      subjectName: 'Open Elective',
      type: 'Elective',
      time: '3:00 PM',
      duration: '1h',
      attended: 18,
      total: 22,
    ),
  ],
  4: [
    TimetableSlot(
      subjectName: 'Computer Networks',
      type: 'Theory',
      time: '11:00 AM',
      duration: '1h',
      attended: 29,
      total: 38,
    ),
    TimetableSlot(
      subjectName: 'Java Lab',
      type: 'Lab',
      time: '2:00 PM',
      duration: '2h',
      attended: 27,
      total: 39,
    ),
  ],
  5: [
    TimetableSlot(
      subjectName: 'Data Structures',
      type: 'Theory',
      time: '9:00 AM',
      duration: '1h',
      attended: 38,
      total: 46,
    ),
    TimetableSlot(
      subjectName: 'DBMS',
      type: 'Theory',
      time: '11:00 AM',
      duration: '1h',
      attended: 31,
      total: 41,
    ),
    TimetableSlot(
      subjectName: 'Operating Systems',
      type: 'Theory',
      time: '12:00 PM',
      duration: '1h',
      attended: 14,
      total: 20,
    ),
    TimetableSlot(
      subjectName: 'OS Lab',
      type: 'Lab',
      time: '2:00 PM',
      duration: '2h',
      attended: 22,
      total: 32,
    ),
  ],
  6: [],
  7: [],
};

// ── Screen ────────────────────────────────────────────────────────────────────

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final DateTime _today = DateTime.now();
  late int _selectedWeekday;
  bool _isWeekView = false;

  @override
  void initState() {
    super.initState();
    _selectedWeekday = _today.weekday;
    _tabCtrl = TabController(length: 2, vsync: this);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) {
        setState(() => _isWeekView = _tabCtrl.index == 1);
      }
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  DateTime get _weekStart {
    final diff = _today.weekday - 1;
    return DateTime(_today.year, _today.month, _today.day - diff);
  }

  List<TimetableSlot> get _selectedSlots =>
      mockTimetable[_selectedWeekday] ?? [];

  String get _monthLabel {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[_today.month]} ${_today.year}';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final mq = MediaQuery.of(context);
    final textScale = mq.textScaler.scale(1.0);
    final statusBarH = mq.padding.top;

    // Heights for the bottom widget sub-components
    final tabBarHeight = 48.0 * textScale;
    final weekStripHeight = 70.0 * textScale;

    // When in week view, the _WeekStrip collapses away (via AnimatedSize)
    // so we exclude its height + gap from the layout math.
    final bottomBarHeight = _isWeekView
        ? tabBarHeight +
              8 +
              10 // tab bar + top gap + bottom gap
        : tabBarHeight + 8 + weekStripHeight + 10; // + week strip

    // Subtitle content area: month label + "Your weekly schedule" + padding
    final subtitleAreaHeight = (80.0 * textScale).clamp(70.0, 120.0);

    // expandedHeight = toolbar + subtitle area + bottom widget
    // This guarantees the subtitle sits between the toolbar and
    // the bottom widget with zero overlap.
    final expandedHeight =
        kToolbarHeight + subtitleAreaHeight + bottomBarHeight;

    return Scaffold(
      backgroundColor: cs.surface,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: expandedHeight,
            pinned: true,
            floating: false,
            forceElevated: innerBoxIsScrolled,
            backgroundColor: cs.primaryContainer,
            surfaceTintColor: Colors.transparent,
            foregroundColor: cs.onPrimaryContainer,
            // Built-in title — renders in the toolbar area and
            // stays visible when collapsed.
            title: Text(
              'Timetable',
              style: TextStyle(
                color: cs.onPrimaryContainer,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
            centerTitle: false,
            actions: [
              IconButton(
                icon: Icon(Icons.today_rounded, color: cs.onPrimaryContainer),
                tooltip: 'Go to today',
                onPressed: () =>
                    setState(() => _selectedWeekday = _today.weekday),
              ),
              SizedBox(width: mq.size.width * 0.02),
            ],
            // Manual flexibleSpace — positions the subtitle text
            // precisely between the toolbar and the bottom widget.
            // No FlexibleSpaceBar: avoids its internal title-positioning
            // logic which was causing the collision.
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                // constraints.maxHeight = current visible height of
                // the SliverAppBar (shrinks as user scrolls up).
                // Fade out the subtitle as the app bar collapses.
                final currentHeight = constraints.maxHeight;
                final fullyExpanded = expandedHeight + statusBarH;
                final collapsed = kToolbarHeight + statusBarH + bottomBarHeight;
                final expansionFraction =
                    ((currentHeight - collapsed) / (fullyExpanded - collapsed))
                        .clamp(0.0, 1.0);

                return Container(
                  color: cs.primaryContainer,
                  child: Stack(
                    clipBehavior: Clip.hardEdge,
                    children: [
                      // Subtitle text — anchored from the bottom only.
                      // No top constraint: avoids the shrinking-box
                      // overflow that occurred when the SliverAppBar
                      // collapsed and crushed the vertical space.
                      Positioned(
                        left: 20,
                        right: 80,
                        bottom: bottomBarHeight + 8,
                        height: subtitleAreaHeight,
                        child: ClipRect(
                          child: Opacity(
                            opacity: expansionFraction,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _monthLabel,
                                  style: TextStyle(
                                    color: cs.onPrimaryContainer.withValues(
                                      alpha: 0.7,
                                    ),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Your weekly schedule',
                                  style: TextStyle(
                                    color: cs.onPrimaryContainer,
                                    fontSize: 22 * textScale.clamp(0.8, 1.3),
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(bottomBarHeight),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // View toggle pills
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: mq.size.width * 0.04,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: cs.onPrimaryContainer.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.all(3),
                      child: TabBar(
                        controller: _tabCtrl,
                        indicator: BoxDecoration(
                          color: cs.surface,
                          borderRadius: BorderRadius.circular(17),
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        labelColor: cs.primary,
                        unselectedLabelColor: cs.onPrimaryContainer.withValues(
                          alpha: 0.75,
                        ),
                        labelStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                        tabs: const [
                          Tab(text: 'Day view'),
                          Tab(text: 'Week view'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Smoothly collapse the week strip when in Week view
                  // to avoid showing duplicate day headers.
                  AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    alignment: Alignment.topCenter,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _isWeekView ? 0.0 : 1.0,
                      child: _isWeekView
                          ? const SizedBox.shrink()
                          : _WeekStrip(
                              today: _today,
                              weekStart: _weekStart,
                              selectedWeekday: _selectedWeekday,
                              timetable: mockTimetable,
                              onDayTap: (wd) =>
                                  setState(() => _selectedWeekday = wd),
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabCtrl,
          children: [
            _DayView(
              weekday: _selectedWeekday,
              today: _today,
              slots: _selectedSlots,
            ),
            _WeekGridView(
              timetable: mockTimetable,
              today: _today,
              weekStart: _weekStart,
              onCellTap: (wd) {
                setState(() {
                  _selectedWeekday = wd;
                  _tabCtrl.animateTo(0);
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Week Strip ────────────────────────────────────────────────────────────────

class _WeekStrip extends StatelessWidget {
  final DateTime today;
  final DateTime weekStart;
  final int selectedWeekday;
  final Map<int, List<TimetableSlot>> timetable;
  final ValueChanged<int> onDayTap;

  const _WeekStrip({
    required this.today,
    required this.weekStart,
    required this.selectedWeekday,
    required this.timetable,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: List.generate(7, (i) {
          final wd = i + 1;
          final date = weekStart.add(Duration(days: i));
          final isToday =
              date.day == today.day &&
              date.month == today.month &&
              date.year == today.year;
          final isSel = wd == selectedWeekday;
          final hasSlots = (timetable[wd] ?? []).isNotEmpty;

          return Expanded(
            child: GestureDetector(
              onTap: () => onDayTap(wd),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: isSel
                      ? cs.onPrimaryContainer.withValues(alpha: 0.36)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      dayLabels[i],
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: cs.onPrimaryContainer.withValues(alpha: 0.65),
                      ),
                    ),
                    const SizedBox(height: 3),
                    isToday
                        ? Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: cs.secondary,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${date.day}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: cs.onSecondary,
                              ),
                            ),
                          )
                        : Text(
                            '${date.day}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: cs.onPrimaryContainer.withValues(
                                alpha: isSel ? 1.0 : 0.8,
                              ),
                            ),
                          ),
                    const SizedBox(height: 4),
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: hasSlots
                            ? cs.onPrimaryContainer.withValues(alpha: 0.5)
                            : Colors.transparent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Day View ──────────────────────────────────────────────────────────────────

class _DayView extends StatelessWidget {
  final int weekday;
  final DateTime today;
  final List<TimetableSlot> slots;

  const _DayView({
    required this.weekday,
    required this.today,
    required this.slots,
  });

  bool get _isToday => weekday == today.weekday;

  String get _dayTitle {
    const names = [
      '',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return _isToday ? 'Today — ${names[weekday]}' : names[weekday];
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final bottomPad = MediaQuery.of(context).padding.bottom;

    if (slots.isEmpty) return _EmptyDay(isWeekend: weekday >= 6);

    return ListView(
      padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPad + 80),
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _dayTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Chip(
                label: Text(
                  '${slots.length} class${slots.length != 1 ? "es" : ""}',
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
        ),
        ...List.generate(
          slots.length,
          (i) => _TimelineSlot(slot: slots[i], isLast: i == slots.length - 1),
        ),
      ],
    );
  }
}

// ── Timeline Slot ─────────────────────────────────────────────────────────────

enum _LogStatus { none, attended, bunked }

class _TimelineSlot extends StatefulWidget {
  final TimetableSlot slot;
  final bool isLast;
  const _TimelineSlot({required this.slot, required this.isLast});

  @override
  State<_TimelineSlot> createState() => _TimelineSlotState();
}

class _TimelineSlotState extends State<_TimelineSlot> {
  _LogStatus _status = _LogStatus.none;

  /// Derives slot styling entirely from the theme's ColorScheme.
  /// - Theory  → primary family
  /// - Lab     → secondary (emerald) family
  /// - Elective → tertiary family
  _SlotStyle _style(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    switch (widget.slot.type) {
      case 'Lab':
        return _SlotStyle(
          accent: cs.secondary,
          bg: cs.surfaceContainerLow,
          fg: cs.onSurface,
          chipBg: cs.secondaryContainer,
          chipFg: cs.onSecondaryContainer,
        );
      case 'Elective':
        return _SlotStyle(
          accent: cs.tertiary,
          bg: cs.surfaceContainerLow,
          fg: cs.onSurface,
          chipBg: cs.tertiaryContainer,
          chipFg: cs.onTertiaryContainer,
        );
      default:
        return _SlotStyle(
          accent: cs.primary,
          bg: cs.surfaceContainerLow,
          fg: cs.onSurface,
          chipBg: cs.primaryContainer,
          chipFg: cs.onPrimaryContainer,
        );
    }
  }

  /// Attendance percentage text color — derived from theme semantic tokens.
  Color _pctColor(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final p = widget.slot.percentage;
    if (p >= 80) return cs.secondary; // safe — emerald
    if (p >= 75) return cs.tertiary; // borderline — amber/tertiary
    return cs.error; // danger
  }

  /// Attendance percentage background — derived from theme containers.
  Color _pctBg(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final p = widget.slot.percentage;
    if (p >= 80) return cs.secondaryContainer;
    if (p >= 75) return cs.tertiaryContainer;
    return cs.errorContainer;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final style = _style(context);
    final pct = widget.slot.percentage.toStringAsFixed(0);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time column — uses constrained width via intrinsic sizing
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 48, maxWidth: 64),
            child: Padding(
              padding: const EdgeInsets.only(top: 16, right: 8),
              child: Text(
                widget.slot.time,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
          ),

          // Timeline line + dot
          Column(
            children: [
              const SizedBox(height: 18),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _status == _LogStatus.attended
                      ? cs.secondary
                      : _status == _LogStatus.bunked
                      ? cs.error
                      : style.accent,
                  shape: BoxShape.circle,
                ),
              ),
              if (!widget.isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: cs.outlineVariant,
                    margin: const EdgeInsets.symmetric(vertical: 3),
                  ),
                ),
            ],
          ),

          const SizedBox(width: 12),

          // Card — expands to fill remaining space
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: style.accent.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.slot.subjectName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: style.fg,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Chips row — Wrap ensures no overflow on tiny screens
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _Chip(
                          label: widget.slot.type,
                          bg: style.chipBg,
                          fg: style.chipFg,
                        ),
                        _Chip(
                          label: widget.slot.duration,
                          bg: style.chipBg,
                          fg: style.chipFg,
                          icon: Icons.schedule_rounded,
                          iconColor: style.accent,
                        ),
                        // Attendance % pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _pctBg(context),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$pct%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: _pctColor(context),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Mark buttons
                    _status == _LogStatus.none
                        ? Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => setState(
                                    () => _status = _LogStatus.attended,
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: cs.secondary,
                                    backgroundColor: Colors.transparent,
                                    side: BorderSide(
                                      color: cs.secondary.withValues(
                                        alpha: 0.6,
                                      ),
                                      width: 1.5,
                                    ),
                                    minimumSize: const Size(0, 42),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: EdgeInsets.zero,
                                    textStyle: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  child: const Text('😇  Attended'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => setState(
                                    () => _status = _LogStatus.bunked,
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: cs.error,
                                    backgroundColor: Colors.transparent,
                                    side: BorderSide(
                                      color: cs.error.withValues(
                                        alpha: 0.6,
                                      ),
                                      width: 1.5,
                                    ),
                                    minimumSize: const Size(0, 42),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: EdgeInsets.zero,
                                    textStyle: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  child: const Text('😈  Bunked'),
                                ),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: Container(
                                  constraints: const BoxConstraints(
                                    minHeight: 40,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _status == _LogStatus.attended
                                        ? cs.secondaryContainer
                                        : cs.errorContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 8,
                                  ),
                                  child: Text(
                                    _status == _LogStatus.attended
                                        ? '😇  Marked present'
                                        : '😈  Marked as bunked',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: _status == _LogStatus.attended
                                          ? cs.onSecondaryContainer
                                          : cs.onErrorContainer,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  minHeight: 40,
                                ),
                                child: OutlinedButton(
                                  onPressed: () =>
                                      setState(() => _status = _LogStatus.none),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: style.fg,
                                    side: BorderSide(
                                      color: style.accent.withValues(
                                        alpha: 0.4,
                                      ),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                    ),
                                    textStyle: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  child: const Text('Undo'),
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper: simple chip widget used in the slot card
class _Chip extends StatelessWidget {
  final String label;
  final Color bg, fg;
  final IconData? icon;
  final Color? iconColor;
  const _Chip({
    required this.label,
    required this.bg,
    required this.fg,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: iconColor ?? fg),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

class _SlotStyle {
  final Color accent, bg, fg, chipBg, chipFg;
  const _SlotStyle({
    required this.accent,
    required this.bg,
    required this.fg,
    required this.chipBg,
    required this.chipFg,
  });
}

// ── Empty Day ─────────────────────────────────────────────────────────────────

class _EmptyDay extends StatelessWidget {
  final bool isWeekend;
  const _EmptyDay({required this.isWeekend});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isWeekend
                    ? Icons.weekend_rounded
                    : Icons.event_available_rounded,
                size: 38,
                color: cs.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isWeekend ? 'Weekend!' : 'No classes today',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isWeekend
                  ? 'Sit back and relax — enjoy your break.'
                  : 'Nothing scheduled. Enjoy the free day!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: cs.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Week Grid View ────────────────────────────────────────────────────────────

class _WeekGridView extends StatelessWidget {
  final Map<int, List<TimetableSlot>> timetable;
  final DateTime today;
  final DateTime weekStart;
  final ValueChanged<int> onCellTap;

  const _WeekGridView({
    required this.timetable,
    required this.today,
    required this.weekStart,
    required this.onCellTap,
  });

  static const _timeSlots = [
    '9 AM',
    '10 AM',
    '11 AM',
    '12 PM',
    '1 PM',
    '2 PM',
    '3 PM',
    '4 PM',
  ];
  static const _timeKeys = [
    '9:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '1:00 PM',
    '2:00 PM',
    '3:00 PM',
    '4:00 PM',
  ];
  static const _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  /// Minimum cell width below which we enable horizontal scroll
  static const double _minCellWidth = 40.0;

  TimetableSlot? _slotAt(int weekday, String timeKey) =>
      (timetable[weekday] ?? []).where((s) => s.time == timeKey).firstOrNull;

  /// Slot background — dark elevated surface so pills pop against
  /// the primaryContainer header when the grid scrolls underneath.
  Color _slotBg(TimetableSlot s, BuildContext ctx) {
    return Theme.of(ctx).colorScheme.surfaceContainerHigh;
  }

  /// Slot text color — bright accent per type for high readability.
  Color _slotFg(TimetableSlot s, BuildContext ctx) {
    final cs = Theme.of(ctx).colorScheme;
    if (s.type == 'Lab') return cs.secondary;
    if (s.type == 'Elective') return cs.tertiary;
    return cs.primary;
  }

  /// Slot border — 1px accent-colored outline for sharp recognition.
  Color _slotBorderColor(TimetableSlot s, BuildContext ctx) {
    final cs = Theme.of(ctx).colorScheme;
    if (s.type == 'Lab') return cs.secondary;
    if (s.type == 'Elective') return cs.tertiary;
    return cs.primary;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;

        // Reserve gutter width proportional to available space
        // (minimum 40, max 56px) to keep time labels readable
        final gutterW = (availableWidth * 0.12).clamp(40.0, 56.0);

        // Compute the cell width from remaining space
        final columnsSpace = availableWidth - gutterW - 16; // 16 = h-padding
        final computedCellW = columnsSpace / 7;

        // If computed cell width is too tight, force a minimum and scroll
        final cellW = computedCellW < _minCellWidth
            ? _minCellWidth
            : computedCellW;
        final needsHScroll = computedCellW < _minCellWidth;

        final totalWidth = gutterW + cellW * 7 + 16;

        Widget gridContent = SizedBox(
          width: needsHScroll ? totalWidth : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header row ──────────────────────────────────────────
              Row(
                children: [
                  SizedBox(width: gutterW),
                  ...List.generate(7, (i) {
                    final date = weekStart.add(Duration(days: i));
                    final isToday =
                        date.day == today.day &&
                        date.month == today.month &&
                        date.year == today.year;
                    return SizedBox(
                      width: needsHScroll ? cellW : null,
                      child: needsHScroll
                          ? _buildHeaderColumn(i, date, isToday, cs)
                          : Expanded(
                              child: _buildHeaderColumn(i, date, isToday, cs),
                            ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 8),
              Container(height: 0.5, color: cs.outlineVariant),
              const SizedBox(height: 4),

              // ── Time rows ────────────────────────────────────────────
              ...List.generate(_timeSlots.length, (ti) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: gutterW,
                        child: Text(
                          _timeSlots[ti],
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 9,
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      ...List.generate(7, (di) {
                        final wd = di + 1;
                        final slot = _slotAt(wd, _timeKeys[ti]);
                        final date = weekStart.add(Duration(days: di));
                        final isToday =
                            date.day == today.day &&
                            date.month == today.month &&
                            date.year == today.year;

                        final cellContent = Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 1.5),
                          child: slot != null
                              ? GestureDetector(
                                  onTap: () => onCellTap(wd),
                                  child: Container(
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: _slotBg(slot, context),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: isToday
                                            ? cs.error
                                            : _slotBorderColor(
                                                slot,
                                                context,
                                              ).withValues(alpha: 0.6),
                                        width: isToday ? 1.5 : 1,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 2,
                                    ),
                                    child: Text(
                                      slot.subjectName
                                          .split(' ')
                                          .map((w) => w.isNotEmpty ? w[0] : '')
                                          .take(3)
                                          .join(),
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: _slotFg(slot, context),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                )
                              : Container(
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: isToday
                                        ? cs.error.withValues(alpha: 0.08)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(6),
                                    border: isToday
                                        ? Border.all(
                                            color: cs.error.withValues(
                                              alpha: 0.3,
                                            ),
                                            width: 1,
                                          )
                                        : null,
                                  ),
                                ),
                        );

                        if (needsHScroll) {
                          return SizedBox(width: cellW, child: cellContent);
                        }
                        return Expanded(child: cellContent);
                      }),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 16),

              // ── Legend ────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _LegendDot(color: cs.primary, label: 'Theory'),
                  const SizedBox(width: 16),
                  _LegendDot(color: cs.secondary, label: 'Lab'),
                  const SizedBox(width: 16),
                  _LegendDot(color: cs.tertiary, label: 'Elective'),
                ],
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Tap a cell to see that day\'s full schedule',
                  style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                ),
              ),
            ],
          ),
        );

        // If we don't need horizontal scroll, just wrap in a vertical scroll
        if (!needsHScroll) {
          // When columns fit, we don't need a fixed SizedBox — let Expanded
          // children in Row distribute evenly.
          gridContent = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header row ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    SizedBox(width: gutterW),
                    ...List.generate(7, (i) {
                      final date = weekStart.add(Duration(days: i));
                      final isToday =
                          date.day == today.day &&
                          date.month == today.month &&
                          date.year == today.year;
                      return Expanded(
                        child: _buildHeaderColumn(i, date, isToday, cs),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Container(height: 0.5, color: cs.outlineVariant),
              ),
              const SizedBox(height: 4),

              // ── Time rows ────────────────────────────────────────────
              ...List.generate(_timeSlots.length, (ti) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 2,
                    horizontal: 8,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: gutterW,
                        child: Text(
                          _timeSlots[ti],
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 9,
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      ...List.generate(7, (di) {
                        final wd = di + 1;
                        final slot = _slotAt(wd, _timeKeys[ti]);
                        final date = weekStart.add(Duration(days: di));
                        final isToday =
                            date.day == today.day &&
                            date.month == today.month &&
                            date.year == today.year;

                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 1.5,
                            ),
                            child: slot != null
                                ? GestureDetector(
                                    onTap: () => onCellTap(wd),
                                    child: Container(
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: _slotBg(slot, context),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: isToday
                                              ? cs.error
                                              : _slotBorderColor(
                                                  slot,
                                                  context,
                                                ).withValues(alpha: 0.6),
                                          width: isToday ? 1.5 : 1,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 2,
                                      ),
                                      child: Text(
                                        slot.subjectName
                                            .split(' ')
                                            .map(
                                              (w) => w.isNotEmpty ? w[0] : '',
                                            )
                                            .take(3)
                                            .join(),
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          color: _slotFg(slot, context),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  )
                                : Container(
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: isToday
                                          ? cs.error.withValues(alpha: 0.08)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(6),
                                      border: isToday
                                          ? Border.all(
                                              color: cs.error.withValues(
                                                alpha: 0.3,
                                              ),
                                              width: 1,
                                            )
                                          : null,
                                    ),
                                  ),
                          ),
                        );
                      }),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 16),

              // ── Legend ────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _LegendDot(color: cs.primary, label: 'Theory'),
                  const SizedBox(width: 16),
                  _LegendDot(color: cs.secondary, label: 'Lab'),
                  const SizedBox(width: 16),
                  _LegendDot(color: cs.tertiary, label: 'Elective'),
                ],
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Tap a cell to see that day\'s full schedule',
                  style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                ),
              ),
            ],
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          padding: EdgeInsets.fromLTRB(0, 12, 0, bottomPad + 80),
          child: needsHScroll
              ? SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: gridContent,
                )
              : gridContent,
        );
      },
    );
  }

  /// Builds a single header column (day label + date number).
  Widget _buildHeaderColumn(
    int index,
    DateTime date,
    bool isToday,
    ColorScheme cs,
  ) {
    return Column(
      children: [
        Text(
          _dayLabels[index],
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: isToday ? cs.error : cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        isToday
            ? Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: cs.error,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${date.day}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: cs.onError,
                  ),
                ),
              )
            : Text(
                '${date.day}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
