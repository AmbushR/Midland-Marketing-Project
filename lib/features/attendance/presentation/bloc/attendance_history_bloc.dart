import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/attendance_record.dart';
import '../../domain/usecases/get_attendance_history.dart';

part 'attendance_history_event.dart';
part 'attendance_history_state.dart';

class AttendanceHistoryBloc
    extends Bloc<AttendanceHistoryEvent, AttendanceHistoryState> {
  AttendanceHistoryBloc(this._getAttendanceHistory)
    : super(const AttendanceHistoryState()) {
    on<AttendanceHistoryRequested>(_onRequested);
  }

  final GetAttendanceHistory _getAttendanceHistory;

  Future<void> _onRequested(
    AttendanceHistoryRequested event,
    Emitter<AttendanceHistoryState> emit,
  ) async {
    emit(const AttendanceHistoryState());
    try {
      final records = await _getAttendanceHistory(event.userId);
      emit(
        AttendanceHistoryState(status: HistoryStatus.loaded, records: records),
      );
    } catch (_) {
      emit(
        const AttendanceHistoryState(
          status: HistoryStatus.failure,
          errorMessage: 'Could not load your attendance history.',
        ),
      );
    }
  }
}
