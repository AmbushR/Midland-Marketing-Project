part of 'users_bloc.dart';

enum UsersStatus { loading, loaded, failure }

enum UserSaveStatus { idle, saving, success, failure }

class UsersState extends Equatable {
  const UsersState({
    this.status = UsersStatus.loading,
    this.users = const [],
    this.errorMessage,
    this.saveStatus = UserSaveStatus.idle,
    this.saveMessage,
  });

  final UsersStatus status;
  final List<User> users;
  final String? errorMessage;
  final UserSaveStatus saveStatus;
  final String? saveMessage;

  UsersState copyWith({
    UsersStatus? status,
    List<User>? users,
    String? errorMessage,
    UserSaveStatus? saveStatus,
    String? saveMessage,
    bool clearSaveMessage = false,
  }) {
    return UsersState(
      status: status ?? this.status,
      users: users ?? this.users,
      errorMessage: errorMessage ?? this.errorMessage,
      saveStatus: saveStatus ?? this.saveStatus,
      saveMessage: clearSaveMessage ? null : (saveMessage ?? this.saveMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    users,
    errorMessage,
    saveStatus,
    saveMessage,
  ];
}
