import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../users/domain/entities/user.dart';
import '../bloc/team_records_bloc.dart';
import '../widgets/employee_attendance_tile.dart';

/// Attendance of other employees. Admin sees everyone, Senior Staff sees Staff
/// only (the rule itself lives in the GetTeamAttendance use case).
class TeamRecordsPage extends StatelessWidget {
  const TeamRecordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthBloc>().state.user;
    if (user == null) return const SizedBox.shrink();

    return BlocProvider(
      create: (_) => sl<TeamRecordsBloc>()..add(TeamRecordsStarted(user)),
      child: _TeamRecordsView(viewer: user),
    );
  }
}

class _TeamRecordsView extends StatelessWidget {
  const _TeamRecordsView({required this.viewer});

  final User viewer;

  Future<void> _pickDate(BuildContext context, DateTime? current) async {
    final bloc = context.read<TeamRecordsBloc>();
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: now,
    );
    if (picked != null) bloc.add(TeamDateChanged(picked));
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = viewer.role == UserRole.admin;

    return Scaffold(
      appBar: AppBar(
        title: Text(isAdmin ? 'Attendance records' : 'Staff attendance'),
      ),
      body: BlocBuilder<TeamRecordsBloc, TeamRecordsState>(
        builder: (context, state) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      onChanged: (value) => context.read<TeamRecordsBloc>().add(
                        TeamSearchChanged(value),
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Search by employee name',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ActionChip(
                            avatar: const Icon(
                              Icons.calendar_today_rounded,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            label: Text(
                              state.filter.date == null
                                  ? 'Any date'
                                  : AppDateUtils.formatDate(state.filter.date!),
                            ),
                            onPressed: () =>
                                _pickDate(context, state.filter.date),
                          ),
                          if (state.filter.date != null) ...[
                            const SizedBox(width: 4),
                            IconButton(
                              tooltip: 'Clear date',
                              icon: const Icon(Icons.close_rounded, size: 20),
                              onPressed: () => context
                                  .read<TeamRecordsBloc>()
                                  .add(const TeamDateChanged(null)),
                            ),
                          ],
                          if (isAdmin) ...[
                            const SizedBox(width: 8),
                            _RoleChip(
                              label: 'All roles',
                              selected: state.filter.role == null,
                              onTap: () => context.read<TeamRecordsBloc>().add(
                                const TeamRoleChanged(null),
                              ),
                            ),
                            for (final role in UserRole.values) ...[
                              const SizedBox(width: 8),
                              _RoleChip(
                                label: role.label,
                                selected: state.filter.role == role,
                                onTap: () => context
                                    .read<TeamRecordsBloc>()
                                    .add(TeamRoleChanged(role)),
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: _buildResults(context, state)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildResults(BuildContext context, TeamRecordsState state) {
    switch (state.status) {
      case TeamRecordsStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case TeamRecordsStatus.failure:
        return ErrorView(
          message: state.errorMessage ?? 'Something went wrong.',
          onRetry: () =>
              context.read<TeamRecordsBloc>().add(TeamRecordsStarted(viewer)),
        );
      case TeamRecordsStatus.loaded:
        if (state.entries.isEmpty) {
          return const EmptyState(
            icon: Icons.search_off_rounded,
            message: 'No attendance records match your filters.',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: state.entries.length + 1,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Text(
                '${state.entries.length} '
                '${state.entries.length == 1 ? 'record' : 'records'}',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.muted,
                ),
              );
            }
            return EmployeeAttendanceTile(entry: state.entries[index - 1]);
          },
        );
    }
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      onSelected: (_) => onTap(),
      labelStyle: TextStyle(
        fontWeight: FontWeight.w700,
        color: selected ? AppColors.primary : AppColors.ink,
      ),
      side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
    );
  }
}
