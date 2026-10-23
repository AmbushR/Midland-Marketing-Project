import 'package:flutter/material.dart';

import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/attendance_record.dart';

class AttendanceStatusChip extends StatelessWidget {
  const AttendanceStatusChip({
    super.key,
    required this.status,
    this.missedCheckOut = false,
  });

  /// Chip for a stored record. A past day that was never checked out shows
  /// as "Missed check-out" instead of "Checked in".
  factory AttendanceStatusChip.forRecord(AttendanceRecord record) {
    final today = AppDateUtils.dateOnly(DateTime.now());
    final missed =
        record.status == AttendanceStatus.checkedIn &&
        record.date.isBefore(today);
    return AttendanceStatusChip(status: record.status, missedCheckOut: missed);
  }

  final AttendanceStatus status;
  final bool missedCheckOut;

  @override
  Widget build(BuildContext context) {
    final (label, background, foreground) = _style();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: foreground, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  (String, Color, Color) _style() {
    if (missedCheckOut) {
      return (
        'Missed check-out',
        const Color(0xFFFEF3C7),
        const Color(0xFFB45309),
      );
    }
    switch (status) {
      case AttendanceStatus.notCheckedIn:
        return (
          status.label,
          const Color(0xFFF3F4F6),
          const Color(0xFF4B5563),
        );
      case AttendanceStatus.checkedIn:
        return (
          status.label,
          const Color(0xFFE0E7FF),
          const Color(0xFF3730A3),
        );
      case AttendanceStatus.checkedOut:
        return (
          status.label,
          const Color(0xFFD1FAE5),
          const Color(0xFF047857),
        );
    }
  }
}
