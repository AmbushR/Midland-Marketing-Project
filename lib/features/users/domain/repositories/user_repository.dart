import 'package:midlandmarketing/features/users/domain/entities/user.dart';

abstract class UserRepository {
  Future<List<User>> getUsers();

  Future<User> addUser({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  });
}
