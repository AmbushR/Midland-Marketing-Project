import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';

class AttendanceTimes extends StatelessWidget {
  const AttendanceTimes({super.key, this.checkIn, this.checkOut});

  final DateTime? checkIn;
  final DateTime? checkOut;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TimeBox(
            icon: Icons.login_rounded,
            label: 'Check in',
            value: AppDateUtils.formatTime(checkIn),
            color: AppColors.success,
            active: checkIn != null,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _TimeBox(
            icon: Icons.logout_rounded,
            label: 'Check out',
            value: AppDateUtils.formatTime(checkOut),
            color: AppColors.orange,
            active: checkOut != null,
          ),
        ),
      ],
    );
  }
}

class _TimeBox extends StatelessWidget {
  const _TimeBox({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.active,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tint = active ? color : AppColors.muted;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: active ? 0.1 : 0.07),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 18, color: tint),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: active ? AppColors.ink : AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
