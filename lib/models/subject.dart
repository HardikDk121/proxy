// lib/models/subject.dart
// ─────────────────────────────────────────────────────────────────────────────
// Hive data model for a tracked Subject.
//
// After any changes to this file, re-run the adapter generator:
//   flutter pub run build_runner build --delete-conflicting-outputs
// ─────────────────────────────────────────────────────────────────────────────

import 'package:hive/hive.dart';

part 'subject.g.dart';

/// Unique type ID used by Hive to identify this adapter.
/// Must be unique across ALL HiveType annotations in the entire project.
const int kSubjectTypeId = 0;

@HiveType(typeId: kSubjectTypeId)
class Subject extends HiveObject {
  // ── Fields ─────────────────────────────────────────────────────────────────

  /// Display name, e.g. "Data Structures"
  @HiveField(0)
  late String name;

  /// "Theory" or "Lab"
  @HiveField(1)
  late String type;

  /// Number of classes the student attended
  @HiveField(2)
  late int attended;

  /// Total classes held so far
  @HiveField(3)
  late int total;

  /// Lecture duration in hours (1.0 for Theory, 2.0 for Lab by default)
  @HiveField(4)
  late double durationHours;

  // ── Constructor ────────────────────────────────────────────────────────────

  Subject({
    required this.name,
    required this.type,
    this.attended = 0,
    this.total = 0,
    this.durationHours = 1.0,
  });

  // ── Computed helpers ───────────────────────────────────────────────────────

  /// Attendance percentage (0–100).
  double get percentage => total == 0 ? 0.0 : (attended / total) * 100;

  /// True when attendance meets the 75% threshold.
  bool get isSafe => percentage >= 75;

  /// How many classes can be skipped (positive) or must be attended (negative).
  int get bunkMargin => attended - (0.75 * total).ceil();

  @override
  String toString() =>
      'Subject(name: $name, type: $type, $attended/$total, ${percentage.toStringAsFixed(1)}%)';
}
