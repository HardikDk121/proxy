// lib/widgets/add_subject_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/subject.dart';
import '../services/attendance_service.dart';

/// Call this from anywhere to show the Add Subject bottom sheet.
Future<void> showAddSubjectSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.6),
    builder: (_) => const _AddSubjectSheet(),
  );
}

// ─────────────────────────────────────────────────────────────────────────────

class _AddSubjectSheet extends StatefulWidget {
  const _AddSubjectSheet();

  @override
  State<_AddSubjectSheet> createState() => _AddSubjectSheetState();
}

class _AddSubjectSheetState extends State<_AddSubjectSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _durationCtrl = TextEditingController(text: '1.0');

  String _type = 'Theory';
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _durationCtrl.dispose();
    super.dispose();
  }

  void _pickType(String type) => setState(() {
    _type = type;
    _durationCtrl.text = type == 'Theory' ? '1.0' : '2.0';
  });

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final subject = Subject(
        name: _nameController.text.trim(),
        type: _type,
        durationHours: double.parse(_durationCtrl.text),
      );

      await AttendanceService.addSubject(subject);
      HapticFeedback.lightImpact();

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save subject: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ── build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final bgColor = theme.scaffoldBackgroundColor;
    final surfaceColor = cs.surface;
    final primaryColor = cs.primary;
    final errorColor = cs.error;
    final textPrimary =
        theme.textTheme.bodyLarge?.color ?? const Color(0xFFE0E0E0);
    final textSecond =
        theme.textTheme.bodyMedium?.color ?? const Color(0xFFA0A0A0);
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + bottom),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Drag handle ───────────────────────────────────────────────
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 4),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: textSecond.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // ── Header ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.add_rounded,
                      color: primaryColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add Subject',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontSize: 18,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        'Track a new course',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: textSecond,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Subject Name ──────────────────────────────────────────────
            _sectionLabel('SUBJECT NAME', textSecond),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              style: TextStyle(
                color: textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              decoration: _inputDeco(
                hint: 'e.g. Data Structures',
                icon: Icons.book_rounded,
                surfaceColor: surfaceColor,
                primaryColor: primaryColor,
                errorColor: errorColor,
                textSecond: textSecond,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Enter subject name';
                if (v.trim().length < 2) return 'At least 2 characters';
                return null;
              },
            ),

            const SizedBox(height: 20),

            // ── Type Selector ─────────────────────────────────────────────
            _sectionLabel('TYPE', textSecond),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _typeChip(
                    type: 'Theory',
                    icon: Icons.menu_book_rounded,
                    primaryColor: primaryColor,
                    surfaceColor: surfaceColor,
                    textSecond: textSecond,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _typeChip(
                    type: 'Lab',
                    icon: Icons.science_rounded,
                    primaryColor: primaryColor,
                    surfaceColor: surfaceColor,
                    textSecond: textSecond,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Duration ──────────────────────────────────────────────────
            _sectionLabel('LECTURE DURATION', textSecond),
            const SizedBox(height: 8),
            TextFormField(
              controller: _durationCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
              ],
              style: TextStyle(
                color: textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              decoration: _inputDeco(
                hint: '1.0',
                icon: Icons.timer_rounded,
                suffix: 'hrs',
                surfaceColor: surfaceColor,
                primaryColor: primaryColor,
                errorColor: errorColor,
                textSecond: textSecond,
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Enter duration';
                final p = double.tryParse(v);
                if (p == null || p <= 0) return 'Enter a valid duration';
                if (p > 6) return 'Too long — max 6 hrs';
                return null;
              },
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 12,
                  color: textSecond.withOpacity(0.5),
                ),
                const SizedBox(width: 5),
                Text(
                  'Auto-filled from type. You can override it.',
                  style: TextStyle(
                    color: textSecond.withOpacity(0.5),
                    fontSize: 11,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ── Save Button ───────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.black,
                  disabledBackgroundColor: primaryColor.withOpacity(0.6),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.black,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_rounded, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Add Subject',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── helpers ────────────────────────────────────────────────────────────────

  Widget _sectionLabel(String text, Color color) => Text(
    text,
    style: TextStyle(
      color: color,
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.1,
    ),
  );

  Widget _typeChip({
    required String type,
    required IconData icon,
    required Color primaryColor,
    required Color surfaceColor,
    required Color textSecond,
  }) {
    final sel = _type == type;
    return GestureDetector(
      onTap: () => _pickType(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: sel ? primaryColor : surfaceColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: sel
              ? [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Icon(icon, size: 22, color: sel ? Colors.black : textSecond),
            const SizedBox(height: 6),
            Text(
              type,
              style: TextStyle(
                color: sel ? Colors.black : textSecond,
                fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
            Text(
              type == 'Theory' ? '1 hr' : '2 hrs',
              style: TextStyle(
                color: sel
                    ? Colors.black.withOpacity(0.6)
                    : textSecond.withOpacity(0.45),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDeco({
    required String hint,
    required IconData icon,
    required Color surfaceColor,
    required Color primaryColor,
    required Color errorColor,
    required Color textSecond,
    String? suffix,
  }) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(
      color: textSecond.withOpacity(0.45),
      fontWeight: FontWeight.w400,
    ),
    filled: true,
    fillColor: surfaceColor,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: primaryColor, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: errorColor, width: 1.5),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: errorColor, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
    prefixIcon: Padding(
      padding: const EdgeInsets.only(left: 14, right: 10),
      child: Icon(icon, color: primaryColor, size: 20),
    ),
    prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
    suffixText: suffix,
    suffixStyle: TextStyle(color: textSecond, fontWeight: FontWeight.w500),
  );
}
