import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:midlandmarketing/core/di/injection.dart';
import 'package:midlandmarketing/core/router/app_routes.dart';
import 'package:midlandmarketing/core/theme/app_colors.dart';
import 'package:midlandmarketing/core/widgets/hero_scaffold.dart';
import 'package:midlandmarketing/core/widgets/quick_link_tile.dart';
import 'package:midlandmarketing/core/widgets/section_title.dart';
import 'package:midlandmarketing/core/widgets/stat_card.dart';
import 'package:midlandmarketing/features/attendance/presentation/bloc/today_attendance_bloc.dart';
import 'package:midlandmarketing/features/attendance/presentation/widgets/today_attendance_card.dart';
import 'package:midlandmarketing/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:midlandmarketing/features/dashboard/presentation/widgets/team_overview.dart';
import 'package:midlandmarketing/features/users/domain/entities/user.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<DashboardBloc>()..add(DashboardRequested(user)),
        ),
        BlocProvider(
          create: (_) =>
              sl<TodayAttendanceBloc>()..add(TodayAttendanceRequested(user.id)),
        ),
      ],
      // The admin can check in too, which changes today's numbers.
      child: BlocListener<TodayAttendanceBloc, TodayAttendanceState>(
        listenWhen: (previous, current) =>
            previous.status == TodayAttendanceStatus.submitting &&
            current.status == TodayAttendanceStatus.loaded &&
            current.errorMessage == null,
        listener: (context, _) =>
            context.read<DashboardBloc>().add(DashboardRequested(user)),
        child: HeroScaffold(
          user: user,
          children: [
            TodayAttendanceCard(userId: user.id),
            const SizedBox(height: 28),
            const SectionTitle('Manage'),
            QuickLinkTile(
              icon: Icons.person_add_alt_1_rounded,
              title: 'Add senior staff & staff',
              subtitle: 'Create logins and manage your team',
              color: AppColors.rose,
              onTap: () => context.push(AppRoutes.users),
            ),
            const SizedBox(height: 12),
            QuickLinkTile(
              icon: Icons.fact_check_outlined,
              title: 'Attendance records',
              subtitle: 'Everyone, with comments',
              color: AppColors.primary,
              onTap: () => context.push(AppRoutes.records),
            ),
            const SizedBox(height: 12),
            QuickLinkTile(
              icon: Icons.history_rounded,
              title: 'My attendance history',
              subtitle: 'Your own days and notes',
              color: AppColors.teal,
              onTap: () => context.push(AppRoutes.history),
            ),
            const SizedBox(height: 28),
            const SectionTitle('Overview'),
            TeamOverview(
              viewer: user,
              listTitle: 'Recent attendance',
              emptyMessage: 'No attendance records yet.',
              statsBuilder: (summary) => [
                StatCard(
                  label: 'Total users',
                  value: summary.totalUsers,
                  icon: Icons.groups_rounded,
                  color: AppColors.primary,
                ),
                StatCard(
                  label: 'Staff',
                  value: summary.staffCount,
                  icon: Icons.badge_outlined,
                  color: AppColors.teal,
                ),
                StatCard(
                  label: 'Senior staff',
                  value: summary.seniorStaffCount,
                  icon: Icons.workspace_premium_outlined,
                  color: AppColors.violet,
                ),
                StatCard(
                  label: 'Checked in today',
                  value: summary.checkedInToday,
                  icon: Icons.login_rounded,
                  color: AppColors.success,
                ),
                StatCard(
                  label: 'Not checked in today',
                  value: summary.notCheckedInToday,
                  icon: Icons.person_off_outlined,
                  color: AppColors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
