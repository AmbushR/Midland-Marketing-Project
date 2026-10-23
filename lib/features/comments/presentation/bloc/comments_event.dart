part of 'comments_bloc.dart';

sealed class CommentsEvent extends Equatable {
  const CommentsEvent();

  @override
  List<Object?> get props => [];
}

class CommentsStarted extends CommentsEvent {
  const CommentsStarted({
    required this.viewer,
    required this.owner,
    required this.recordId,
  });

  /// The signed-in user.
  final User viewer;

  /// The person the attendance record belongs to.
  final User owner;
  final String recordId;

  @override
  List<Object?> get props => [viewer, owner, recordId];
}

class CommentSubmitted extends CommentsEvent {
  const CommentSubmitted(this.text);

  final String text;

  @override
  List<Object?> get props => [text];
}
