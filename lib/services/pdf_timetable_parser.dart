// lib/services/pdf_timetable_parser.dart
// ─────────────────────────────────────────────────────────────────────────────
// Utility class: picks a PDF, extracts its text with Syncfusion, parses
// days/times/subjects with Regex, and persists the result via TimetableService.
//
// Supports two common timetable PDF layouts:
//   • "Day-per-section" — a heading like "MONDAY" followed by rows of times
//   • "Grid/table" — columns are days, rows are time slots
//
// The parser is deliberately conservative: it emits a slot only when it can
// confidently identify at least a day + subject name.  Unrecognised lines are
// silently skipped so a partial import is still useful.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../models/timetable_slot.dart';
import 'timetable_service.dart';

class PdfTimetableParser {
  PdfTimetableParser._(); // pure utility — no instantiation

  // ── Public entry point ─────────────────────────────────────────────────────

  /// Full pipeline: pick → extract → parse → persist.
  ///
  /// Returns the number of slots imported, or -1 if the user cancelled.
  /// Shows a [SnackBar] on success/error so callers need no extra UI logic.
  static Future<int> pickAndParse(BuildContext context) async {
    // Cache UI handles BEFORE the first await to avoid using BuildContext
    // across async gaps (use_build_context_synchronously lint).
    final messenger = ScaffoldMessenger.of(context);
    final errorContainerColor =
        Theme.of(context).colorScheme.errorContainer;

    // 1️⃣  Let the user pick a PDF
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true, // load bytes directly — works on all platforms
    );

    if (result == null || result.files.isEmpty) return -1; // cancelled

    final Uint8List? bytes = result.files.first.bytes;
    if (bytes == null || bytes.isEmpty) {
      _showSnack(
        messenger,
        errorContainerColor,
        '⚠️  Could not read the selected file.',
        isError: true,
      );
      return 0;
    }

    // 2️⃣  Extract text
    final String rawText;
    try {
      rawText = _extractText(bytes);
    } catch (e) {
      _showSnack(
        messenger,
        errorContainerColor,
        '⚠️  Failed to read PDF: $e',
        isError: true,
      );
      return 0;
    }

    if (rawText.trim().isEmpty) {
      _showSnack(
        messenger,
        errorContainerColor,
        '⚠️  No readable text found. The PDF may be image-only.',
        isError: true,
      );
      return 0;
    }

    // 3️⃣  Parse
    final slots = _parse(rawText);

    if (slots.isEmpty) {
      _showSnack(
        messenger,
        errorContainerColor,
        '⚠️  No timetable data recognised. Check the PDF format.',
        isError: true,
      );
      return 0;
    }

    // 4️⃣  Persist
    await TimetableService.replaceAll(slots);

    _showSnack(messenger, errorContainerColor, '✅  Imported ${slots.length} slots from PDF.');
    return slots.length;
  }

  // ── Text extraction ────────────────────────────────────────────────────────

  static String _extractText(Uint8List bytes) {
    final doc = PdfDocument(inputBytes: bytes);
    final extractor = PdfTextExtractor(doc);
    final buf = StringBuffer();
    for (int i = 0; i < doc.pages.count; i++) {
      buf.writeln(extractor.extractText(startPageIndex: i, endPageIndex: i));
    }
    doc.dispose();
    return buf.toString();
  }

  // ── Parser ─────────────────────────────────────────────────────────────────

  static final _dayRegex = RegExp(
    r'\b(monday|tuesday|wednesday|thursday|friday|saturday|sunday|mon|tue|wed|thu|fri|sat|sun)\b',
    caseSensitive: false,
  );

  static final _timeRegex = RegExp(
    r'\b(\d{1,2}:\d{2}\s*(?:AM|PM|am|pm)?)\b',
    caseSensitive: false,
  );

  // Heuristic: subject names are typically 3–40 chars of mixed case / digits.
  // Lines that are only times, numbers, or very short are ignored.
  static final _skipLineRegex = RegExp(
    r'^[\d\s:APMapm\-–/|]+$',
  );

  static List<TimetableSlot> _parse(String text) {
    final slots = <TimetableSlot>[];
    int currentDay = 0;
    String currentTime = '';

    for (final rawLine in text.split('\n')) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;

      // ── Detect a day header ────────────────────────────────────────────────
      final dayMatch = _dayRegex.firstMatch(line);
      if (dayMatch != null && line.length < 30) {
        currentDay = _dayIndex(dayMatch.group(1)!);
        currentTime = '';
        continue;
      }

      // ── Detect a time stamp ───────────────────────────────────────────────
      final timeMatch = _timeRegex.firstMatch(line);
      if (timeMatch != null) {
        currentTime = _normaliseTime(timeMatch.group(1)!);
      }

      // ── If we have a day context and this looks like a subject name ────────
      if (currentDay > 0 && !_skipLineRegex.hasMatch(line) && line.length >= 3) {
        // Strip any trailing time/numeric suffixes for a cleaner name
        final name = line.replaceAll(_timeRegex, '').replaceAll('|', '').trim();
        if (name.length < 3) continue;

        // Infer type from keywords
        final lc = name.toLowerCase();
        final String type;
        if (lc.contains('lab')) {
          type = 'Lab';
        } else if (lc.contains('elective') || lc.contains('open')) {
          type = 'Elective';
        } else {
          type = 'Theory';
        }

        final duration = type == 'Lab' ? '2h' : '1h';

        slots.add(TimetableSlot(
          day: currentDay,
          subjectName: _toTitleCase(name),
          type: type,
          time: currentTime.isEmpty ? '—' : currentTime,
          duration: duration,
        ));
      }
    }

    return slots;
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static int _dayIndex(String day) {
    switch (day.toLowerCase().substring(0, 3)) {
      case 'mon': return 1;
      case 'tue': return 2;
      case 'wed': return 3;
      case 'thu': return 4;
      case 'fri': return 5;
      case 'sat': return 6;
      case 'sun': return 7;
      default:    return 0;
    }
  }

  /// Normalises "9:00am" → "9:00 AM", "14:30" → "2:30 PM", etc.
  static String _normaliseTime(String raw) {
    final clean = raw.trim().toUpperCase().replaceAll(' ', '');
    final hasAmPm = clean.endsWith('AM') || clean.endsWith('PM');
    final numStr = clean.replaceAll(RegExp(r'[APM]'), '');
    final parts = numStr.split(':');
    int h = int.tryParse(parts[0]) ?? 0;
    final m = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;

    if (!hasAmPm) {
      // 24-h format → 12-h
      final period = h >= 12 ? 'PM' : 'AM';
      if (h > 12) h -= 12;
      if (h == 0) h = 12;
      return '${h.toString().padLeft(1)}:${m.toString().padLeft(2, '0')} $period';
    }

    final period = clean.endsWith('PM') ? 'PM' : 'AM';
    return '${h.toString().padLeft(1)}:${m.toString().padLeft(2, '0')} $period';
  }

  static String _toTitleCase(String s) {
    return s
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  static void _showSnack(
    ScaffoldMessengerState messenger,
    Color errorContainerColor,
    String message, {
    bool isError = false,
  }) {
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? errorContainerColor : null,
      ),
    );
  }
}
