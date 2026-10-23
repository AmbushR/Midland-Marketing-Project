import '../entities/attendance_comment.dart';

abstract class CommentRepository {
  /// Comments of one attendance record, oldest first.
  Future<List<AttendanceComment>> getForRecord(String recordId);

  Future<void> add(AttendanceComment comment);
}
