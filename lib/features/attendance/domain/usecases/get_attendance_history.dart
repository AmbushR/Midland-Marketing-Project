import '../entities/attendance_record.dart';
import '../repositories/attendance_repository.dart';

class GetAttendanceHistory {
  const GetAttendanceHistory(this._repository);

  final AttendanceRepository _repository;

  /// Records of one user, latest first.
  Future<List<AttendanceRecord>> call(String userId) async {
    final records = await _repository.getRecords();
    final own = records.where((record) => record.userId == userId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return own;
  }
}
