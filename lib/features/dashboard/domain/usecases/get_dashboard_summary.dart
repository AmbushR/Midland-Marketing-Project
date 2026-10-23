import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../attendance/domain/entities/employee_attendance.dart';
import '../../../attendance/domain/repositories/attendance_repository.dart';
import '../../../users/domain/entities/user.dart';
import '../../../users/domain/repositories/user_repository.dart';
import '../entities/dashboard_summary.dart';

/// Builds the Admin / Senior Staff dashboard numbers from the stored data.
class GetDashboardSummary {
  const GetDashboardSummary({
    required UserRepository userRepository,
    required AttendanceRepository attendanceRepository,
  }) : _userRepository = userRepository,
       _attendanceRepository = attendanceRepository;

  final UserRepository _userRepository;
  final AttendanceRepository _attendanceRepository;

  static const _recentLimit = 10;

  Future<DashboardSummary> call(User viewer) async {
    if (!viewer.role.canViewTeamRecords) {
      throw const AttendanceException(
        'You do not have access to this dashboard.',
      );
    }

    final users = await _userRepository.getUsers();
    final scope = [
      for (final user in users)
        if (viewer.role.canViewAttendanceOf(user.role)) user,
    ];
    final usersById = {for (final user in scope) user.id: user};

    final records = await _attendanceRepository.getRecords();
    final entries = <EmployeeAttendance>[];
    for (final record in records) {
      final employee = usersById[record.userId];
      if (employee != null) {
        entries.add(EmployeeAttendance(employee: employee, record: record));
      }
    }
    entries.sort(_latestFirst);

    final today = DateTime.now();
    final todayEntries = entries
        .where((entry) => AppDateUtils.isSameDay(entry.record.date, today))
        .toList();

    final listed = viewer.role == UserRole.admin
        ? entries.take(_recentLimit).toList()
        : todayEntries;

    return DashboardSummary(
      totalUsers: scope.length,
      staffCount: _countRole(scope, UserRole.staff),
      seniorStaffCount: _countRole(scope, UserRole.seniorStaff),
      // One record per user per day, so records equal people.
      checkedInToday: todayEntries.length,
      notCheckedInToday: scope.length - todayEntries.length,
      entries: listed,
    );
  }

  static int _countRole(List<User> users, UserRole role) =>
      users.where((user) => user.role == role).length;

  static int _latestFirst(EmployeeAttendance a, EmployeeAttendance b) {
    final aTime = a.record.checkInTime ?? a.record.date;
    final bTime = b.record.checkInTime ?? b.record.date;
    return bTime.compareTo(aTime);
  }
}
