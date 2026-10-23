part of 'team_records_bloc.dart';

enum TeamRecordsStatus { loading, loaded, failure }

class TeamRecordsState extends Equatable {
  const TeamRecordsState({
    this.status = TeamRecordsStatus.loading,
    this.entries = const [],
    this.filter = const AttendanceFilter(),
    this.errorMessage,
  });

  final TeamRecordsStatus status;
  final List<EmployeeAttendance> entries;
  final AttendanceFilter filter;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, entries, filter, errorMessage];
}
