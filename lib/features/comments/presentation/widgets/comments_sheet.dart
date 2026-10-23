import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:midlandmarketing/core/di/injection.dart';
import 'package:midlandmarketing/core/theme/app_colors.dart';
import 'package:midlandmarketing/core/utils/date_utils.dart';
import 'package:midlandmarketing/core/widgets/empty_state.dart';
import 'package:midlandmarketing/core/widgets/role_badge.dart';
import 'package:midlandmarketing/core/widgets/user_avatar.dart';
import 'package:midlandmarketing/features/attendance/domain/entities/attendance_record.dart';
import 'package:midlandmarketing/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:midlandmarketing/features/comments/domain/entities/attendance_comment.dart';
import 'package:midlandmarketing/features/comments/domain/usecases/add_comment.dart';
import 'package:midlandmarketing/features/comments/presentation/bloc/comments_bloc.dart';
import 'package:midlandmarketing/features/users/domain/entities/user.dart';

/// Opens the comments of [record] (which belongs to [owner]) in a bottom sheet.
Future<void> showCommentsSheet(
  BuildContext context, {
  required AttendanceRecord record,
  required User owner,
}) async {
  final viewer = context.read<AuthBloc>().state.user;
  if (viewer == null) return;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => BlocProvider(
      create: (_) => sl<CommentsBloc>()
        ..add(
          CommentsStarted(viewer: viewer, owner: owner, recordId: record.id),
        ),
      child: _CommentsSheet(record: record, owner: owner),
    ),
  );
}

class _CommentsSheet extends StatefulWidget {
  const _CommentsSheet({required this.record, required this.owner});

  final AttendanceRecord record;
  final User owner;

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send() {
    context.read<CommentsBloc>().add(CommentSubmitted(_controller.text));
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<CommentsBloc, CommentsState>(
      listenWhen: (previous, current) =>
          previous.submitting &&
          !current.submitting &&
          current.errorMessage == null,
      listener: (context, state) {
        _controller.clear();
        _scrollToEnd();
      },
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.85,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 14),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: AppColors.heroGradient,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.forum_outlined,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Comments',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              '${widget.owner.name}  ·  '
                              '${AppDateUtils.longDate(widget.record.date)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Flexible(child: _buildList(context, state)),
                const Divider(),
                _buildFooter(context, state),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildList(BuildContext context, CommentsState state) {
    if (state.status == CommentsStatus.loading) {
      return const SizedBox(
        height: 160,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    // EmptyState centres itself, so it is placed in a scroll view to keep the
    // sheet only as tall as its content.
    if (state.status == CommentsStatus.failure) {
      return SingleChildScrollView(
        child: EmptyState(
          icon: Icons.error_outline,
          message: state.errorMessage ?? 'Could not load comments.',
        ),
      );
    }
    if (state.comments.isEmpty) {
      return SingleChildScrollView(
        child: EmptyState(
          icon: Icons.chat_bubble_outline_rounded,
          message: switch (state.addKind) {
            CommentKind.feedback =>
              'No comments yet.\nShare some feedback on this day.',
            CommentKind.note =>
              'No notes yet.\nAdd a quick note about your work.',
            null => 'No comments on this record yet.',
          },
        ),
      );
    }
    return ListView.separated(
      controller: _scrollController,
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      itemCount: state.comments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) =>
          _CommentBubble(comment: state.comments[index]),
    );
  }

  Widget _buildFooter(BuildContext context, CommentsState state) {
    final kind = state.addKind;

    if (kind == null) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(24, 16, 24, 20),
        child: Row(
          children: [
            Icon(Icons.visibility_outlined, size: 18, color: AppColors.muted),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'View only. Senior staff add feedback and staff add their own notes.',
                style: TextStyle(color: AppColors.muted, fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }

    final hint = kind == CommentKind.feedback
        ? 'Write feedback for ${widget.owner.name.split(' ').first}…'
        : 'Add a note about your day…';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (state.errorMessage != null &&
              state.status == CommentsStatus.loaded)
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 8),
              child: Text(
                state.errorMessage!,
                style: const TextStyle(color: AppColors.danger, fontSize: 13),
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  minLines: 1,
                  maxLines: 4,
                  maxLength: AddComment.maxLength,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: hint,
                    counterText: '',
                    isDense: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                tooltip: 'Send',
                onPressed: state.submitting ? null : _send,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(48, 48),
                ),
                icon: state.submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CommentBubble extends StatelessWidget {
  const _CommentBubble({required this.comment});

  final AttendanceComment comment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFeedback = comment.kind == CommentKind.feedback;
    final tint = isFeedback ? AppColors.primary : AppColors.teal;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UserAvatar(
          name: comment.authorName,
          role: comment.authorRole,
          size: 38,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    comment.authorName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  RoleBadge(role: comment.authorRole),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '${comment.kind.label}  ·  '
                '${AppDateUtils.formatRelative(comment.createdAt)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: 0.08),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Text(
                  comment.text,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
