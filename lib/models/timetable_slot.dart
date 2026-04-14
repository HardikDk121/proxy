// lib/models/timetable_slot.dart
// ─────────────────────────────────────────────────────────────────────────────
// Hive data model for a single timetable entry (one class in the weekly grid).
//
// After any changes to this file, re-run the adapter generator:
//   flutter pub run build_runner build --delete-conflicting-outputs
// ─────────────────────────────────────────────────────────────────────────────

import 'package:hive/hive.dart';

part 'timetable_slot.g.dart';

/// Unique type ID used by Hive to identify this adapter.
/// MUST differ from kSubjectTypeId (0) and every other @HiveType in the project.
const int kTimetableSlotTypeId = 1;

@HiveType(typeId: kTimetableSlotTypeId)
class TimetableSlot extends HiveObject {
  // ── Fields ─────────────────────────────────────────────────────────────────

  /// Day of week: 1 = Monday … 7 = Sunday  (aligns with DateTime.weekday)
  @HiveField(0)
  late int day;

  /// Display name of the subject, e.g. "Data Structures"
  @HiveField(1)
  late String subjectName;

  /// Class type: 'Theory' | 'Lab' | 'Elective'
  @HiveField(2)
  late String type;

  /// Human-readable start time, e.g. "9:00 AM"
  @HiveField(3)
  late String time;

  /// Human-readable duration, e.g. "1h" or "2h"
  @HiveField(4)
  late String duration;

  @HiveField(5)
  DateTime? lastLoggedDate;

  @HiveField(6)
  String? lastLoggedStatus;

  // ── Constructor ────────────────────────────────────────────────────────────

  TimetableSlot({
    required this.day,
    required this.subjectName,
    required this.type,
    required this.time,
    required this.duration,
    this.lastLoggedDate,
    this.lastLoggedStatus,
  });

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// 24-hour sort key parsed from [time], used to sort slots within a day.
  /// Falls back to 0 if the format cannot be parsed.
  int get sortKey {
    // Accepts "9:00 AM", "11:30 PM", "14:00" etc.
    final t = time.trim().toUpperCase();
    final pmBiased = t.endsWith('PM');
    final numPart = t.replaceAll(RegExp(r'[APM\s]'), '');
    final parts = numPart.split(':');
    if (parts.isEmpty) return 0;
    int hour = int.tryParse(parts[0]) ?? 0;
    final min  = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    if (pmBiased && hour != 12) hour += 12;
    if (!pmBiased && hour == 12) hour = 0;
    return hour * 60 + min;
  }

  @override
  String toString() =>
      'TimetableSlot(day: $day, $subjectName [$type] @ $time for $duration)';
}
