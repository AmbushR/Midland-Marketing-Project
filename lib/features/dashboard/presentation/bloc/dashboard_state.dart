part of 'dashboard_bloc.dart';

enum DashboardStatus { loading, loaded, failure }

class DashboardState extends Equatable {
  const DashboardState({
    this.status = DashboardStatus.loading,
    this.summary,
    this.errorMessage,
  });

  final DashboardStatus status;
  final DashboardSummary? summary;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, summary, errorMessage];
}
