// lib/screens/time_table_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
// TimetableScreen — fully wired to Hive via ValueListenableBuilder.
// All mock data removed; slots come from TimetableService (hive box: 'timetable').
// Use the "Import PDF" FAB to populate the box via PdfTimetableParser.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/timetable_slot.dart';
import '../services/timetable_service.dart';
import '../services/pdf_timetable_parser.dart';

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
  bool _isImporting = false;

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
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[_today.month]} ${_today.year}';
  }

  Future<void> _importPdf() async {
    setState(() => _isImporting = true);
    try {
      await PdfTimetableParser.pickAndParse(context);
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Wrap the entire screen in ValueListenableBuilder so any box change
    // (import / delete) automatically triggers a full rebuild.
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
                      icon: Icon(Icons.delete_sweep_rounded,
                          color: cs.onPrimaryContainer),
                      tooltip: 'Clear timetable',
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Clear Timetable?'),
                            content: const Text(
                              'All imported slots will be deleted. You can re-import from PDF at any time.',
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
                    icon: Icon(Icons.today_rounded,
                        color: cs.onPrimaryContainer),
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
                                        color: cs.onPrimaryContainer
                                            .withValues(alpha: 0.7),
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
                            color: cs.onPrimaryContainer
                                .withValues(alpha: 0.12),
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
                                cs.onPrimaryContainer.withValues(alpha: 0.75),
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
                        isImporting: _isImporting,
                        onImport: _importPdf,
                      )
                    : _DayView(
                        weekday: _selectedWeekday,
                        today: _today,
                        slots: selectedSlots,
                      ),
                box.isEmpty
                    ? _EmptyTimetable(
                        isImporting: _isImporting,
                        onImport: _importPdf,
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
          // Import PDF button
          floatingActionButton: _isImporting
              ? FloatingActionButton.extended(
                  onPressed: null,
                  icon: const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                  label: const Text('Importing…'),
                )
              : FloatingActionButton.extended(
                  onPressed: _importPdf,
                  icon: const Icon(Icons.upload_file_rounded, size: 20),
                  label: Text(
                    box.isEmpty ? 'Import PDF' : 'Re-import PDF',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
        );
      },
    );
  }
}

// ── Empty State — no PDF imported yet ─────────────────────────────────────────

class _EmptyTimetable extends StatelessWidget {
  final bool isImporting;
  final VoidCallback onImport;

  const _EmptyTimetable({
    required this.isImporting,
    required this.onImport,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
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
                Icons.picture_as_pdf_rounded,
                size: 42,
                color: cs.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No timetable yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Import your college timetable PDF to populate\nthe day and week views automatically.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: cs.onSurfaceVariant,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: isImporting ? null : onImport,
              icon: isImporting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : const Icon(Icons.upload_file_rounded),
              label: Text(isImporting ? 'Importing…' : 'Import PDF'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(200, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
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
          final isToday = date.day == today.day &&
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
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday',
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final style = _style(context);

    return IntrinsicHeight(
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
                                      color:
                                          cs.secondary.withValues(alpha: 0.6),
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
                                      color: cs.error.withValues(alpha: 0.6),
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
                                  constraints:
                                      const BoxConstraints(minHeight: 40),
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
                                constraints:
                                    const BoxConstraints(minHeight: 40),
                                child: OutlinedButton(
                                  onPressed: () => setState(
                                    () => _status = _LogStatus.none,
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: style.fg,
                                    side: BorderSide(
                                      color:
                                          style.accent.withValues(alpha: 0.4),
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
    '9 AM', '10 AM', '11 AM', '12 PM', '1 PM', '2 PM', '3 PM', '4 PM',
  ];
  static const _timeKeys = [
    '9:00 AM', '10:00 AM', '11:00 AM', '12:00 PM',
    '1:00 PM', '2:00 PM', '3:00 PM', '4:00 PM',
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
    return cs.primary;
  }

  Color _slotBorder(TimetableSlot s, BuildContext ctx) {
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
        final gutterW = (availableWidth * 0.12).clamp(40.0, 56.0);
        final columnsSpace = availableWidth - gutterW - 16;
        final computedCellW = columnsSpace / 7;
        final cellW =
            computedCellW < _minCellWidth ? _minCellWidth : computedCellW;
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
                      final isToday = date.day == today.day &&
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
                        final isToday = date.day == today.day &&
                            date.month == today.month &&
                            date.year == today.year;

                        Widget cell = Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 1.5),
                          child: slot != null
                              ? GestureDetector(
                                  onTap: () => onCellTap(wd),
                                  child: Container(
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: _slotBg(slot, context),
                                      borderRadius:
                                          BorderRadius.circular(6),
                                      border: Border.all(
                                        color: isToday
                                            ? cs.error
                                            : _slotBorder(slot, context)
                                                .withValues(alpha: 0.6),
                                        width: isToday ? 1.5 : 1,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 2),
                                    child: Text(
                                      slot.subjectName
                                          .split(' ')
                                          .map((w) =>
                                              w.isNotEmpty ? w[0] : '')
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
                                    borderRadius:
                                        BorderRadius.circular(6),
                                    border: isToday
                                        ? Border.all(
                                            color: cs.error
                                                .withValues(alpha: 0.3),
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
                ],
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Tap a cell to see that day\'s full schedule',
                  style:
                      TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8),
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
