import 'package:midlandmarketing/features/users/data/datasources/user_local_data_source.dart';
import 'package:midlandmarketing/features/users/data/models/user_model.dart';
import 'package:midlandmarketing/features/users/domain/entities/user.dart';
import 'package:midlandmarketing/features/users/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this._dataSource);

  final UserLocalDataSource _dataSource;

  @override
  Future<List<User>> getUsers() async {
    final models = await _dataSource.getUsers();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<User> addUser({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final model = UserModel(
      id: 'u${DateTime.now().microsecondsSinceEpoch}',
      name: name,
      email: email,
      role: role,
      password: password,
    );
    await _dataSource.addUser(model);
    return model.toEntity();
  }
}
