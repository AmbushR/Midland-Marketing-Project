import '../../domain/entities/attendance_record.dart';

class AttendanceModel extends AttendanceRecord {
  const AttendanceModel({
    required super.id,
    required super.userId,
    required super.date,
    super.checkInTime,
    super.checkOutTime,
  });

  factory AttendanceModel.fromEntity(AttendanceRecord record) {
    return AttendanceModel(
      id: record.id,
      userId: record.userId,
      date: record.date,
      checkInTime: record.checkInTime,
      checkOutTime: record.checkOutTime,
    );
  }

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      date: DateTime.parse(json['date'] as String),
      checkInTime: _parseTime(json['checkInTime']),
      checkOutTime: _parseTime(json['checkOutTime']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'date': date.toIso8601String(),
    'checkInTime': checkInTime?.toIso8601String(),
    'checkOutTime': checkOutTime?.toIso8601String(),
    'status': status.name,
  };

  static DateTime? _parseTime(Object? value) {
    return value == null ? null : DateTime.parse(value as String);
  }
}
