import 'package:midlandmarketing/core/error/exceptions.dart';
import 'package:midlandmarketing/features/auth/data/datasources/session_local_data_source.dart';
import 'package:midlandmarketing/features/auth/domain/repositories/auth_repository.dart';
import 'package:midlandmarketing/features/users/data/datasources/user_local_data_source.dart';
import 'package:midlandmarketing/features/users/domain/entities/user.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required UserLocalDataSource userDataSource,
    required SessionLocalDataSource sessionDataSource,
  }) : _userDataSource = userDataSource,
       _sessionDataSource = sessionDataSource;

  final UserLocalDataSource _userDataSource;
  final SessionLocalDataSource _sessionDataSource;

  @override
  Future<User> login({required String email, required String password}) async {
    final users = await _userDataSource.getUsers();
    final enteredEmail = email.trim().toLowerCase();

    for (final user in users) {
      if (user.email.toLowerCase() == enteredEmail &&
          user.password == password) {
        await _sessionDataSource.saveUser(user);
        return user.toEntity();
      }
    }
    throw const AuthException('Invalid email or password.');
  }

  @override
  Future<User?> getCurrentUser() async {
    final saved = _sessionDataSource.getUser();
    if (saved == null) return null;

    // Make sure the saved user still exists in the user list.
    final users = await _userDataSource.getUsers();
    for (final user in users) {
      if (user.id == saved.id) return user.toEntity();
    }
    return null;
  }

  @override
  Future<void> logout() => _sessionDataSource.clear();
}
