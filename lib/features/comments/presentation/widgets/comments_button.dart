import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:midlandmarketing/core/di/injection.dart';
import 'package:midlandmarketing/core/theme/app_colors.dart';
import 'package:midlandmarketing/features/attendance/domain/entities/attendance_record.dart';
import 'package:midlandmarketing/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:midlandmarketing/features/comments/domain/entities/attendance_comment.dart';
import 'package:midlandmarketing/features/comments/domain/usecases/get_comments.dart';
import 'package:midlandmarketing/features/comments/presentation/widgets/comments_sheet.dart';
import 'package:midlandmarketing/features/users/domain/entities/user.dart';

/// Button under an attendance record that shows how many comments it has and
/// opens them. The label says what the signed-in user can do there.
class CommentsButton extends StatefulWidget {
  const CommentsButton({super.key, required this.record, required this.owner});

  final AttendanceRecord record;
  final User owner;

  @override
  State<CommentsButton> createState() => _CommentsButtonState();
}

class _CommentsButtonState extends State<CommentsButton> {
  int? _count;

  @override
  void initState() {
    super.initState();
    _loadCount();
  }

  @override
  void didUpdateWidget(CommentsButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.record.id != widget.record.id) _loadCount();
  }

  Future<void> _loadCount() async {
    try {
      final comments = await sl<GetComments>()(widget.record.id);
      if (mounted) setState(() => _count = comments.length);
    } catch (_) {
      // The label simply stays generic when the count cannot be read.
    }
  }

  Future<void> _open() async {
    await showCommentsSheet(
      context,
      record: widget.record,
      owner: widget.owner,
    );
    if (mounted) _loadCount();
  }

  @override
  Widget build(BuildContext context) {
    final viewer = context.read<AuthBloc>().state.user;
    final kind = viewer == null
        ? null
        : CommentPolicy.kindFor(author: viewer, owner: widget.owner);
    final count = _count ?? 0;

    final String label;
    if (count > 0) {
      label = count == 1 ? '1 comment' : '$count comments';
    } else if (kind == CommentKind.feedback) {
      label = 'Add comment';
    } else if (kind == CommentKind.note) {
      label = 'Add note';
    } else {
      label = 'No comments';
    }

    // Nothing to read and nothing the viewer can add: keep it quiet.
    final enabled = count > 0 || kind != null;

    return TextButton.icon(
      onPressed: enabled ? _open : null,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
      ),
      icon: Icon(
        count > 0
            ? Icons.chat_bubble_rounded
            : Icons.chat_bubble_outline_rounded,
        size: 17,
      ),
      label: Text(label),
    );
  }
}
