import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/role_badge.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../comments/presentation/widgets/comments_button.dart';
import '../../domain/entities/employee_attendance.dart';
import 'attendance_status_chip.dart';
import 'attendance_times.dart';

class EmployeeAttendanceTile extends StatelessWidget {
  const EmployeeAttendanceTile({super.key, required this.entry});

  final EmployeeAttendance entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final employee = entry.employee;
    final record = entry.record;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserAvatar(name: employee.name, role: employee.role, size: 46),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employee.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        RoleBadge(role: employee.role),
                        Text(
                          AppDateUtils.formatDate(record.date),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AttendanceStatusChip.forRecord(record),
            ],
          ),
          const SizedBox(height: 14),
          AttendanceTimes(
            checkIn: record.checkInTime,
            checkOut: record.checkOutTime,
          ),
          const SizedBox(height: 4),
          CommentsButton(record: record, owner: employee),
        ],
      ),
    );
  }
}
