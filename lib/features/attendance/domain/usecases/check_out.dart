import '../../../../core/error/exceptions.dart';
import '../entities/attendance_record.dart';
import '../repositories/attendance_repository.dart';

class CheckOut {
  CheckOut(this._repository, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AttendanceRepository _repository;
  final DateTime Function() _clock;

  Future<AttendanceRecord> call(String userId) async {
    final now = _clock();

    final today = await _repository.getRecordForDay(userId, now);
    if (today == null || !today.hasCheckedIn) {
      throw const AttendanceException('Please check in before checking out.');
    }
    if (today.hasCheckedOut) {
      throw const AttendanceException('You have already checked out today.');
    }

    final updated = today.withCheckOut(now);
    await _repository.saveRecord(updated);
    return updated;
  }
}
