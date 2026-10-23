import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:midlandmarketing/core/widgets/empty_state.dart';
import 'package:midlandmarketing/core/widgets/error_view.dart';
import 'package:midlandmarketing/core/widgets/section_title.dart';
import 'package:midlandmarketing/core/widgets/stat_card.dart';
import 'package:midlandmarketing/features/attendance/presentation/widgets/employee_attendance_tile.dart';
import 'package:midlandmarketing/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:midlandmarketing/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:midlandmarketing/features/users/domain/entities/user.dart';

/// Summary cards plus an attendance list, shared by the Admin and Senior Staff
/// dashboards. Needs a [DashboardBloc] above it in the widget tree.
class TeamOverview extends StatelessWidget {
  const TeamOverview({
    super.key,
    required this.viewer,
    required this.statsBuilder,
    required this.listTitle,
    required this.emptyMessage,
  });

  final User viewer;
  final List<StatCard> Function(DashboardSummary summary) statsBuilder;
  final String listTitle;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        final summary = state.summary;

        if (state.status == DashboardStatus.loading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.status == DashboardStatus.failure || summary == null) {
          return ErrorView(
            message: state.errorMessage ?? 'Could not load the dashboard.',
            onRetry: () =>
                context.read<DashboardBloc>().add(DashboardRequested(viewer)),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StatGrid(cards: statsBuilder(summary)),
            const SizedBox(height: 28),
            SectionTitle(listTitle),
            if (summary.entries.isEmpty)
              EmptyState(message: emptyMessage)
            else
              for (final entry in summary.entries)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: EmployeeAttendanceTile(entry: entry),
                ),
          ],
        );
      },
    );
  }
}
