import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:midlandmarketing/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:midlandmarketing/features/dashboard/presentation/pages/admin_dashboard_page.dart';
import 'package:midlandmarketing/features/dashboard/presentation/pages/senior_dashboard_page.dart';
import 'package:midlandmarketing/features/dashboard/presentation/pages/staff_dashboard_page.dart';
import 'package:midlandmarketing/features/users/domain/entities/user.dart';

/// Picks the dashboard that matches the role of the signed-in user.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthBloc bloc) => bloc.state.user);
    if (user == null) return const SizedBox.shrink();

    switch (user.role) {
      case UserRole.admin:
        return AdminDashboardPage(user: user);
      case UserRole.seniorStaff:
        return SeniorDashboardPage(user: user);
      case UserRole.staff:
        return StaffDashboardPage(user: user);
    }
  }
}
