part of 'today_attendance_bloc.dart';

enum TodayAttendanceStatus { loading, loaded, submitting, failure }

class TodayAttendanceState extends Equatable {
  const TodayAttendanceState({
    this.status = TodayAttendanceStatus.loading,
    this.record,
    this.errorMessage,
  });

  final TodayAttendanceStatus status;
  final AttendanceRecord? record;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, record, errorMessage];
}
