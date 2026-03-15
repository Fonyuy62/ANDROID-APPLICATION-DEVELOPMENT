// ============================================================
// app_widgets.dart — Reusable custom widgets
// ============================================================

import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../models/calculator.dart';

// ---- Stat Card Widget ----
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accent.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.accent, size: 20),
              const SizedBox(width: 8),
              Text(label,
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12, letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? AppTheme.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ---- Grade Badge Widget ----
class GradeBadge extends StatelessWidget {
  final String grade;

  const GradeBadge({super.key, required this.grade});

  Color get _gradeColor => switch (grade) {
        'A' || 'A-' => AppTheme.passGreen,
        'B+' || 'B' || 'B-' => AppTheme.accentLight,
        'C+' || 'C' => AppTheme.gradeGold,
        'D' => Colors.orange,
        _ => AppTheme.failRed,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _gradeColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _gradeColor.withOpacity(0.4)),
      ),
      child: Text(
        grade,
        style: TextStyle(
          color: _gradeColor,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}

// ---- Result Badge ----
class ResultBadge extends StatelessWidget {
  final String result;
  const ResultBadge({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final isPass = result == 'PASS';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: (isPass ? AppTheme.passGreen : AppTheme.failRed).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: (isPass ? AppTheme.passGreen : AppTheme.failRed).withOpacity(0.5)),
      ),
      child: Text(
        result,
        style: TextStyle(
          color: isPass ? AppTheme.passGreen : AppTheme.failRed,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ---- GlowButton ----
class GlowButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final bool isLoading;

  const GlowButton({
    super.key,
    required this.label,
    required this.icon,
    this.onPressed,
    this.color,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final btnColor = color ?? AppTheme.accent;
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: onPressed == null ? AppTheme.border : btnColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: onPressed != null
              ? [
                  BoxShadow(
                    color: btnColor.withOpacity(0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
            else
              Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    letterSpacing: 0.3)),
          ],
        ),
      ),
    );
  }
}

// ---- Students Data Table ----
class StudentsDataTable extends StatelessWidget {
  final List<StudentRecord> students;

  const StudentsDataTable({super.key, required this.students});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          // Header Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(children: [
              _headerCell('Student ID', flex: 2),
              _headerCell('Full Name', flex: 3),
              _headerCell('Mark', flex: 2),
              _headerCell('Grade', flex: 1),
              _headerCell('Result', flex: 2),
            ]),
          ),
          const Divider(height: 1, color: AppTheme.divider),
          // Data Rows
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: students.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: AppTheme.divider),
            itemBuilder: (context, index) {
              final s = students[index];
              final isEven = index.isEven;
              return Container(
                color: isEven
                    ? Colors.transparent
                    : AppTheme.surface.withOpacity(0.4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(children: [
                  _dataCell(s.studentId, flex: 2,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13)),
                  _dataCell(s.studentName, flex: 3,
                      style: const TextStyle(
                          color: AppTheme.textPrimary, fontWeight: FontWeight.w500)),
                  _dataCell('${s.examMark.toStringAsFixed(1)}%', flex: 2,
                      style: TextStyle(
                          color: s.examMark >= 50
                              ? AppTheme.passGreen
                              : AppTheme.failRed,
                          fontWeight: FontWeight.w600)),
                  Expanded(flex: 1, child: GradeBadge(grade: s.grade)),
                  Expanded(flex: 2, child: ResultBadge(result: s.result)),
                ]),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _headerCell(String text, {int flex = 1}) => Expanded(
        flex: flex,
        child: Text(text,
            style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8)),
      );

  Widget _dataCell(String text, {int flex = 1, TextStyle? style}) => Expanded(
        flex: flex,
        child: Text(text,
            style: style ??
                const TextStyle(color: AppTheme.textPrimary, fontSize: 13)),
      );
}

// ---- Drop Zone Widget ----
class DropZone extends StatefulWidget {
  final VoidCallback onTap;
  final bool isLoading;

  const DropZone({super.key, required this.onTap, this.isLoading = false});

  @override
  State<DropZone> createState() => _DropZoneState();
}

class _DropZoneState extends State<DropZone> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.isLoading ? null : widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.all(60),
          decoration: BoxDecoration(
            color: _hovered
                ? AppTheme.accent.withOpacity(0.08)
                : AppTheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _hovered ? AppTheme.accent : AppTheme.border,
              width: _hovered ? 2 : 1,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.isLoading)
                const CircularProgressIndicator(color: AppTheme.accent)
              else ...[
                Icon(
                  Icons.upload_file_rounded,
                  size: 56,
                  color: _hovered ? AppTheme.accent : AppTheme.textSecondary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Click to Upload Student Excel File',
                  style: TextStyle(
                    color: _hovered ? AppTheme.accent : AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Supported formats: .xlsx  •  Columns: Student ID, Student Name, Exam Mark',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
