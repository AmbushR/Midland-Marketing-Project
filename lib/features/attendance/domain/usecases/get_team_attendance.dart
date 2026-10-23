import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../users/domain/entities/user.dart';
import '../../../users/domain/repositories/user_repository.dart';
import '../entities/attendance_filter.dart';
import '../entities/employee_attendance.dart';
import '../repositories/attendance_repository.dart';

/// Attendance of other employees, limited to what the viewer's role allows.
class GetTeamAttendance {
  const GetTeamAttendance({
    required AttendanceRepository attendanceRepository,
    required UserRepository userRepository,
  }) : _attendanceRepository = attendanceRepository,
       _userRepository = userRepository;

  final AttendanceRepository _attendanceRepository;
  final UserRepository _userRepository;

  Future<List<EmployeeAttendance>> call({
    required User viewer,
    AttendanceFilter filter = const AttendanceFilter(),
  }) async {
    if (!viewer.role.canViewTeamRecords) {
      throw const AttendanceException(
        'You do not have access to team attendance.',
      );
    }

    final users = await _userRepository.getUsers();
    final visibleUsers = {
      for (final user in users)
        if (viewer.role.canViewAttendanceOf(user.role)) user.id: user,
    };

    final records = await _attendanceRepository.getRecords();
    final query = filter.query.trim().toLowerCase();
    final results = <EmployeeAttendance>[];

    for (final record in records) {
      final employee = visibleUsers[record.userId];
      if (employee == null) continue;

      if (query.isNotEmpty && !employee.name.toLowerCase().contains(query)) {
        continue;
      }
      if (filter.role != null && employee.role != filter.role) continue;
      if (filter.date != null &&
          !AppDateUtils.isSameDay(record.date, filter.date!)) {
        continue;
      }
      results.add(EmployeeAttendance(employee: employee, record: record));
    }

    results.sort((a, b) {
      final byDate = b.record.date.compareTo(a.record.date);
      return byDate != 0 ? byDate : a.employee.name.compareTo(b.employee.name);
    });
    return results;
  }
}
