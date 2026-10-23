import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/attendance_record.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../datasources/attendance_local_data_source.dart';
import '../models/attendance_model.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  AttendanceRepositoryImpl(this._dataSource);

  final AttendanceLocalDataSource _dataSource;

  @override
  Future<List<AttendanceRecord>> getRecords() => _dataSource.getRecords();

  @override
  Future<AttendanceRecord?> getRecordForDay(String userId, DateTime day) async {
    final records = await _dataSource.getRecords();
    for (final record in records) {
      if (record.userId == userId && AppDateUtils.isSameDay(record.date, day)) {
        return record;
      }
    }
    return null;
  }

  @override
  Future<void> saveRecord(AttendanceRecord record) async {
    final records = await _dataSource.getRecords();
    final model = AttendanceModel.fromEntity(record);
    final index = records.indexWhere((r) => r.id == record.id);

    if (index == -1) {
      records.add(model);
    } else {
      records[index] = model;
    }
    await _dataSource.saveRecords(records);
  }
}
