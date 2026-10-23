import 'package:equatable/equatable.dart';

import '../../../users/domain/entities/user.dart';
import 'attendance_record.dart';

/// An attendance record together with the employee it belongs to.
class EmployeeAttendance extends Equatable {
  const EmployeeAttendance({required this.employee, required this.record});

  final User employee;
  final AttendanceRecord record;

  @override
  List<Object?> get props => [employee, record];
}
