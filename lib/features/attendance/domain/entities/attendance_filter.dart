import 'package:equatable/equatable.dart';

import '../../../users/domain/entities/user.dart';

class AttendanceFilter extends Equatable {
  const AttendanceFilter({this.query = '', this.date, this.role});

  final String query;
  final DateTime? date;
  final UserRole? role;

  AttendanceFilter copyWith({
    String? query,
    DateTime? date,
    bool clearDate = false,
    UserRole? role,
    bool clearRole = false,
  }) {
    return AttendanceFilter(
      query: query ?? this.query,
      date: clearDate ? null : (date ?? this.date),
      role: clearRole ? null : (role ?? this.role),
    );
  }

  @override
  List<Object?> get props => [query, date, role];
}
