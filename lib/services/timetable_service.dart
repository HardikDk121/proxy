// lib/services/timetable_service.dart
// ─────────────────────────────────────────────────────────────────────────────
// Repository / Service layer for all Hive CRUD operations on TimetableSlot.
//
// Design mirrors AttendanceService exactly:
//  • Single static Box<TimetableSlot> opened once at startup.
//  • ValueListenable<Box<TimetableSlot>> exposed for reactive UI rebuilds.
//  • replaceAll() atomically clears + re-writes (used by the PDF parser).
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/timetable_slot.dart';

class TimetableService {
  // ── Box name constant ──────────────────────────────────────────────────────
  static const String _boxName = 'timetable';

  // ── Internal box reference ─────────────────────────────────────────────────
  static Box<TimetableSlot>? _box;

  // ── Singleton guard ────────────────────────────────────────────────────────
  TimetableService._();

  // ── Initialization ─────────────────────────────────────────────────────────

  /// Opens the Hive box. Call exactly ONCE in main() before runApp().
  static Future<void> init() async {
    if (_box != null && _box!.isOpen) return;
    _box = await Hive.openBox<TimetableSlot>(_boxName);
  }

  // ── Private accessor ───────────────────────────────────────────────────────
  static Box<TimetableSlot> get _openBox {
    assert(
      _box != null && _box!.isOpen,
      'TimetableService.init() must be called before using the service.',
    );
    return _box!;
  }

  // ── Reactive listenable ────────────────────────────────────────────────────

  /// Wrap your widget with [ValueListenableBuilder] to get automatic rebuilds.
  static ValueListenable<Box<TimetableSlot>> get listenable =>
      _openBox.listenable();

  // ── READ ───────────────────────────────────────────────────────────────────

  /// All slots as a flat list.
  static List<TimetableSlot> getAll() => _openBox.values.toList(growable: false);

  /// Slots grouped by weekday (1–7).  Days with no slots are absent from the map.
  static Map<int, List<TimetableSlot>> getWeekMap() {
    final result = <int, List<TimetableSlot>>{};
    for (final slot in _openBox.values) {
      result.putIfAbsent(slot.day, () => []).add(slot);
    }
    // Sort each day's list by start time
    for (final list in result.values) {
      list.sort((a, b) => a.sortKey.compareTo(b.sortKey));
    }
    return result;
  }

  // ── WRITE ──────────────────────────────────────────────────────────────────

  /// Atomically replaces ALL slots with [slots].
  /// Called by [PdfTimetableParser] after a successful parse.
  static Future<void> replaceAll(List<TimetableSlot> slots) async {
    try {
      await _openBox.clear();
      await _openBox.addAll(slots);
    } catch (e, st) {
      debugPrint('[TimetableService] replaceAll error: $e\n$st');
      rethrow;
    }
  }

  /// Adds a single slot; returns its auto-generated key.
  static Future<dynamic> addSlot(TimetableSlot slot) async {
    try {
      return await _openBox.add(slot);
    } catch (e, st) {
      debugPrint('[TimetableService] addSlot error: $e\n$st');
      rethrow;
    }
  }

  /// Deletes ALL slots — used in Settings / "Clear timetable".
  static Future<void> deleteAll() async {
    try {
      await _openBox.clear();
    } catch (e, st) {
      debugPrint('[TimetableService] deleteAll error: $e\n$st');
      rethrow;
    }
  }

  // ── CLOSE ──────────────────────────────────────────────────────────────────
  static Future<void> close() async {
    await _box?.close();
    _box = null;
  }
}
