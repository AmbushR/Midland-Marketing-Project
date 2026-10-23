import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/attendance_history_bloc.dart';
import '../widgets/attendance_history_tile.dart';

/// The signed-in user's own attendance history (available to every role).
class AttendanceHistoryPage extends StatelessWidget {
  const AttendanceHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthBloc>().state.user;
    if (user == null) return const SizedBox.shrink();

    return BlocProvider(
      create: (_) =>
          sl<AttendanceHistoryBloc>()..add(AttendanceHistoryRequested(user.id)),
      child: Scaffold(
        appBar: AppBar(title: const Text('My attendance')),
        body: BlocBuilder<AttendanceHistoryBloc, AttendanceHistoryState>(
          builder: (context, state) {
            switch (state.status) {
              case HistoryStatus.loading:
                return const Center(child: CircularProgressIndicator());
              case HistoryStatus.failure:
                return ErrorView(
                  message: state.errorMessage ?? 'Something went wrong.',
                  onRetry: () => context.read<AttendanceHistoryBloc>().add(
                    AttendanceHistoryRequested(user.id),
                  ),
                );
              case HistoryStatus.loaded:
                if (state.records.isEmpty) {
                  return const EmptyState(
                    icon: Icons.event_busy_outlined,
                    message: 'No attendance records yet.',
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: state.records.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => AttendanceHistoryTile(
                    record: state.records[index],
                    owner: user,
                  ),
                );
            }
          },
        ),
      ),
    );
  }
}
