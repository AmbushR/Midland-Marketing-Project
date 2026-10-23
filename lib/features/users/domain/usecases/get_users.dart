import 'package:midlandmarketing/features/users/domain/entities/user.dart';
import 'package:midlandmarketing/features/users/domain/repositories/user_repository.dart';

class GetUsers {
  const GetUsers(this._repository);

  final UserRepository _repository;

  Future<List<User>> call() => _repository.getUsers();
}
