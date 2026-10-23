part of 'dashboard_bloc.dart';

sealed class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class DashboardRequested extends DashboardEvent {
  const DashboardRequested(this.viewer);

  final User viewer;

  @override
  List<Object?> get props => [viewer];
}
