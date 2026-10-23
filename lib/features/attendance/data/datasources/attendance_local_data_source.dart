import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/attendance_model.dart';
import 'attendance_seed.dart';

class AttendanceLocalDataSource {
  AttendanceLocalDataSource(this._prefs);

  final SharedPreferences _prefs;

  static const _recordsKey = 'attendance_records';

  Future<List<AttendanceModel>> getRecords() async {
    final raw = _prefs.getString(_recordsKey);

    if (raw != null) {
      try {
        final decoded = jsonDecode(raw) as List<dynamic>;
        return decoded
            .map((e) => AttendanceModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        // Stored data is unreadable, so start again from the dummy records.
      }
    }

    final seeded = AttendanceSeed.generate();
    await saveRecords(seeded);
    return seeded;
  }

  Future<void> saveRecords(List<AttendanceModel> records) async {
    final encoded = jsonEncode(records.map((r) => r.toJson()).toList());
    await _prefs.setString(_recordsKey, encoded);
  }
}
