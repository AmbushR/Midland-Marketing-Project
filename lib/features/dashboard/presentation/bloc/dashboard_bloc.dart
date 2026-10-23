import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/exceptions.dart';
import '../../../users/domain/entities/user.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/usecases/get_dashboard_summary.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc(this._getDashboardSummary) : super(const DashboardState()) {
    on<DashboardRequested>(_onRequested);
  }

  final GetDashboardSummary _getDashboardSummary;

  Future<void> _onRequested(
    DashboardRequested event,
    Emitter<DashboardState> emit,
  ) async {
    // Keep showing the old numbers while refreshing, only reset after an error.
    if (state.status == DashboardStatus.failure) {
      emit(const DashboardState());
    }

    try {
      final summary = await _getDashboardSummary(event.viewer);
      emit(DashboardState(status: DashboardStatus.loaded, summary: summary));
    } on AppException catch (e) {
      emit(
        DashboardState(
          status: DashboardStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (_) {
      emit(
        const DashboardState(
          status: DashboardStatus.failure,
          errorMessage: 'Could not load the dashboard.',
        ),
      );
    }
  }
}
