import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/exceptions.dart';
import '../../../users/domain/entities/user.dart';
import '../../domain/entities/attendance_filter.dart';
import '../../domain/entities/employee_attendance.dart';
import '../../domain/usecases/get_team_attendance.dart';

part 'team_records_event.dart';
part 'team_records_state.dart';

class TeamRecordsBloc extends Bloc<TeamRecordsEvent, TeamRecordsState> {
  TeamRecordsBloc(this._getTeamAttendance) : super(const TeamRecordsState()) {
    on<TeamRecordsStarted>(_onStarted);
    on<TeamSearchChanged>(
      (event, emit) => _load(emit, state.filter.copyWith(query: event.query)),
    );
    on<TeamDateChanged>(
      (event, emit) => _load(
        emit,
        state.filter.copyWith(date: event.date, clearDate: event.date == null),
      ),
    );
    on<TeamRoleChanged>(
      (event, emit) => _load(
        emit,
        state.filter.copyWith(role: event.role, clearRole: event.role == null),
      ),
    );
  }

  final GetTeamAttendance _getTeamAttendance;

  User? _viewer;

  Future<void> _onStarted(
    TeamRecordsStarted event,
    Emitter<TeamRecordsState> emit,
  ) async {
    _viewer = event.viewer;
    emit(const TeamRecordsState());
    await _load(emit, const AttendanceFilter());
  }

  Future<void> _load(
    Emitter<TeamRecordsState> emit,
    AttendanceFilter filter,
  ) async {
    final viewer = _viewer;
    if (viewer == null) return;

    try {
      final entries = await _getTeamAttendance(viewer: viewer, filter: filter);
      emit(
        TeamRecordsState(
          status: TeamRecordsStatus.loaded,
          entries: entries,
          filter: filter,
        ),
      );
    } on AppException catch (e) {
      emit(
        TeamRecordsState(
          status: TeamRecordsStatus.failure,
          filter: filter,
          errorMessage: e.message,
        ),
      );
    } catch (_) {
      emit(
        TeamRecordsState(
          status: TeamRecordsStatus.failure,
          filter: filter,
          errorMessage: 'Could not load attendance records.',
        ),
      );
    }
  }
}
