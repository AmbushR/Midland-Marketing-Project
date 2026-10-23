import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/exceptions.dart';
import '../../../users/domain/entities/user.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/logout_user.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required GetCurrentUser getCurrentUser,
    required LoginUser loginUser,
    required LogoutUser logoutUser,
  }) : _getCurrentUser = getCurrentUser,
       _loginUser = loginUser,
       _logoutUser = logoutUser,
       super(const AuthState.unknown()) {
    on<AuthStarted>(_onStarted);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  final GetCurrentUser _getCurrentUser;
  final LoginUser _loginUser;
  final LogoutUser _logoutUser;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    try {
      final user = await _getCurrentUser();
      emit(
        user == null
            ? const AuthState.unauthenticated()
            : AuthState.authenticated(user),
      );
    } catch (_) {
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.authenticating());
    try {
      final user = await _loginUser(
        email: event.email,
        password: event.password,
      );
      emit(AuthState.authenticated(user));
    } on AppException catch (e) {
      emit(AuthState.unauthenticated(errorMessage: e.message));
    } catch (_) {
      emit(
        const AuthState.unauthenticated(
          errorMessage: 'Something went wrong. Please try again.',
        ),
      );
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _logoutUser();
    emit(const AuthState.unauthenticated());
  }
}
