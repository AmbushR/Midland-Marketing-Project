import 'dart:convert';

import 'package:midlandmarketing/features/users/data/datasources/dummy_users.dart';
import 'package:midlandmarketing/features/users/data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Keeps the user list on the device. The first launch starts from the demo
/// accounts, and accounts added by the admin are saved next to them.
class UserLocalDataSource {
  UserLocalDataSource(this._prefs);

  final SharedPreferences _prefs;

  static const _usersKey = 'app_users';

  Future<List<UserModel>> getUsers() async {
    final raw = _prefs.getString(_usersKey);

    if (raw != null) {
      try {
        final decoded = jsonDecode(raw) as List<dynamic>;
        return decoded
            .map((e) => UserModel.fromStorageJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        // Unreadable data: start again from the demo accounts.
      }
    }

    final seeded = List<UserModel>.of(dummyUsers);
    await _saveUsers(seeded);
    return seeded;
  }

  Future<void> addUser(UserModel user) async {
    final users = await getUsers();
    users.add(user);
    await _saveUsers(users);
  }

  Future<void> _saveUsers(List<UserModel> users) async {
    final encoded = jsonEncode(users.map((u) => u.toStorageJson()).toList());
    await _prefs.setString(_usersKey, encoded);
  }
}
