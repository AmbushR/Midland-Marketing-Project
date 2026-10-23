import 'package:equatable/equatable.dart';

import '../../../users/domain/entities/user.dart';

enum CommentKind {
  /// A senior staff member commenting on a staff member's day.
  feedback('Feedback'),

  /// Someone writing a note on their own attendance record.
  note('Work note');

  const CommentKind(this.label);

  final String label;
}

class AttendanceComment extends Equatable {
  const AttendanceComment({
    required this.id,
    required this.recordId,
    required this.authorId,
    required this.authorName,
    required this.authorRole,
    required this.kind,
    required this.text,
    required this.createdAt,
  });

  final String id;
  final String recordId;
  final String authorId;
  final String authorName;
  final UserRole authorRole;
  final CommentKind kind;
  final String text;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
    id,
    recordId,
    authorId,
    authorName,
    authorRole,
    kind,
    text,
    createdAt,
  ];
}

/// Who may write on whose attendance record.
///
/// * Everyone can add a work note to their own record.
/// * Senior staff can add feedback to a staff member's record.
/// * Admin can read comments but not write on other people's records.
class CommentPolicy {
  const CommentPolicy._();

  /// The kind of comment [author] may add to a record owned by [owner],
  /// or null when they may not comment at all.
  static CommentKind? kindFor({required User author, required User owner}) {
    if (author.id == owner.id) return CommentKind.note;
    if (author.role == UserRole.seniorStaff && owner.role == UserRole.staff) {
      return CommentKind.feedback;
    }
    return null;
  }
}
