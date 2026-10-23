import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/date_utils.dart';
import '../entities/attendance_record.dart';
import '../repositories/attendance_repository.dart';

class CheckIn {
  CheckIn(this._repository, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AttendanceRepository _repository;
  final DateTime Function() _clock;

  Future<AttendanceRecord> call(String userId) async {
    final now = _clock();

    final existing = await _repository.getRecordForDay(userId, now);
    if (existing != null) {
      throw const AttendanceException('You have already checked in today.');
    }

    // One record per user per day: the id is built from both.
    final record = AttendanceRecord(
      id: '${userId}_${AppDateUtils.dayKey(now)}',
      userId: userId,
      date: AppDateUtils.dateOnly(now),
      checkInTime: now,
    );
    await _repository.saveRecord(record);
    return record;
  }
}
