import '../entities/attendance_comment.dart';
import '../repositories/comment_repository.dart';

class GetComments {
  const GetComments(this._repository);

  final CommentRepository _repository;

  Future<List<AttendanceComment>> call(String recordId) =>
      _repository.getForRecord(recordId);
}
