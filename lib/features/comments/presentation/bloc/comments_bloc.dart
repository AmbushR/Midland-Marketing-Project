import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/exceptions.dart';
import '../../../users/domain/entities/user.dart';
import '../../domain/entities/attendance_comment.dart';
import '../../domain/usecases/add_comment.dart';
import '../../domain/usecases/get_comments.dart';

part 'comments_event.dart';
part 'comments_state.dart';

/// Comments of one attendance record, shown inside the comments sheet.
class CommentsBloc extends Bloc<CommentsEvent, CommentsState> {
  CommentsBloc({
    required GetComments getComments,
    required AddComment addComment,
  }) : _getComments = getComments,
       _addComment = addComment,
       super(const CommentsState()) {
    on<CommentsStarted>(_onStarted);
    on<CommentSubmitted>(_onSubmitted);
  }

  final GetComments _getComments;
  final AddComment _addComment;

  User? _viewer;
  User? _owner;
  String? _recordId;

  Future<void> _onStarted(
    CommentsStarted event,
    Emitter<CommentsState> emit,
  ) async {
    _viewer = event.viewer;
    _owner = event.owner;
    _recordId = event.recordId;

    final kind = CommentPolicy.kindFor(
      author: event.viewer,
      owner: event.owner,
    );
    emit(CommentsState(addKind: kind));

    try {
      final comments = await _getComments(event.recordId);
      emit(
        CommentsState(
          status: CommentsStatus.loaded,
          comments: comments,
          addKind: kind,
        ),
      );
    } catch (_) {
      emit(
        CommentsState(
          status: CommentsStatus.failure,
          addKind: kind,
          errorMessage: 'Could not load comments.',
        ),
      );
    }
  }

  Future<void> _onSubmitted(
    CommentSubmitted event,
    Emitter<CommentsState> emit,
  ) async {
    final viewer = _viewer;
    final owner = _owner;
    final recordId = _recordId;
    if (viewer == null || owner == null || recordId == null) return;
    if (state.submitting) return;

    emit(state.copyWith(submitting: true, clearError: true));
    try {
      await _addComment(
        author: viewer,
        recordId: recordId,
        ownerId: owner.id,
        text: event.text,
      );
      final comments = await _getComments(recordId);
      emit(
        state.copyWith(
          status: CommentsStatus.loaded,
          comments: comments,
          submitting: false,
          clearError: true,
        ),
      );
    } on AppException catch (e) {
      emit(state.copyWith(submitting: false, errorMessage: e.message));
    } catch (_) {
      emit(
        state.copyWith(
          submitting: false,
          errorMessage: 'Could not save your comment. Please try again.',
        ),
      );
    }
  }
}
