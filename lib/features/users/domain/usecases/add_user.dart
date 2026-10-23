import 'package:midlandmarketing/core/error/exceptions.dart';
import 'package:midlandmarketing/features/users/domain/entities/user.dart';
import 'package:midlandmarketing/features/users/domain/repositories/user_repository.dart';

/// Lets an admin create a Senior Staff or Staff account.
class AddUser {
  const AddUser(this._repository);

  final UserRepository _repository;

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static const minPasswordLength = 6;

  Future<User> call({
    required User actor,
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    if (!actor.role.canManageUsers) {
      throw const UserException('Only an admin can add users.');
    }
    if (!actor.role.creatableRoles.contains(role)) {
      throw const UserException('Choose Senior Staff or Staff for the account.');
    }

    final cleanName = name.trim();
    final cleanEmail = email.trim().toLowerCase();

    if (cleanName.length < 2) {
      throw const UserException('Please enter the full name.');
    }
    if (!_emailPattern.hasMatch(cleanEmail)) {
      throw const UserException('Enter a valid email address.');
    }
    if (password.length < minPasswordLength) {
      throw const UserException(
        'Password must be at least $minPasswordLength characters.',
      );
    }

    final existing = await _repository.getUsers();
    final taken = existing.any((user) => user.email.toLowerCase() == cleanEmail);
    if (taken) {
      throw const UserException('A user with this email already exists.');
    }

    return _repository.addUser(
      name: cleanName,
      email: cleanEmail,
      password: password,
      role: role,
    );
  }
}
