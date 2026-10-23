import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/comment_model.dart';

class CommentLocalDataSource {
  CommentLocalDataSource(this._prefs);

  final SharedPreferences _prefs;

  static const _commentsKey = 'attendance_comments';

  Future<List<CommentModel>> getComments() async {
    final raw = _prefs.getString(_commentsKey);
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveComments(List<CommentModel> comments) async {
    final encoded = jsonEncode(comments.map((c) => c.toJson()).toList());
    await _prefs.setString(_commentsKey, encoded);
  }
}
