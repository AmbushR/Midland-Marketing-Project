part of 'today_attendance_bloc.dart';

sealed class TodayAttendanceEvent extends Equatable {
  const TodayAttendanceEvent();

  @override
  List<Object?> get props => [];
}

class TodayAttendanceRequested extends TodayAttendanceEvent {
  const TodayAttendanceRequested(this.userId);

  final String userId;

  @override
  List<Object?> get props => [userId];
}

class CheckInPressed extends TodayAttendanceEvent {
  const CheckInPressed();
}

class CheckOutPressed extends TodayAttendanceEvent {
  const CheckOutPressed();
}
