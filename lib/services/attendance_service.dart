// lib/services/attendance_service.dart
// ─────────────────────────────────────────────────────────────────────────────
// Repository / Service layer for all Hive CRUD operations on subjects.
//
// Design decisions:
//  • Single static `Box<Subject>` reference opened once at startup.
//  • All write operations return the key so callers can reference the record.
//  • `ValueListenable<Box<Subject>>` is exposed so UI can use
//    ValueListenableBuilder for automatic reactive rebuilds.
//  • Error handling via try/catch with rethrow so callers always know
//    when an operation fails.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart'; // ValueListenable
import 'package:hive_flutter/hive_flutter.dart';
import '../models/subject.dart';

class AttendanceService {
  // ── Box name constant ──────────────────────────────────────────────────────
  static const String _boxName = 'subjects';

  // ── Internal box reference (set after openBox) ─────────────────────────────
  static Box<Subject>? _box;

  // ── Singleton constructor prevents accidental instantiation ───────────────
  AttendanceService._();

  // ── Initialization ─────────────────────────────────────────────────────────

  /// Opens the Hive box. Call exactly ONCE in main() before runApp().
  static Future<void> init() async {
    if (_box != null && _box!.isOpen) return; // already open — idempotent
    _box = await Hive.openBox<Subject>(_boxName);
  }

  // ── Private accessor (throws if box not initialised) ──────────────────────
  static Box<Subject> get _openBox {
    assert(_box != null && _box!.isOpen,
        'AttendanceService.init() must be called before using the service.');
    return _box!;
  }

  // ── Reactive stream (for ValueListenableBuilder) ───────────────────────────

  /// Returns a [ValueListenable] that notifies listeners on every box change.
  /// Wrap your list widget with [ValueListenableBuilder] to get automatic
  /// reactive rebuilds without setState or Provider.
  static ValueListenable<Box<Subject>> get listenable =>
      _openBox.listenable();

  // ── READ ───────────────────────────────────────────────────────────────────

  /// Returns all subjects as an unmodifiable list.
  static List<Subject> getAll() {
    try {
      return _openBox.values.toList(growable: false);
    } catch (e, st) {
      debugPrint('[AttendanceService] getAll error: $e\n$st');
      rethrow;
    }
  }

  /// Returns a single subject by its Hive key, or null if not found.
  static Subject? getByKey(dynamic key) {
    try {
      return _openBox.get(key);
    } catch (e, st) {
      debugPrint('[AttendanceService] getByKey($key) error: $e\n$st');
      rethrow;
    }
  }

  // ── CREATE ─────────────────────────────────────────────────────────────────

  /// Persists a new [Subject] and returns its auto-generated Hive key.
  static Future<dynamic> addSubject(Subject subject) async {
    try {
      return await _openBox.add(subject);
    } catch (e, st) {
      debugPrint('[AttendanceService] addSubject error: $e\n$st');
      rethrow;
    }
  }

  // ── UPDATE ─────────────────────────────────────────────────────────────────

  /// Saves any in-memory changes made to a [HiveObject] back to disk.
  /// Use after mutating fields directly:
  ///   subject.attended += 1;
  ///   await AttendanceService.save(subject);
  static Future<void> save(Subject subject) async {
    try {
      await subject.save(); // HiveObject.save() — uses stored key
    } catch (e, st) {
      debugPrint('[AttendanceService] save error: $e\n$st');
      rethrow;
    }
  }

  /// Increments attended count and saves.
  static Future<void> markAttended(Subject subject) async {
    subject.attended += 1;
    subject.total += 1;
    await save(subject);
  }

  /// Increments total count (skipped class) and saves.
  static Future<void> markAbsent(Subject subject) async {
    subject.total += 1;
    await save(subject);
  }

  /// Replaces editable fields on an existing subject.
  static Future<void> updateSubject(
    Subject subject, {
    String? name,
    String? type,
    int? attended,
    int? total,
    double? durationHours,
  }) async {
    try {
      if (name != null) subject.name = name;
      if (type != null) subject.type = type;
      if (attended != null) subject.attended = attended;
      if (total != null) subject.total = total;
      if (durationHours != null) subject.durationHours = durationHours;
      await subject.save();
    } catch (e, st) {
      debugPrint('[AttendanceService] updateSubject error: $e\n$st');
      rethrow;
    }
  }

  // ── DELETE ─────────────────────────────────────────────────────────────────

  /// Deletes a subject from the box by its [HiveObject] reference.
  static Future<void> deleteSubject(Subject subject) async {
    try {
      await subject.delete(); // HiveObject.delete() — uses stored key
    } catch (e, st) {
      debugPrint('[AttendanceService] deleteSubject error: $e\n$st');
      rethrow;
    }
  }

  /// Deletes ALL subjects — use with caution (e.g. "Clear all data" in Settings).
  static Future<void> deleteAll() async {
    try {
      await _openBox.clear();
    } catch (e, st) {
      debugPrint('[AttendanceService] deleteAll error: $e\n$st');
      rethrow;
    }
  }

  // ── CLOSE ──────────────────────────────────────────────────────────────────

  /// Closes the box. Usually not needed — Hive closes boxes on app exit.
  static Future<void> close() async {
    await _box?.close();
    _box = null;
  }
}
