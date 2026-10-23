import 'package:equatable/equatable.dart';

enum AttendanceStatus {
  notCheckedIn('Not checked in'),
  checkedIn('Checked in'),
  checkedOut('Checked out');

  const AttendanceStatus(this.label);

  final String label;
}

class AttendanceRecord extends Equatable {
  const AttendanceRecord({
    required this.id,
    required this.userId,
    required this.date,
    this.checkInTime,
    this.checkOutTime,
  });

  final String id;
  final String userId;

  /// Calendar day of the record (time part is always midnight).
  final DateTime date;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;

  bool get hasCheckedIn => checkInTime != null;

  bool get hasCheckedOut => checkOutTime != null;

  AttendanceStatus get status {
    if (checkInTime == null) return AttendanceStatus.notCheckedIn;
    if (checkOutTime == null) return AttendanceStatus.checkedIn;
    return AttendanceStatus.checkedOut;
  }

  AttendanceRecord withCheckOut(DateTime time) {
    return AttendanceRecord(
      id: id,
      userId: userId,
      date: date,
      checkInTime: checkInTime,
      checkOutTime: time,
    );
  }

  @override
  List<Object?> get props => [id, userId, date, checkInTime, checkOutTime];
}
