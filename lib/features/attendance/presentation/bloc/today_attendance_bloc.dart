import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/attendance_record.dart';
import '../../domain/usecases/check_in.dart';
import '../../domain/usecases/check_out.dart';
import '../../domain/usecases/get_today_attendance.dart';

part 'today_attendance_event.dart';
part 'today_attendance_state.dart';

/// Handles the signed-in user's own attendance for the current day.
class TodayAttendanceBloc
    extends Bloc<TodayAttendanceEvent, TodayAttendanceState> {
  TodayAttendanceBloc({
    required GetTodayAttendance getTodayAttendance,
    required CheckIn checkIn,
    required CheckOut checkOut,
  }) : _getTodayAttendance = getTodayAttendance,
       _checkIn = checkIn,
       _checkOut = checkOut,
       super(const TodayAttendanceState()) {
    on<TodayAttendanceRequested>(_onRequested);
    on<CheckInPressed>((event, emit) => _submit(emit, _checkIn.call));
    on<CheckOutPressed>((event, emit) => _submit(emit, _checkOut.call));
  }

  final GetTodayAttendance _getTodayAttendance;
  final CheckIn _checkIn;
  final CheckOut _checkOut;

  String? _userId;

  Future<void> _onRequested(
    TodayAttendanceRequested event,
    Emitter<TodayAttendanceState> emit,
  ) async {
    _userId = event.userId;
    emit(const TodayAttendanceState());
    try {
      final record = await _getTodayAttendance(event.userId);
      emit(
        TodayAttendanceState(
          status: TodayAttendanceStatus.loaded,
          record: record,
        ),
      );
    } catch (_) {
      emit(
        const TodayAttendanceState(
          status: TodayAttendanceStatus.failure,
          errorMessage: "Could not load today's attendance.",
        ),
      );
    }
  }

  Future<void> _submit(
    Emitter<TodayAttendanceState> emit,
    Future<AttendanceRecord> Function(String userId) action,
  ) async {
    final userId = _userId;
    if (userId == null || state.status == TodayAttendanceStatus.submitting) {
      return;
    }

    final previous = state.record;
    emit(
      TodayAttendanceState(
        status: TodayAttendanceStatus.submitting,
        record: previous,
      ),
    );

    try {
      final record = await action(userId);
      emit(
        TodayAttendanceState(
          status: TodayAttendanceStatus.loaded,
          record: record,
        ),
      );
    } on AppException catch (e) {
      emit(
        TodayAttendanceState(
          status: TodayAttendanceStatus.loaded,
          record: previous,
          errorMessage: e.message,
        ),
      );
    } catch (_) {
      emit(
        TodayAttendanceState(
          status: TodayAttendanceStatus.loaded,
          record: previous,
          errorMessage: 'Something went wrong. Please try again.',
        ),
      );
    }
  }
}
