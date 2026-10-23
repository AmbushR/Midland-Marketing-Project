part of 'attendance_history_bloc.dart';

enum HistoryStatus { loading, loaded, failure }

class AttendanceHistoryState extends Equatable {
  const AttendanceHistoryState({
    this.status = HistoryStatus.loading,
    this.records = const [],
    this.errorMessage,
  });

  final HistoryStatus status;
  final List<AttendanceRecord> records;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, records, errorMessage];
}
