import 'package:equatable/equatable.dart';

enum UserRole {
  admin('Admin'),
  seniorStaff('Senior Staff'),
  staff('Staff');

  const UserRole(this.label);

  final String label;

  bool get canViewTeamRecords => this != UserRole.staff;

  bool get canManageUsers => this == UserRole.admin;

  /// Roles this role is allowed to create accounts for.
  List<UserRole> get creatableRoles => this == UserRole.admin
      ? const [UserRole.seniorStaff, UserRole.staff]
      : const [];

  /// Whether this role is allowed to see attendance of someone with [target] role.
  bool canViewAttendanceOf(UserRole target) {
    switch (this) {
      case UserRole.admin:
        return true;
      case UserRole.seniorStaff:
        return target == UserRole.staff;
      case UserRole.staff:
        return false;
    }
  }
}

class User extends Equatable {
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  final String id;
  final String name;
  final String email;
  final UserRole role;

  @override
  List<Object?> get props => [id, name, email, role];
}
