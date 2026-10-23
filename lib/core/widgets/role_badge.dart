import 'package:flutter/material.dart';

import '../../features/users/domain/entities/user.dart';
import '../theme/app_colors.dart';

Color roleColor(UserRole role) {
  switch (role) {
    case UserRole.admin:
      return AppColors.rose;
    case UserRole.seniorStaff:
      return AppColors.primary;
    case UserRole.staff:
      return AppColors.teal;
  }
}

IconData roleIcon(UserRole role) {
  switch (role) {
    case UserRole.admin:
      return Icons.shield_outlined;
    case UserRole.seniorStaff:
      return Icons.workspace_premium_outlined;
    case UserRole.staff:
      return Icons.badge_outlined;
  }
}

/// Small coloured pill showing a role.
class RoleBadge extends StatelessWidget {
  const RoleBadge({super.key, required this.role, this.onDark = false});

  final UserRole role;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final color = onDark ? Colors.white : roleColor(role);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: onDark
            ? Colors.white.withValues(alpha: 0.18)
            : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(roleIcon(role), size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            role.label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
