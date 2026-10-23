import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:midlandmarketing/core/di/injection.dart';
import 'package:midlandmarketing/core/router/app_routes.dart';
import 'package:midlandmarketing/core/theme/app_colors.dart';
import 'package:midlandmarketing/core/widgets/hero_scaffold.dart';
import 'package:midlandmarketing/core/widgets/quick_link_tile.dart';
import 'package:midlandmarketing/core/widgets/section_title.dart';
import 'package:midlandmarketing/features/attendance/presentation/bloc/today_attendance_bloc.dart';
import 'package:midlandmarketing/features/attendance/presentation/widgets/today_attendance_card.dart';
import 'package:midlandmarketing/features/users/domain/entities/user.dart';

class StaffDashboardPage extends StatelessWidget {
  const StaffDashboardPage({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<TodayAttendanceBloc>()..add(TodayAttendanceRequested(user.id)),
      child: HeroScaffold(
        user: user,
        children: [
          TodayAttendanceCard(userId: user.id),
          const SizedBox(height: 28),
          const SectionTitle('Quick links'),
          QuickLinkTile(
            icon: Icons.history_rounded,
            title: 'My attendance history',
            subtitle: 'Past days, notes and feedback',
            color: AppColors.teal,
            onTap: () => context.push(AppRoutes.history),
          ),
        ],
      ),
    );
  }
}
