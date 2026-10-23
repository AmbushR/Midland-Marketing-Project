part of 'comments_bloc.dart';

enum CommentsStatus { loading, loaded, failure }

class CommentsState extends Equatable {
  const CommentsState({
    this.status = CommentsStatus.loading,
    this.comments = const [],
    this.addKind,
    this.submitting = false,
    this.errorMessage,
  });

  final CommentsStatus status;
  final List<AttendanceComment> comments;

  /// What the viewer may add here, or null when they can only read.
  final CommentKind? addKind;
  final bool submitting;
  final String? errorMessage;

  CommentsState copyWith({
    CommentsStatus? status,
    List<AttendanceComment>? comments,
    bool? submitting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CommentsState(
      status: status ?? this.status,
      comments: comments ?? this.comments,
      addKind: addKind,
      submitting: submitting ?? this.submitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    comments,
    addKind,
    submitting,
    errorMessage,
  ];
}
