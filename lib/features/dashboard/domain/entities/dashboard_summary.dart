import 'package:equatable/equatable.dart';

import '../../../attendance/domain/entities/employee_attendance.dart';

class DashboardSummary extends Equatable {
  const DashboardSummary({
    required this.totalUsers,
    required this.staffCount,
    required this.seniorStaffCount,
    required this.checkedInToday,
    required this.notCheckedInToday,
    required this.entries,
  });

  /// Everyone the viewer is allowed to see (all users for Admin, Staff only
  /// for Senior Staff).
  final int totalUsers;
  final int staffCount;
  final int seniorStaffCount;
  final int checkedInToday;
  final int notCheckedInToday;

  /// Recent records for Admin, today's Staff records for Senior Staff.
  final List<EmployeeAttendance> entries;

  @override
  List<Object?> get props => [
    totalUsers,
    staffCount,
    seniorStaffCount,
    checkedInToday,
    notCheckedInToday,
    entries,
  ];
}
