// lib/screens/time_table_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
// TimetableScreen — fully wired to Hive via ValueListenableBuilder.
// Slots come from TimetableService (hive box: 'timetable').
// Use the "Edit Timetable" FAB to open the manual Timetable Builder.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/timetable_slot.dart';
import '../models/subject.dart';
import '../services/timetable_service.dart';
import '../services/attendance_service.dart';

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

  // ── Builder Sheet ──────────────────────────────────────────────────────────

  void _showBuilderSheet(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _TimetableBuilderSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<TimetableSlot>>(
      valueListenable: TimetableService.listenable,
      builder: (context, box, _) {
        final timetable = TimetableService.getWeekMap();
        final selectedSlots = timetable[_selectedWeekday] ?? [];

        final cs = Theme.of(context).colorScheme;
        final mq = MediaQuery.of(context);
        final textScale = mq.textScaler.scale(1.0);
        final statusBarH = mq.padding.top;

        final tabBarHeight = 48.0 * textScale;
        final weekStripHeight = 70.0 * textScale;

        final bottomBarHeight = _isWeekView
            ? tabBarHeight + 8 + 10
            : tabBarHeight + 8 + weekStripHeight + 10;

        final subtitleAreaHeight = (80.0 * textScale).clamp(70.0, 120.0);
        final expandedHeight =
            kToolbarHeight + subtitleAreaHeight + bottomBarHeight;

        return Scaffold(
          backgroundColor: cs.surface,
          // ── Edit Timetable FAB ─────────────────────────────────────────────
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showBuilderSheet(context),
            icon: const Icon(Icons.edit_calendar_rounded),
            label: const Text(
              'Edit Timetable',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            elevation: 4,
          ),
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
                  // Clear timetable
                  if (box.isNotEmpty)
                    IconButton(
                      icon: Icon(
                        Icons.delete_sweep_rounded,
                        color: cs.onPrimaryContainer,
                      ),
                      tooltip: 'Clear timetable',
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Clear Timetable?'),
                            content: const Text('All slots will be deleted.'),
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
                                child: const Text('Clear'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await TimetableService.deleteAll();
                        }
                      },
                    ),
                  IconButton(
                    icon: Icon(
                      Icons.today_rounded,
                      color: cs.onPrimaryContainer,
                    ),
                    tooltip: 'Go to today',
                    onPressed: () =>
                        setState(() => _selectedWeekday = _today.weekday),
                  ),
                  SizedBox(width: mq.size.width * 0.02),
                ],
                flexibleSpace: LayoutBuilder(
                  builder: (context, constraints) {
                    final currentHeight = constraints.maxHeight;
                    final fullyExpanded = expandedHeight + statusBarH;
                    final collapsed =
                        kToolbarHeight + statusBarH + bottomBarHeight;
                    final expansionFraction =
                        ((currentHeight - collapsed) /
                                (fullyExpanded - collapsed))
                            .clamp(0.0, 1.0);

                    return Container(
                      color: cs.primaryContainer,
                      child: Stack(
                        clipBehavior: Clip.hardEdge,
                        children: [
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
                                        fontSize:
                                            22 * textScale.clamp(0.8, 1.3),
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
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: mq.size.width * 0.04,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: cs.onPrimaryContainer.withValues(
                              alpha: 0.12,
                            ),
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
                            unselectedLabelColor: cs.onPrimaryContainer
                                .withValues(alpha: 0.75),
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
                                  timetable: timetable,
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
                box.isEmpty
                    ? _EmptyTimetable(
                        onBuildTapped: () => _showBuilderSheet(context),
                      )
                    : _DayView(
                        weekday: _selectedWeekday,
                        today: _today,
                        slots: selectedSlots,
                      ),
                box.isEmpty
                    ? _EmptyTimetable(
                        onBuildTapped: () => _showBuilderSheet(context),
                      )
                    : _WeekGridView(
                        timetable: timetable,
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
      },
    );
  }
}

// ── Empty State ────────────────────────────────────────────────────────────────

class _EmptyTimetable extends StatelessWidget {
  final VoidCallback? onBuildTapped;
  const _EmptyTimetable({this.onBuildTapped});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon circle
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [cs.primaryContainer, cs.secondaryContainer],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calendar_month_rounded,
                size: 44,
                color: cs.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'No classes scheduled yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: cs.onSurface,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Tap the button below to start\nbuilding your weekly timetable.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: cs.onSurfaceVariant,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: onBuildTapped,
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text(
                'Build Timetable',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Timetable Builder Bottom Sheet ────────────────────────────────────────────

class _TimetableBuilderSheet extends StatefulWidget {
  final TimetableSlot? existingSlot;
  const _TimetableBuilderSheet({this.existingSlot});

  @override
  State<_TimetableBuilderSheet> createState() => _TimetableBuilderSheetState();
}

class _TimetableBuilderSheetState extends State<_TimetableBuilderSheet> {
  // ── Static options ─────────────────────────────────────────────────────────
  static const _staticSubjects = ['Lunch Break', 'Free Period / No Lecture'];

  static const _dayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static const _typeOptions = ['Theory', 'Lab', 'Elective', 'Break'];
  static const _durationOptions = ['1h', '2h', '3h', '30min'];

  // ── State ──────────────────────────────────────────────────────────────────
  int _selectedDay = DateTime.now().weekday; // default to today
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  String? _selectedSubject;
  String _selectedType = 'Theory';
  String _selectedDuration = '1h';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingSlot != null) {
      final slot = widget.existingSlot!;
      _selectedDay = slot.day;
      _selectedSubject = slot.subjectName;
      _selectedType = slot.type;
      _selectedDuration = slot.duration;
      final parsedTime = _parseTimeOfDay(slot.time);
      if (parsedTime != null) {
        _selectedTime = parsedTime;
      }
    }
  }

  TimeOfDay? _parseTimeOfDay(String timeStr) {
    try {
      final t = timeStr.trim().toUpperCase();
      final pmBiased = t.endsWith('PM');
      final numPart = t.replaceAll(RegExp(r'[APM\s]'), '');
      final parts = numPart.split(':');
      if (parts.isEmpty) return null;
      int hour = int.tryParse(parts[0]) ?? 0;
      final min = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
      if (pmBiased && hour != 12) hour += 12;
      if (!pmBiased && hour == 12) hour = 0;
      return TimeOfDay(hour: hour, minute: min);
    } catch (_) {
      return null;
    }
  }

  /// Formats a [TimeOfDay] to a human-readable string like "9:15 AM".
  String _formatTime(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final minute = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (ctx, child) {
        // Force dark theme for the time picker
        return Theme(
          data: Theme.of(ctx).copyWith(colorScheme: Theme.of(ctx).colorScheme),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() => _selectedTime = picked);
    }
  }

  bool get _isBreakSubject => _staticSubjects.contains(_selectedSubject);

  // ── Auto-set type when a break subject is chosen ───────────────────────────
  void _onSubjectChanged(String? value) {
    setState(() {
      _selectedSubject = value;
      if (_staticSubjects.contains(value)) {
        _selectedType = 'Break';
      } else if (_selectedType == 'Break') {
        _selectedType = 'Theory';
      }
    });
  }

  int _parseDurationMins(String duration) {
    if (duration == '30min') return 30;
    if (duration == '1h') return 60;
    if (duration == '2h') return 120;
    if (duration == '3h') return 180;
    return 60; // default
  }

  bool _checkOverlap() {
    final Map<int, List<TimetableSlot>> allSlots =
        TimetableService.getWeekMap();
    final daySlots = allSlots[_selectedDay] ?? [];

    final newStartMinutes = _selectedTime.hour * 60 + _selectedTime.minute;
    final newDurationMins = _parseDurationMins(_selectedDuration);
    final newEndMinutes = newStartMinutes + newDurationMins;

    for (final slot in daySlots) {
      if (widget.existingSlot != null && slot.key == widget.existingSlot!.key) {
        continue;
      }
      final slotStartMins = slot.sortKey;
      final slotDurationMins = _parseDurationMins(slot.duration);
      final slotEndMins = slotStartMins + slotDurationMins;

      // Overlap condition:
      if (newStartMinutes < slotEndMins && newEndMinutes > slotStartMins) {
        return true;
      }
    }
    return false;
  }

  // ── Save ───────────────────────────────────────────────────────────────────
  Future<void> _saveSlot() async {
    if (_selectedSubject == null || _selectedSubject!.isEmpty) {
      _showError('Please select a subject or break type.');
      return;
    }

    if (_checkOverlap()) {
      _showError('Error: This time slot overlaps with an existing class.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final formattedTime = _formatTime(_selectedTime);
      final formattedType = _isBreakSubject ? 'Break' : _selectedType;

      if (widget.existingSlot != null) {
        await TimetableService.updateSlot(
          widget.existingSlot!,
          day: _selectedDay,
          subjectName: _selectedSubject!,
          type: formattedType,
          time: formattedTime,
          duration: _selectedDuration,
        );
      } else {
        final slot = TimetableSlot(
          day: _selectedDay,
          subjectName: _selectedSubject!,
          type: formattedType,
          time: formattedTime,
          duration: _selectedDuration,
        );
        await TimetableService.addSlot(slot);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Text(
                  widget.existingSlot != null
                      ? 'Slot updated for ${_dayNames[_selectedDay - 1]}'
                      : 'Slot added for ${_dayNames[_selectedDay - 1]}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        _showError('Failed to save: $e');
      }
    }
  }

  void _showError(String msg) {
    final cs = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: cs.error,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final mq = MediaQuery.of(context);

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag handle ─────────────────────────────────────────────────
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ── Header ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.edit_calendar_rounded,
                    color: cs.onPrimaryContainer,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.existingSlot != null
                            ? 'Edit Timetable Slot'
                            : 'Add Timetable Slot',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        widget.existingSlot != null
                            ? 'Update details for this class slot'
                            : 'Fill in the details for a new class slot',
                        style: TextStyle(
                          fontSize: 12,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: cs.onSurfaceVariant,
                    size: 22,
                  ),
                  onPressed: () => Navigator.pop(context),
                  style: IconButton.styleFrom(
                    backgroundColor: cs.onSurfaceVariant.withValues(
                      alpha: 0.08,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
            child: Divider(color: cs.outlineVariant.withValues(alpha: 0.5)),
          ),

          // ── Form ────────────────────────────────────────────────────────
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: ValueListenableBuilder<Box<Subject>>(
              valueListenable: AttendanceService.listenable,
              builder: (context, subjectBox, _) {
                // Build the combined subject list:
                // Static options first, then all user subjects
                final userSubjects = subjectBox.values
                    .map((s) => s.name)
                    .toList(growable: false);
                final allSubjects = [..._staticSubjects, ...userSubjects];

                // If the current selection is no longer valid, reset
                if (_selectedSubject != null &&
                    !allSubjects.contains(_selectedSubject)) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() => _selectedSubject = null);
                  });
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Row 1: Day + Time ──────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: _DropdownField<int>(
                            label: 'Day',
                            icon: Icons.calendar_today_rounded,
                            value: _selectedDay,
                            items: List.generate(
                              7,
                              (i) => DropdownMenuItem(
                                value: i + 1,
                                child: Text(
                                  _dayNames[i],
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            onChanged: (v) =>
                                setState(() => _selectedDay = v ?? 1),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _SectionLabel(label: 'Time', cs: cs),
                              const SizedBox(height: 6),
                              _TimePickerButton(
                                formattedTime: _formatTime(_selectedTime),
                                onTap: _pickTime,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // ── Subject / Break ────────────────────────────────
                    _SectionLabel(label: 'Subject / Break', cs: cs),
                    const SizedBox(height: 8),
                    _buildSubjectTiles(allSubjects, userSubjects, cs),
                    const SizedBox(height: 14),

                    // ── Row 2: Type + Duration ─────────────────────────
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _SectionLabel(label: 'Type', cs: cs),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _typeOptions
                                    .where((t) => t != 'Break')
                                    .map((t) {
                                      final isSelected =
                                          _selectedType == t &&
                                          !_isBreakSubject;
                                      return ChoiceChip(
                                        label: Text(t),
                                        selected: isSelected,
                                        onSelected: !_isBreakSubject
                                            ? (bool selected) {
                                                if (selected) {
                                                  setState(
                                                    () => _selectedType = t,
                                                  );
                                                }
                                              }
                                            : null,
                                        showCheckmark: false,
                                        labelStyle: TextStyle(
                                          fontSize: 12,
                                          fontWeight: isSelected
                                              ? FontWeight.w700
                                              : FontWeight.w600,
                                          color: isSelected
                                              ? cs.onPrimaryContainer
                                              : cs.onSurfaceVariant,
                                        ),
                                        selectedColor: cs.primaryContainer,
                                        backgroundColor: cs
                                            .surfaceContainerHighest
                                            .withValues(alpha: 0.5),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          side: BorderSide(
                                            color: isSelected
                                                ? cs.primary.withValues(
                                                    alpha: 0.5,
                                                  )
                                                : Colors.transparent,
                                          ),
                                        ),
                                      );
                                    })
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: _DropdownField<String>(
                            label: 'Duration',
                            icon: Icons.timelapse_rounded,
                            value: _selectedDuration,
                            items: _durationOptions
                                .map(
                                  (d) => DropdownMenuItem(
                                    value: d,
                                    child: Text(d),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _selectedDuration = v ?? '1h'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // ── Static subjects note ───────────────────────────
                    if (_isBreakSubject)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(top: 6, bottom: 2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: cs.secondaryContainer.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              size: 14,
                              color: cs.onSecondaryContainer,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Type is auto-set to "Break" for this option.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: cs.onSecondaryContainer,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ),

          // ── Save Button ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _isSaving ? null : _saveSlot,
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: _isSaving
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: cs.onPrimary,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            widget.existingSlot != null
                                ? Icons.save_rounded
                                : Icons.add_circle_outline_rounded,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            widget.existingSlot != null
                                ? 'Save Changes'
                                : 'Add Slot',
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

  Widget _buildSubjectTiles(
    List<String> allSubjects,
    List<String> userSubjects,
    ColorScheme cs,
  ) {
    // ── Section: Breaks ────────────────────────────────────────────────────
    final breakTiles = _staticSubjects.map((s) {
      final isSelected = _selectedSubject == s;
      final icon = s == 'Lunch Break'
          ? Icons.lunch_dining_rounded
          : Icons.free_cancellation_rounded;
      return _SubjectTile(
        label: s,
        icon: icon,
        isSelected: isSelected,
        onTap: () => _onSubjectChanged(s),
      );
    }).toList();

    // ── Section: My Subjects ───────────────────────────────────────────────
    final subjectTiles = userSubjects.map((s) {
      final isSelected = _selectedSubject == s;
      return _SubjectTile(
        label: s,
        icon: Icons.menu_book_rounded,
        isSelected: isSelected,
        onTap: () => _onSubjectChanged(s),
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Breaks group label
        Text(
          'BREAKS',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.4,
            color: cs.onSurfaceVariant.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 6),
        Wrap(spacing: 8, runSpacing: 8, children: breakTiles),
        if (userSubjects.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(
            'MY SUBJECTS',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
              color: cs.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 6),
          Wrap(spacing: 8, runSpacing: 8, children: subjectTiles),
        ] else ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 15,
                  color: cs.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'No subjects yet. Add subjects from the home screen.',
                    style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// ── Reusable Dropdown Field ────────────────────────────────────────────────────

class _DropdownField<T> extends StatelessWidget {
  final String label;
  final IconData icon;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final bool enabled;

  const _DropdownField({
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label: label, cs: cs),
        const SizedBox(height: 6),
        Opacity(
          opacity: enabled ? 1.0 : 0.5,
          child: Container(
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: cs.outline.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: value,
                isExpanded: true,
                items: items,
                onChanged: enabled ? onChanged : null,
                icon: Icon(
                  Icons.expand_more_rounded,
                  color: cs.onSurfaceVariant,
                  size: 18,
                ),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Section Label helper ───────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final ColorScheme cs;
  const _SectionLabel({required this.label, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: cs.onSurfaceVariant,
        letterSpacing: 0.4,
      ),
    );
  }
}

// ── Subject Tile ──────────────────────────────────────────────────────────────

class _SubjectTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _SubjectTile({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final bgColor = isSelected ? cs.primaryContainer : cs.surfaceContainerHigh;
    final fgColor = isSelected ? cs.onPrimaryContainer : cs.onSurfaceVariant;
    final borderColor = isSelected
        ? cs.primary.withValues(alpha: 0.6)
        : cs.outlineVariant.withValues(alpha: 0.4);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? Icons.check_circle_rounded : icon,
                key: ValueKey(isSelected),
                size: 15,
                color: fgColor,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: fgColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Time Picker Button ────────────────────────────────────────────────────────

class _TimePickerButton extends StatelessWidget {
  final String formattedTime;
  final VoidCallback onTap;

  const _TimePickerButton({required this.formattedTime, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: cs.outline.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Icon(Icons.schedule_rounded, size: 16, color: cs.onSurfaceVariant),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                formattedTime,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
            ),
            Icon(
              Icons.expand_more_rounded,
              size: 18,
              color: cs.onSurfaceVariant,
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
  bool _isLogging = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final lastDate = widget.slot.lastLoggedDate;

    if (lastDate != null &&
        lastDate.year == now.year &&
        lastDate.month == now.month &&
        lastDate.day == now.day) {
      if (widget.slot.lastLoggedStatus == 'attended') {
        _status = _LogStatus.attended;
      } else if (widget.slot.lastLoggedStatus == 'bunked') {
        _status = _LogStatus.bunked;
      }
    } else {
      _status = _LogStatus.none;
    }
  }

  // ── Service calls ─────────────────────────────────────────────────

  Future<void> _logAttendance(bool isPresent) async {
    if (_isLogging) return;
    setState(() => _isLogging = true);
    try {
      await AttendanceService.markAttendance(
        widget.slot.subjectName,
        isPresent: isPresent,
      );

      widget.slot.lastLoggedDate = DateTime.now();
      widget.slot.lastLoggedStatus = isPresent ? 'attended' : 'bunked';
      widget.slot.save();

      if (mounted) {
        setState(() {
          _status = isPresent ? _LogStatus.attended : _LogStatus.bunked;
          _isLogging = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLogging = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to log attendance: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _undoLog() async {
    if (_isLogging) return;
    final wasPresent = _status == _LogStatus.attended;
    setState(() => _isLogging = true);
    try {
      await AttendanceService.undoAttendance(
        widget.slot.subjectName,
        wasPresent: wasPresent,
      );

      widget.slot.lastLoggedDate = null;
      widget.slot.lastLoggedStatus = null;
      widget.slot.save();

      if (mounted) {
        setState(() {
          _status = _LogStatus.none;
          _isLogging = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLogging = false);
    }
  }

  // ── Long-press slot management sheet ───────────────────────────────

  void _showSlotOptions(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final slot = widget.slot;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              slot.subjectName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: cs.onSurface,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${slot.time}  •  ${slot.duration}  •  ${slot.type}',
              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            // Edit
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              tileColor: cs.surfaceContainerHighest,
              leading: Icon(Icons.edit_rounded, color: cs.primary),
              title: Text(
                'Edit Slot',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              subtitle: Text(
                'Change subject, time, or duration',
                style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
              ),
              onTap: () {
                Navigator.pop(context);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => _TimetableBuilderSheet(existingSlot: slot),
                );
              },
            ),
            const SizedBox(height: 8),
            // Delete
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              tileColor: cs.errorContainer.withValues(alpha: 0.4),
              leading: Icon(Icons.delete_rounded, color: cs.error),
              title: Text(
                'Delete Slot',
                style: TextStyle(fontWeight: FontWeight.w700, color: cs.error),
              ),
              subtitle: Text(
                'Remove this class from the timetable',
                style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
              ),
              onTap: () async {
                Navigator.pop(context);
                await TimetableService.deleteSlot(slot);
              },
            ),
          ],
        ),
      ),
    );
  }

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
      case 'Break':
        return _SlotStyle(
          accent: cs.outline,
          bg: cs.surfaceContainerLow,
          fg: cs.onSurface,
          chipBg: cs.surfaceContainerHigh,
          chipFg: cs.onSurfaceVariant,
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final style = _style(context);
    final isBreak = widget.slot.type == 'Break';

    return GestureDetector(
      onLongPress: () => _showSlotOptions(context),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time column
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

            // Card
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

                      // Chips row
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
                        ],
                      ),

                      // Don't show attendance buttons for break slots
                      if (!isBreak) ...[
                        const SizedBox(height: 10),

                        // Mark buttons
                        _status == _LogStatus.none
                            ? Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: _isLogging
                                          ? null
                                          : () => _logAttendance(true),
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
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        padding: EdgeInsets.zero,
                                        textStyle: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SvgPicture.asset(
                                            'assets/icons/attended.svg',
                                            width: 16,
                                            height: 16,
                                            colorFilter: ColorFilter.mode(
                                              cs.secondary,
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Text('Attended'),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: _isLogging
                                          ? null
                                          : () => _logAttendance(false),
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
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        padding: EdgeInsets.zero,
                                        textStyle: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SvgPicture.asset(
                                            'assets/icons/bunked.svg',
                                            width: 16,
                                            height: 16,
                                            colorFilter: ColorFilter.mode(
                                              cs.error,
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Text('Bunked'),
                                        ],
                                      ),
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
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SvgPicture.asset(
                                            _status == _LogStatus.attended
                                                ? 'assets/icons/attended.svg'
                                                : 'assets/icons/bunked.svg',
                                            width: 16,
                                            height: 16,
                                            colorFilter: ColorFilter.mode(
                                              _status == _LogStatus.attended
                                                  ? cs.onSecondaryContainer
                                                  : cs.onErrorContainer,
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            _status == _LogStatus.attended
                                                ? 'Marked present'
                                                : 'Marked as bunked',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color:
                                                  _status == _LogStatus.attended
                                                  ? cs.onSecondaryContainer
                                                  : cs.onErrorContainer,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      minHeight: 40,
                                    ),
                                    child: OutlinedButton(
                                      onPressed: _isLogging
                                          ? null
                                          : () => _undoLog(),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: style.fg,
                                        side: BorderSide(
                                          color: style.accent.withValues(
                                            alpha: 0.4,
                                          ),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
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
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helper widgets ────────────────────────────────────────────────────────────

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
    '8 AM',
    '9 AM',
    '10 AM',
    '11 AM',
    '12 PM',
    '1 PM',
    '2 PM',
    '3 PM',
    '4 PM',
    '5 PM',
    '6 PM',
  ];
  static const _timeKeys = [
    '8:00 AM',
    '9:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '1:00 PM',
    '2:00 PM',
    '3:00 PM',
    '4:00 PM',
    '5:00 PM',
    '6:00 PM',
  ];
  static const _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const double _minCellWidth = 40.0;

  TimetableSlot? _slotAt(int weekday, String timeKey) =>
      (timetable[weekday] ?? []).where((s) => s.time == timeKey).firstOrNull;

  Color _slotBg(TimetableSlot s, BuildContext ctx) =>
      Theme.of(ctx).colorScheme.surfaceContainerHigh;

  Color _slotFg(TimetableSlot s, BuildContext ctx) {
    final cs = Theme.of(ctx).colorScheme;
    if (s.type == 'Lab') return cs.secondary;
    if (s.type == 'Elective') return cs.tertiary;
    if (s.type == 'Break') return cs.outline;
    return cs.primary;
  }

  Color _slotBorder(TimetableSlot s, BuildContext ctx) {
    final cs = Theme.of(ctx).colorScheme;
    if (s.type == 'Lab') return cs.secondary;
    if (s.type == 'Elective') return cs.tertiary;
    if (s.type == 'Break') return cs.outline;
    return cs.primary;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final gutterW = (availableWidth * 0.12).clamp(40.0, 56.0);
        final columnsSpace = availableWidth - gutterW - 16;
        final computedCellW = columnsSpace / 7;
        final cellW = computedCellW < _minCellWidth
            ? _minCellWidth
            : computedCellW;
        final needsHScroll = computedCellW < _minCellWidth;
        final totalWidth = gutterW + cellW * 7 + 16;

        Widget buildGrid({bool scroll = false}) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
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
                      final col = _buildHeaderColumn(i, date, isToday, cs);
                      return scroll
                          ? SizedBox(width: cellW, child: col)
                          : Expanded(child: col);
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

              // Time rows
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

                        Widget cell = Padding(
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
                                            : _slotBorder(
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

                        return scroll
                            ? SizedBox(width: cellW, child: cell)
                            : Expanded(child: cell);
                      }),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 16),

              // Legend
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _LegendDot(color: cs.primary, label: 'Theory'),
                  const SizedBox(width: 16),
                  _LegendDot(color: cs.secondary, label: 'Lab'),
                  const SizedBox(width: 16),
                  _LegendDot(color: cs.tertiary, label: 'Elective'),
                  const SizedBox(width: 16),
                  _LegendDot(color: cs.outline, label: 'Break'),
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
                  child: SizedBox(
                    width: totalWidth,
                    child: buildGrid(scroll: true),
                  ),
                )
              : buildGrid(),
        );
      },
    );
  }

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

// ── Legend Dot ────────────────────────────────────────────────────────────────

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
