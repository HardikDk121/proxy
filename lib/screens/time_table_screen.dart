// lib/screens/timetable_screen.dart
import 'package:flutter/material.dart';

// ── Mock data ─────────────────────────────────────────────────────────────────

class TimetableSlot {
  final String subjectName;
  final String type; // 'Theory' | 'Lab' | 'Elective'
  final String time; // e.g. '9:00 AM'
  final String duration; // e.g. '1h' | '2h'
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

// weekday → list of slots  (DateTime.weekday: 1=Mon … 7=Sun)
const Map<int, List<TimetableSlot>> mockTimetable = {
  1: [
    TimetableSlot(subjectName: 'Data Structures',  type: 'Theory',   time: '9:00 AM',  duration: '1h', attended: 38, total: 46),
    TimetableSlot(subjectName: 'Java Lab',         type: 'Lab',      time: '11:00 AM', duration: '2h', attended: 27, total: 39),
    TimetableSlot(subjectName: 'DBMS',             type: 'Theory',   time: '1:00 PM',  duration: '1h', attended: 31, total: 41),
    TimetableSlot(subjectName: 'Software Engg',    type: 'Theory',   time: '3:00 PM',  duration: '1h', attended: 44, total: 48),
  ],
  2: [
    TimetableSlot(subjectName: 'Computer Networks',type: 'Theory',   time: '10:00 AM', duration: '1h', attended: 29, total: 38),
    TimetableSlot(subjectName: 'DBMS',             type: 'Theory',   time: '12:00 PM', duration: '1h', attended: 31, total: 41),
    TimetableSlot(subjectName: 'OS Lab',           type: 'Lab',      time: '2:00 PM',  duration: '2h', attended: 22, total: 32),
  ],
  3: [
    TimetableSlot(subjectName: 'Data Structures',  type: 'Theory',   time: '9:00 AM',  duration: '1h', attended: 38, total: 46),
    TimetableSlot(subjectName: 'Software Engg',    type: 'Theory',   time: '10:00 AM', duration: '1h', attended: 44, total: 48),
    TimetableSlot(subjectName: 'Operating Systems',type: 'Theory',   time: '12:00 PM', duration: '1h', attended: 14, total: 20),
    TimetableSlot(subjectName: 'Open Elective',    type: 'Elective', time: '3:00 PM',  duration: '1h', attended: 18, total: 22),
  ],
  4: [
    TimetableSlot(subjectName: 'Computer Networks',type: 'Theory',   time: '11:00 AM', duration: '1h', attended: 29, total: 38),
    TimetableSlot(subjectName: 'Java Lab',         type: 'Lab',      time: '2:00 PM',  duration: '2h', attended: 27, total: 39),
  ],
  5: [
    TimetableSlot(subjectName: 'Data Structures',  type: 'Theory',   time: '9:00 AM',  duration: '1h', attended: 38, total: 46),
    TimetableSlot(subjectName: 'DBMS',             type: 'Theory',   time: '11:00 AM', duration: '1h', attended: 31, total: 41),
    TimetableSlot(subjectName: 'Operating Systems',type: 'Theory',   time: '12:00 PM', duration: '1h', attended: 14, total: 20),
    TimetableSlot(subjectName: 'OS Lab',           type: 'Lab',      time: '2:00 PM',  duration: '2h', attended: 22, total: 32),
  ],
  6: [], // Saturday — no classes
  7: [], // Sunday  — no classes
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
  late int _selectedWeekday; // 1–7

  // Week view vs Day view
  bool _isWeekView = false;

  @override
  void initState() {
    super.initState();
    _selectedWeekday = _today.weekday; // 1=Mon … 7=Sun
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

  // Monday of current week
  DateTime get _weekStart {
    final diff = _today.weekday - 1; // weekday 1=Mon
    return DateTime(_today.year, _today.month, _today.day - diff);
  }

  DateTime _dayForWeekday(int wd) =>
      _weekStart.add(Duration(days: wd - 1));

  List<TimetableSlot> get _selectedSlots =>
      mockTimetable[_selectedWeekday] ?? [];

  String get _monthLabel {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[_today.month]} ${_today.year}';
  }

  @override
  Widget build(BuildContext context) {
    final cs    = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          // ── SliverAppBar (matches HomeScreen style) ────────────────────
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            floating: false,
            backgroundColor: cs.primaryContainer,
            surfaceTintColor: Colors.transparent,
            // Ensure action icons are always visible
            foregroundColor: cs.onPrimaryContainer,
            actions: [
              // Jump to today
              IconButton(
                icon: Icon(Icons.today_rounded, color: cs.onPrimaryContainer),
                tooltip: 'Go to today',
                onPressed: () => setState(() {
                  _selectedWeekday = _today.weekday;
                }),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(20, 0, 72, 14),
              title: Text(
                'Timetable',
                style: TextStyle(
                  color: cs.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
              background: Padding(
                padding: const EdgeInsets.fromLTRB(20, 60, 80, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _monthLabel,
                      style: TextStyle(
                        color: cs.onPrimaryContainer.withOpacity(0.7),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Your weekly schedule',
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
            // ── Day / Week tab bar ───────────────────────────────────────
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(130),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // View toggle pills
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: cs.onPrimaryContainer.withOpacity(0.12),
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
                        unselectedLabelColor:
                            cs.onPrimaryContainer.withOpacity(0.75),
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
                  // Week strip
                  _WeekStrip(
                    today: _today,
                    weekStart: _weekStart,
                    selectedWeekday: _selectedWeekday,
                    timetable: mockTimetable,
                    onDayTap: (wd) => setState(() => _selectedWeekday = wd),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),

          // ── Body: Day or Week view ─────────────────────────────────────
          SliverFillRemaining(
            hasScrollBody: true,
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                // Day view
                _DayView(
                  weekday: _selectedWeekday,
                  today: _today,
                  slots: _selectedSlots,
                ),
                // Week view
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
        ],
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
          final wd      = i + 1; // 1=Mon … 7=Sun
          final date    = weekStart.add(Duration(days: i));
          final isToday = date.day == today.day &&
              date.month == today.month &&
              date.year == today.year;
          final isSel   = wd == selectedWeekday;
          final hasSlots = (timetable[wd] ?? []).isNotEmpty;

          return Expanded(
            child: GestureDetector(
              onTap: () => onDayTap(wd),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSel
                      ? cs.onPrimaryContainer.withOpacity(0.18)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Day letter
                    Text(
                      dayLabels[i],
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: cs.onPrimaryContainer.withOpacity(0.65),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Date number — today gets a filled circle
                    isToday
                        ? Container(
                            width: 28, height: 28,
                            decoration: BoxDecoration(
                              color: cs.surface,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${date.day}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: cs.primary,
                              ),
                            ),
                          )
                        : Text(
                            '${date.day}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: cs.onPrimaryContainer.withOpacity(
                                isSel ? 1.0 : 0.8,
                              ),
                            ),
                          ),
                    const SizedBox(height: 5),
                    // Dot for days that have classes
                    Container(
                      width: 5, height: 5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: hasSlots
                            ? cs.onPrimaryContainer.withOpacity(0.5)
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
    const names = ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final name = names[weekday];
    return _isToday ? 'Today — $name' : name;
  }

  @override
  Widget build(BuildContext context) {
    final cs    = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return slots.isEmpty
        ? _EmptyDay(isWeekend: weekday >= 6)
        : ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            children: [
              // Day header
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

              // Timeline
              ...List.generate(slots.length, (i) {
                final isLast = i == slots.length - 1;
                return _TimelineSlot(
                  slot: slots[i],
                  isLast: isLast,
                );
              }),
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

  _SlotStyle _style(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    switch (widget.slot.type) {
      case 'Lab':
        return _SlotStyle(
          accent: const Color(0xFF7C5800),
          bg: cs.surfaceContainerLow,
          fg: cs.onSurface,
          chipBg: const Color(0xFFFFDEA8),
          chipFg: const Color(0xFF261900),
        );
      case 'Elective':
        return _SlotStyle(
          accent: cs.tertiary,
          bg: cs.surfaceContainerLow,
          fg: cs.onSurface,
          chipBg: cs.tertiaryContainer,
          chipFg: cs.onTertiaryContainer,
        );
      default: // Theory
        return _SlotStyle(
          accent: cs.primary,
          bg: cs.surfaceContainerLow,
          fg: cs.onSurface,
          chipBg: cs.primaryContainer,
          chipFg: cs.onPrimaryContainer,
        );
    }
  }

  Color _pctColor(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final p  = widget.slot.percentage;
    if (p >= 80) return cs.primary;
    if (p >= 75) return const Color(0xFF7C5800);
    return cs.error;
  }

  Color _pctBg(BuildContext context) {
    final p = widget.slot.percentage;
    if (p >= 80) return Theme.of(context).colorScheme.primaryContainer;
    if (p >= 75) return const Color(0xFFFFDEA8);
    return Theme.of(context).colorScheme.errorContainer;
  }

  @override
  Widget build(BuildContext context) {
    final cs    = Theme.of(context).colorScheme;
    final style = _style(context);
    final pct   = widget.slot.percentage.toStringAsFixed(0);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time column
          SizedBox(
            width: 54,
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
                width: 12, height: 12,
                decoration: BoxDecoration(
                  color: _status == _LogStatus.attended
                      ? cs.primary
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

          // Slot card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: style.bg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border(
                    left: BorderSide(color: style.accent, width: 3),
                  ),
                ),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subject name
                    Text(
                      widget.slot.subjectName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: style.fg,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Type + duration + % row
                    Row(
                      children: [
                        // Type chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 3),
                          decoration: BoxDecoration(
                            color: style.chipBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.slot.type,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: style.chipFg,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Duration chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 3),
                          decoration: BoxDecoration(
                            color: style.chipBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.schedule_rounded,
                                  size: 10, color: style.accent),
                              const SizedBox(width: 3),
                              Text(
                                widget.slot.duration,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: style.chipFg,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        // Attendance % pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
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

                    // ── Attended / Bunked buttons ─────────────────────
                    _status == _LogStatus.none
                        ? Row(
                            children: [
                              // Attended button — success green
                              Expanded(
                                child: FilledButton(
                                  onPressed: () => setState(
                                      () => _status = _LogStatus.attended),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFF146C2E),
                                    foregroundColor: Colors.white,
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
                              // Bunked button — error red
                              Expanded(
                                child: FilledButton(
                                  onPressed: () => setState(
                                      () => _status = _LogStatus.bunked),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: cs.error,
                                    foregroundColor: cs.onError,
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
                              // Logged status pill
                              Expanded(
                                child: Container(
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: _status == _LogStatus.attended
                                        ? cs.primaryContainer
                                        : cs.errorContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    _status == _LogStatus.attended
                                        ? '😇  Marked present'
                                        : '😈  Marked as bunked',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: _status == _LogStatus.attended
                                          ? cs.onPrimaryContainer
                                          : cs.onErrorContainer,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Undo button
                              SizedBox(
                                height: 40,
                                child: OutlinedButton(
                                  onPressed: () => setState(
                                      () => _status = _LogStatus.none),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: style.fg,
                                    side: BorderSide(
                                        color: style.accent.withOpacity(0.4)),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14),
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
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isWeekend ? Icons.weekend_rounded : Icons.event_available_rounded,
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
    '9 AM', '10 AM', '11 AM', '12 PM',
    '1 PM', '2 PM', '3 PM', '4 PM',
  ];
  static const _timeKeys = [
    '9:00 AM', '10:00 AM', '11:00 AM', '12:00 PM',
    '1:00 PM', '2:00 PM', '3:00 PM', '4:00 PM',
  ];
  static const _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  TimetableSlot? _slotAt(int weekday, String timeKey) {
    return (timetable[weekday] ?? [])
        .where((s) => s.time == timeKey)
        .firstOrNull;
  }

  Color _slotBg(TimetableSlot s, BuildContext ctx) {
    final cs = Theme.of(ctx).colorScheme;
    if (s.type == 'Lab')      return const Color(0xFFFFDEA8);
    if (s.type == 'Elective') return cs.tertiaryContainer;
    return cs.primaryContainer;
  }

  Color _slotFg(TimetableSlot s, BuildContext ctx) {
    final cs = Theme.of(ctx).colorScheme;
    if (s.type == 'Lab')      return const Color(0xFF261900);
    if (s.type == 'Elective') return cs.onTertiaryContainer;
    return cs.onPrimaryContainer;
  }

  @override
  Widget build(BuildContext context) {
    final cs    = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 100),
      child: Column(
        children: [
          // ── Header row ──────────────────────────────────────────────
          Row(
            children: [
              // Time gutter
              const SizedBox(width: 42),
              ...List.generate(7, (i) {
                final wd      = i + 1;
                final date    = weekStart.add(Duration(days: i));
                final isToday = date.day == today.day &&
                    date.month == today.month &&
                    date.year == today.year;
                return Expanded(
                  child: Column(
                    children: [
                      Text(
                        _dayLabels[i],
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: isToday ? cs.primary : cs.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      isToday
                          ? Container(
                              width: 22, height: 22,
                              decoration: BoxDecoration(
                                color: cs.primary,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${date.day}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: cs.onPrimary,
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
                            ),
                    ],
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 8),
          Container(height: 0.5, color: cs.outlineVariant),
          const SizedBox(height: 4),

          // ── Time rows ───────────────────────────────────────────────
          ...List.generate(_timeSlots.length, (ti) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Time label gutter
                  SizedBox(
                    width: 42,
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
                  // Day cells
                  ...List.generate(7, (di) {
                    final wd   = di + 1;
                    final slot = _slotAt(wd, _timeKeys[ti]);
                    final date = weekStart.add(Duration(days: di));
                    final isToday = date.day == today.day &&
                        date.month == today.month &&
                        date.year == today.year;

                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 1.5),
                        child: slot != null
                            ? GestureDetector(
                                onTap: () => onCellTap(wd),
                                child: Container(
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: _slotBg(slot, context),
                                    borderRadius: BorderRadius.circular(6),
                                    border: isToday
                                        ? Border.all(color: cs.primary, width: 1.5)
                                        : null,
                                  ),
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(horizontal: 2),
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
                                      ? cs.primary.withOpacity(0.05)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(6),
                                  border: isToday
                                      ? Border.all(
                                          color: cs.primary.withOpacity(0.2),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendDot(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  label: 'Theory',
                ),
                const SizedBox(width: 16),
                const _LegendDot(
                  color: Color(0xFFFFDEA8),
                  label: 'Lab',
                ),
                const SizedBox(width: 16),
                _LegendDot(
                  color: Theme.of(context).colorScheme.tertiaryContainer,
                  label: 'Elective',
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
          Text(
            'Tap a cell to see that day\'s full schedule',
            style: TextStyle(
              fontSize: 11,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
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
          width: 12, height: 12,
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