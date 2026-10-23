import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/date_badge.dart';
import '../../../comments/presentation/widgets/comments_button.dart';
import '../../../users/domain/entities/user.dart';
import '../../domain/entities/attendance_record.dart';
import 'attendance_status_chip.dart';
import 'attendance_times.dart';

class AttendanceHistoryTile extends StatelessWidget {
  const AttendanceHistoryTile({
    super.key,
    required this.record,
    required this.owner,
  });

  final AttendanceRecord record;

  /// Whose record this is (the signed-in user on the history page).
  final User owner;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              DateBadge(date: record.date),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppDateUtils.weekdayFull(record.date),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      AppDateUtils.longDate(record.date),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              AttendanceStatusChip.forRecord(record),
            ],
          ),
          const SizedBox(height: 14),
          AttendanceTimes(
            checkIn: record.checkInTime,
            checkOut: record.checkOutTime,
          ),
          const SizedBox(height: 4),
          CommentsButton(record: record, owner: owner),
        ],
      ),
    );
  }
}
