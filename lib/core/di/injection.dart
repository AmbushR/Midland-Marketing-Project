import 'package:get_it/get_it.dart';
import 'package:midlandmarketing/features/attendance/data/datasources/attendance_local_data_source.dart';
import 'package:midlandmarketing/features/attendance/data/repositories/attendance_repository_impl.dart';
import 'package:midlandmarketing/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:midlandmarketing/features/attendance/domain/usecases/check_in.dart';
import 'package:midlandmarketing/features/attendance/domain/usecases/check_out.dart';
import 'package:midlandmarketing/features/attendance/domain/usecases/get_attendance_history.dart';
import 'package:midlandmarketing/features/attendance/domain/usecases/get_team_attendance.dart';
import 'package:midlandmarketing/features/attendance/domain/usecases/get_today_attendance.dart';
import 'package:midlandmarketing/features/attendance/presentation/bloc/attendance_history_bloc.dart';
import 'package:midlandmarketing/features/attendance/presentation/bloc/team_records_bloc.dart';
import 'package:midlandmarketing/features/attendance/presentation/bloc/today_attendance_bloc.dart';
import 'package:midlandmarketing/features/auth/data/datasources/session_local_data_source.dart';
import 'package:midlandmarketing/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:midlandmarketing/features/auth/domain/repositories/auth_repository.dart';
import 'package:midlandmarketing/features/auth/domain/usecases/get_current_user.dart';
import 'package:midlandmarketing/features/auth/domain/usecases/login_user.dart';
import 'package:midlandmarketing/features/auth/domain/usecases/logout_user.dart';
import 'package:midlandmarketing/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:midlandmarketing/features/comments/data/datasources/comment_local_data_source.dart';
import 'package:midlandmarketing/features/comments/data/repositories/comment_repository_impl.dart';
import 'package:midlandmarketing/features/comments/domain/repositories/comment_repository.dart';
import 'package:midlandmarketing/features/comments/domain/usecases/add_comment.dart';
import 'package:midlandmarketing/features/comments/domain/usecases/get_comments.dart';
import 'package:midlandmarketing/features/comments/presentation/bloc/comments_bloc.dart';
import 'package:midlandmarketing/features/dashboard/domain/usecases/get_dashboard_summary.dart';
import 'package:midlandmarketing/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:midlandmarketing/features/users/data/datasources/user_local_data_source.dart';
import 'package:midlandmarketing/features/users/data/repositories/user_repository_impl.dart';
import 'package:midlandmarketing/features/users/domain/repositories/user_repository.dart';
import 'package:midlandmarketing/features/users/domain/usecases/add_user.dart';
import 'package:midlandmarketing/features/users/domain/usecases/get_users.dart';
import 'package:midlandmarketing/features/users/presentation/bloc/users_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);

  // Data sources
  sl.registerLazySingleton(() => UserLocalDataSource(sl()));
  sl.registerLazySingleton(() => SessionLocalDataSource(sl()));
  sl.registerLazySingleton(() => AttendanceLocalDataSource(sl()));
  sl.registerLazySingleton(() => CommentLocalDataSource(sl()));

  // Repositories
  sl.registerLazySingleton<UserRepository>(() => UserRepositoryImpl(sl()));
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(userDataSource: sl(), sessionDataSource: sl()),
  );
  sl.registerLazySingleton<AttendanceRepository>(
    () => AttendanceRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<CommentRepository>(
    () => CommentRepositoryImpl(sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  sl.registerLazySingleton(() => LogoutUser(sl()));
  sl.registerLazySingleton(() => GetUsers(sl()));
  sl.registerLazySingleton(() => AddUser(sl()));
  sl.registerLazySingleton(() => GetComments(sl()));
  sl.registerLazySingleton(
    () => AddComment(commentRepository: sl(), userRepository: sl()),
  );
  sl.registerLazySingleton(() => GetTodayAttendance(sl()));
  sl.registerLazySingleton(() => CheckIn(sl()));
  sl.registerLazySingleton(() => CheckOut(sl()));
  sl.registerLazySingleton(() => GetAttendanceHistory(sl()));
  sl.registerLazySingleton(
    () => GetTeamAttendance(attendanceRepository: sl(), userRepository: sl()),
  );
  sl.registerLazySingleton(
    () => GetDashboardSummary(userRepository: sl(), attendanceRepository: sl()),
  );

  // Blocs. AuthBloc lives for the whole app, the rest are created per screen.
  sl.registerLazySingleton(
    () => AuthBloc(getCurrentUser: sl(), loginUser: sl(), logoutUser: sl()),
  );
  sl.registerFactory(() => UsersBloc(sl(), sl()));
  sl.registerFactory(
    () => CommentsBloc(getComments: sl(), addComment: sl()),
  );
  sl.registerFactory(() => AttendanceHistoryBloc(sl()));
  sl.registerFactory(() => TeamRecordsBloc(sl()));
  sl.registerFactory(() => DashboardBloc(sl()));
  sl.registerFactory(
    () => TodayAttendanceBloc(
      getTodayAttendance: sl(),
      checkIn: sl(),
      checkOut: sl(),
    ),
  );
}
