import '../../domain/entities/attendance_comment.dart';
import '../../domain/repositories/comment_repository.dart';
import '../datasources/comment_local_data_source.dart';
import '../models/comment_model.dart';

class CommentRepositoryImpl implements CommentRepository {
  CommentRepositoryImpl(this._dataSource);

  final CommentLocalDataSource _dataSource;

  @override
  Future<List<AttendanceComment>> getForRecord(String recordId) async {
    final all = await _dataSource.getComments();
    final own = all.where((comment) => comment.recordId == recordId).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return own;
  }

  @override
  Future<void> add(AttendanceComment comment) async {
    final all = await _dataSource.getComments();
    all.add(CommentModel.fromEntity(comment));
    await _dataSource.saveComments(all);
  }
}
