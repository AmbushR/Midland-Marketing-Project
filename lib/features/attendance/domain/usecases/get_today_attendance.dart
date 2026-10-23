import '../entities/attendance_record.dart';
import '../repositories/attendance_repository.dart';

class GetTodayAttendance {
  const GetTodayAttendance(this._repository);

  final AttendanceRepository _repository;

  Future<AttendanceRecord?> call(String userId) {
    return _repository.getRecordForDay(userId, DateTime.now());
  }
}
