part of 'users_bloc.dart';

sealed class UsersEvent extends Equatable {
  const UsersEvent();

  @override
  List<Object?> get props => [];
}

class UsersRequested extends UsersEvent {
  const UsersRequested();
}

class UserAddRequested extends UsersEvent {
  const UserAddRequested({
    required this.actor,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });

  final User actor;
  final String name;
  final String email;
  final String password;
  final UserRole role;

  @override
  List<Object?> get props => [actor, name, email, password, role];
}

/// Clears the result of the last "add user" attempt.
class UserSaveReset extends UsersEvent {
  const UserSaveReset();
}
