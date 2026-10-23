import '../../../../core/error/exceptions.dart';
import '../../../users/domain/entities/user.dart';
import '../../../users/domain/repositories/user_repository.dart';
import '../entities/attendance_comment.dart';
import '../repositories/comment_repository.dart';

class AddComment {
  AddComment({
    required CommentRepository commentRepository,
    required UserRepository userRepository,
    DateTime Function()? clock,
  }) : _commentRepository = commentRepository,
       _userRepository = userRepository,
       _clock = clock ?? DateTime.now;

  final CommentRepository _commentRepository;
  final UserRepository _userRepository;
  final DateTime Function() _clock;

  static const maxLength = 300;

  Future<AttendanceComment> call({
    required User author,
    required String recordId,
    required String ownerId,
    required String text,
  }) async {
    final body = text.trim();
    if (body.isEmpty) {
      throw const CommentException('Please write something first.');
    }
    if (body.length > maxLength) {
      throw const CommentException(
        'Please keep it under $maxLength characters.',
      );
    }

    final users = await _userRepository.getUsers();
    User? owner;
    for (final user in users) {
      if (user.id == ownerId) owner = user;
    }
    if (owner == null) {
      throw const CommentException('This record could not be found.');
    }

    final kind = CommentPolicy.kindFor(author: author, owner: owner);
    if (kind == null) {
      throw const CommentException(
        'You are not allowed to comment on this record.',
      );
    }

    final now = _clock();
    final comment = AttendanceComment(
      id: 'c${now.microsecondsSinceEpoch}',
      recordId: recordId,
      authorId: author.id,
      authorName: author.name,
      authorRole: author.role,
      kind: kind,
      text: body,
      createdAt: now,
    );
    await _commentRepository.add(comment);
    return comment;
  }
}
