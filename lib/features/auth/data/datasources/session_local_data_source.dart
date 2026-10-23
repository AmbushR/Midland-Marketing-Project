import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../users/data/models/user_model.dart';

class SessionLocalDataSource {
  SessionLocalDataSource(this._prefs);

  final SharedPreferences _prefs;

  static const _sessionKey = 'current_user';

  Future<void> saveUser(UserModel user) async {
    await _prefs.setString(_sessionKey, jsonEncode(user.toJson()));
  }

  UserModel? getUser() {
    final raw = _prefs.getString(_sessionKey);
    if (raw == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      // A broken session is treated the same as no session.
      return null;
    }
  }

  Future<void> clear() async {
    await _prefs.remove(_sessionKey);
  }
}
