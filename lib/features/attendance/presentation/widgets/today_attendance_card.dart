import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../comments/presentation/widgets/comments_button.dart';
import '../../domain/entities/attendance_record.dart';
import '../bloc/today_attendance_bloc.dart';
import 'attendance_status_chip.dart';
import 'attendance_times.dart';

/// Shows today's attendance for [userId] with the check in / check out action.
/// Needs a [TodayAttendanceBloc] above it in the widget tree.
class TodayAttendanceCard extends StatelessWidget {
  const TodayAttendanceCard({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TodayAttendanceBloc, TodayAttendanceState>(
      listenWhen: (previous, current) =>
          current.status != TodayAttendanceStatus.failure &&
          current.errorMessage != null &&
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
      },
      builder: (context, state) {
        return AppCard(
          padding: const EdgeInsets.all(18),
          child: _buildContent(context, state),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, TodayAttendanceState state) {
    if (state.status == TodayAttendanceStatus.loading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.status == TodayAttendanceStatus.failure) {
      return ErrorView(
        message: state.errorMessage ?? 'Something went wrong.',
        onRetry: () => context.read<TodayAttendanceBloc>().add(
          TodayAttendanceRequested(userId),
        ),
      );
    }

    final theme = Theme.of(context);
    final record = state.record;
    final status = record?.status ?? AttendanceStatus.notCheckedIn;
    final isSubmitting = state.status == TodayAttendanceStatus.submitting;
    final viewer = context.read<AuthBloc>().state.user;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TODAY',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.muted,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppDateUtils.formatDate(DateTime.now()),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            AttendanceStatusChip(status: status),
          ],
        ),
        const SizedBox(height: 16),
        AttendanceTimes(
          checkIn: record?.checkInTime,
          checkOut: record?.checkOutTime,
        ),
        const SizedBox(height: 16),
        _buildAction(context, status, isSubmitting),
        if (record != null && viewer != null) ...[
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.center,
            child: CommentsButton(record: record, owner: viewer),
          ),
        ],
      ],
    );
  }

  /// Beautiful confirmation dialog for check-in / check-out.
  Future<void> _confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    required IconData icon,
    required Color color,
    required VoidCallback onConfirm,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        elevation: 12,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),

        // Icon badge
        icon: Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 30),
            ),
          ),
        ),

        // Title
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF242424),
            letterSpacing: -0.4,
          ),
        ),

        // Message and information
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F9FA),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEAEEF0)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, color: color, size: 21),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Please verify your attendance action before continuing.',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
        actions: [
          Row(
            children: [
              // Cancel button
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(false);
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 50),
                    foregroundColor: const Color(0xFF555555),
                    side: const BorderSide(color: Color(0xFFDDE2E5)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Confirm button
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(true);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 50),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 19,
                  ),
                  label: Text(
                    confirmLabel,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed == true) {
      onConfirm();
    }
  }

  Widget _buildAction(
    BuildContext context,
    AttendanceStatus status,
    bool isSubmitting,
  ) {
    final bloc = context.read<TodayAttendanceBloc>();

    switch (status) {
      case AttendanceStatus.notCheckedIn:
        return _ActionButton(
          label: 'Check in',
          icon: Icons.login_rounded,
          color: AppColors.success,
          isLoading: isSubmitting,
          onPressed: () => _confirm(
            context,
            title: 'Confirm check in',
            message:
                'Check in now at ${AppDateUtils.formatTime(DateTime.now())}?',
            confirmLabel: 'Check in',
            icon: Icons.login_rounded,
            color: AppColors.success,
            onConfirm: () => bloc.add(const CheckInPressed()),
          ),
        );
      case AttendanceStatus.checkedIn:
        return _ActionButton(
          label: 'Check out',
          icon: Icons.logout_rounded,
          color: AppColors.orange,
          isLoading: isSubmitting,
          onPressed: () => _confirm(
            context,
            title: 'Confirm check out',
            message:
                'Check out now at ${AppDateUtils.formatTime(DateTime.now())}? '
                'You cannot check in again today.',
            confirmLabel: 'Check out',
            icon: Icons.logout_rounded,
            color: AppColors.orange,
            onConfirm: () => bloc.add(const CheckOutPressed()),
          ),
        );
      case AttendanceStatus.checkedOut:
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_rounded, color: AppColors.success),
              SizedBox(width: 8),
              Text(
                "You're all done for today",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF047857),
                ),
              ),
            ],
          ),
        );
    }
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: color,
          minimumSize: const Size(64, 54),
        ),
        icon: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(icon),
        label: Text(label),
      ),
    );
  }
}
