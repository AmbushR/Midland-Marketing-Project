part of 'team_records_bloc.dart';

sealed class TeamRecordsEvent extends Equatable {
  const TeamRecordsEvent();

  @override
  List<Object?> get props => [];
}

class TeamRecordsStarted extends TeamRecordsEvent {
  const TeamRecordsStarted(this.viewer);

  final User viewer;

  @override
  List<Object?> get props => [viewer];
}

class TeamSearchChanged extends TeamRecordsEvent {
  const TeamSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

/// A null date clears the date filter.
class TeamDateChanged extends TeamRecordsEvent {
  const TeamDateChanged(this.date);

  final DateTime? date;

  @override
  List<Object?> get props => [date];
}

/// A null role clears the role filter.
class TeamRoleChanged extends TeamRecordsEvent {
  const TeamRoleChanged(this.role);

  final UserRole? role;

  @override
  List<Object?> get props => [role];
}
