import 'package:flutter/material.dart';

import '../../features/users/domain/entities/user.dart';
import 'role_badge.dart';

/// Round avatar with initials and a gradient based on the user's role.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.name,
    required this.role,
    this.size = 44,
    this.onDark = false,
  });

  final String name;
  final UserRole role;
  final double size;
  final bool onDark;

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'))
      ..removeWhere((part) => part.isEmpty);
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final color = roleColor(role);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color.lerp(color, Colors.white, 0.28)!, color],
        ),
        border: onDark
            ? Border.all(color: Colors.white.withValues(alpha: 0.7), width: 2)
            : null,
      ),
      child: Text(
        _initials,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.36,
        ),
      ),
    );
  }
}
