import '../entities/attendance_record.dart';

abstract class AttendanceRepository {
  Future<List<AttendanceRecord>> getRecords();

  Future<AttendanceRecord?> getRecordForDay(String userId, DateTime day);

  /// Inserts the record, or replaces the one with the same id.
  Future<void> saveRecord(AttendanceRecord record);
}
