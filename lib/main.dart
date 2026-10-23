import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();

  final authBloc = sl<AuthBloc>()..add(const AuthStarted());
  final router = AppRouter(authBloc).router;

  runApp(AttendanceApp(authBloc: authBloc, router: router));
}

class AttendanceApp extends StatelessWidget {
  const AttendanceApp({
    super.key,
    required this.authBloc,
    required this.router,
  });

  final AuthBloc authBloc;
  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: authBloc,
      child: MaterialApp.router(
        title: 'Attendance Manager',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: router,
      ),
    );
  }
}
