import 'package:intl/intl.dart';

class AppDateUtils {
  const AppDateUtils._();

  static DateTime dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Used to build a stable id such as `u4_2026-10-23`.
  static String dayKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  static String formatDate(DateTime date) =>
      DateFormat('EEE, d MMM yyyy').format(date);

  static String formatTime(DateTime? time) =>
      time == null ? '--:--' : DateFormat('hh:mm a').format(time);

  static String dayNumber(DateTime date) => DateFormat('d').format(date);

  static String monthShort(DateTime date) => DateFormat('MMM').format(date);

  static String weekdayFull(DateTime date) => DateFormat('EEEE').format(date);

  static String longDate(DateTime date) =>
      DateFormat('d MMMM yyyy').format(date);

  /// "Today, 09:15 AM", "Yesterday, 05:02 PM" or "12 Oct, 10:30 AM".
  static String formatRelative(DateTime time, {DateTime? now}) {
    final current = now ?? DateTime.now();
    final clock = DateFormat('hh:mm a').format(time);
    if (isSameDay(time, current)) return 'Today, $clock';
    final yesterday = current.subtract(const Duration(days: 1));
    if (isSameDay(time, yesterday)) return 'Yesterday, $clock';
    return '${DateFormat('d MMM').format(time)}, $clock';
  }
}
