part of 'attendance_history_bloc.dart';

sealed class AttendanceHistoryEvent extends Equatable {
  const AttendanceHistoryEvent();

  @override
  List<Object?> get props => [];
}

class AttendanceHistoryRequested extends AttendanceHistoryEvent {
  const AttendanceHistoryRequested(this.userId);

  final String userId;

  @override
  List<Object?> get props => [userId];
}
