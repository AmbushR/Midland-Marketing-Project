import 'package:midlandmarketing/features/users/domain/entities/user.dart';

/// Data-layer user. Only the data layer (and never the UI) knows the password.
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
    this.password = '',
  });

  final String password;

  /// Session JSON: no password.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: UserRole.values.byName(json['role'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'role': role.name,
  };

  /// Storage JSON for the demo user list: includes the demo password.
  factory UserModel.fromStorageJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: UserRole.values.byName(json['role'] as String),
      password: (json['password'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toStorageJson() => {...toJson(), 'password': password};

  User toEntity() => User(id: id, name: name, email: email, role: role);
}
