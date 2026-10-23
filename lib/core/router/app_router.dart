import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:midlandmarketing/core/router/app_routes.dart';
import 'package:midlandmarketing/core/router/go_router_refresh_stream.dart';
import 'package:midlandmarketing/features/attendance/presentation/pages/attendance_history_page.dart';
import 'package:midlandmarketing/features/attendance/presentation/pages/team_records_page.dart';
import 'package:midlandmarketing/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:midlandmarketing/features/auth/presentation/pages/login_page.dart';
import 'package:midlandmarketing/features/auth/presentation/pages/splash_page.dart';
import 'package:midlandmarketing/features/dashboard/presentation/pages/home_page.dart';
import 'package:midlandmarketing/features/users/presentation/pages/users_page.dart';

class AppRouter {
  AppRouter(this._authBloc);

  final AuthBloc _authBloc;

  late final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: GoRouterRefreshStream(_authBloc.stream),
    redirect: _redirect,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.history,
        builder: (context, state) => const AttendanceHistoryPage(),
      ),
      GoRoute(
        path: AppRoutes.records,
        builder: (context, state) => const TeamRecordsPage(),
      ),
      GoRoute(
        path: AppRoutes.users,
        builder: (context, state) => const UsersPage(),
      ),
    ],
  );

  /// Central place for access control: who can open which screen.
  String? _redirect(BuildContext context, GoRouterState state) {
    final auth = _authBloc.state;
    final location = state.matchedLocation;

    // Still restoring the saved session.
    if (auth.status == AuthStatus.unknown) {
      return location == AppRoutes.splash ? null : AppRoutes.splash;
    }

    final user = auth.user;
    if (!auth.isAuthenticated || user == null) {
      return location == AppRoutes.login ? null : AppRoutes.login;
    }

    if (location == AppRoutes.login || location == AppRoutes.splash) {
      return AppRoutes.home;
    }
    if (location == AppRoutes.records && !user.role.canViewTeamRecords) {
      return AppRoutes.home;
    }
    if (location == AppRoutes.users && !user.role.canManageUsers) {
      return AppRoutes.home;
    }
    return null;
  }
}
