import '../../../users/domain/entities/user.dart';
import '../../domain/entities/attendance_comment.dart';

class CommentModel extends AttendanceComment {
  const CommentModel({
    required super.id,
    required super.recordId,
    required super.authorId,
    required super.authorName,
    required super.authorRole,
    required super.kind,
    required super.text,
    required super.createdAt,
  });

  factory CommentModel.fromEntity(AttendanceComment comment) {
    return CommentModel(
      id: comment.id,
      recordId: comment.recordId,
      authorId: comment.authorId,
      authorName: comment.authorName,
      authorRole: comment.authorRole,
      kind: comment.kind,
      text: comment.text,
      createdAt: comment.createdAt,
    );
  }

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String,
      recordId: json['recordId'] as String,
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String,
      authorRole: UserRole.values.byName(json['authorRole'] as String),
      kind: CommentKind.values.byName(json['kind'] as String),
      text: json['text'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'recordId': recordId,
    'authorId': authorId,
    'authorName': authorName,
    'authorRole': authorRole.name,
    'kind': kind.name,
    'text': text,
    'createdAt': createdAt.toIso8601String(),
  };
}
