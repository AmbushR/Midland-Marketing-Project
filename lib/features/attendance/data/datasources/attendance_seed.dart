import '../../../../core/utils/date_utils.dart';
import '../../../users/data/datasources/dummy_users.dart';
import '../models/attendance_model.dart';

/// Builds the dummy attendance history, relative to the current date so the
/// data always looks recent.
class AttendanceSeed {
  const AttendanceSeed._();

  static List<AttendanceModel> generate({DateTime? now}) {
    final current = now ?? DateTime.now();
    final today = AppDateUtils.dateOnly(current);
    final records = <AttendanceModel>[];

    for (var userIndex = 0; userIndex < dummyUsers.length; userIndex++) {
      final user = dummyUsers[userIndex];

      for (var daysAgo = 1; daysAgo <= 7; daysAgo++) {
        final day = DateTime(today.year, today.month, today.day - daysAgo);
        if (day.weekday == DateTime.saturday ||
            day.weekday == DateTime.sunday) {
          continue;
        }
        // Skip a few days so people are not present every single day.
        if ((userIndex + daysAgo) % 6 == 0) continue;

        final lateBy = (userIndex * 7 + daysAgo * 3) % 25;
        final forgotCheckOut = (userIndex + daysAgo) % 9 == 4;

        records.add(
          AttendanceModel(
            id: '${user.id}_${AppDateUtils.dayKey(day)}',
            userId: user.id,
            date: day,
            checkInTime: DateTime(day.year, day.month, day.day, 9, lateBy),
            checkOutTime: forgotCheckOut
                ? null
                : DateTime(day.year, day.month, day.day, 17, (lateBy * 2) % 40),
          ),
        );
      }
    }

    // A few people already at work today, so the dashboards have data on the
    // first launch. Only added once the morning is over to avoid future times.
    if (current.hour >= 10) {
      const checkedInToday = {'u3': (8, 48), 'u5': (9, 2), 'u6': (9, 15)};
      for (final entry in checkedInToday.entries) {
        final (hour, minute) = entry.value;
        records.add(
          AttendanceModel(
            id: '${entry.key}_${AppDateUtils.dayKey(today)}',
            userId: entry.key,
            date: today,
            checkInTime: DateTime(
              today.year,
              today.month,
              today.day,
              hour,
              minute,
            ),
          ),
        );
      }
    }

    return records;
  }
}
