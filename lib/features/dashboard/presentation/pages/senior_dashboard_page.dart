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

class SeniorDashboardPage extends StatelessWidget {
  const SeniorDashboardPage({super.key, required this.user});

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
      child: HeroScaffold(
        user: user,
        children: [
          TodayAttendanceCard(userId: user.id),
          const SizedBox(height: 28),
          const SectionTitle('Quick links'),
          QuickLinkTile(
            icon: Icons.rate_review_outlined,
            title: 'Staff attendance & comments',
            subtitle: 'Review days and leave feedback',
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
          const SectionTitle('Staff overview'),
          TeamOverview(
            viewer: user,
            listTitle: "Today's staff attendance",
            emptyMessage: 'No staff have checked in today.',
            statsBuilder: (summary) => [
              StatCard(
                label: 'Total staff',
                value: summary.totalUsers,
                icon: Icons.groups_rounded,
                color: AppColors.primary,
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
    );
  }
}
