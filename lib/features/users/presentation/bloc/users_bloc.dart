import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:midlandmarketing/core/error/exceptions.dart';
import 'package:midlandmarketing/features/users/domain/entities/user.dart';
import 'package:midlandmarketing/features/users/domain/usecases/add_user.dart';
import 'package:midlandmarketing/features/users/domain/usecases/get_users.dart';

part 'users_event.dart';
part 'users_state.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  UsersBloc(this._getUsers, this._addUser) : super(const UsersState()) {
    on<UsersRequested>(_onRequested);
    on<UserAddRequested>(_onAddRequested);
    on<UserSaveReset>(
      (event, emit) => emit(
        state.copyWith(
          saveStatus: UserSaveStatus.idle,
          clearSaveMessage: true,
        ),
      ),
    );
  }

  final GetUsers _getUsers;
  final AddUser _addUser;

  Future<void> _onRequested(
    UsersRequested event,
    Emitter<UsersState> emit,
  ) async {
    emit(const UsersState());
    try {
      final users = await _getUsers();
      emit(UsersState(status: UsersStatus.loaded, users: users));
    } catch (_) {
      emit(
        const UsersState(
          status: UsersStatus.failure,
          errorMessage: 'Could not load users.',
        ),
      );
    }
  }

  Future<void> _onAddRequested(
    UserAddRequested event,
    Emitter<UsersState> emit,
  ) async {
    if (state.saveStatus == UserSaveStatus.saving) return;
    emit(
      state.copyWith(
        saveStatus: UserSaveStatus.saving,
        clearSaveMessage: true,
      ),
    );

    try {
      final created = await _addUser(
        actor: event.actor,
        name: event.name,
        email: event.email,
        password: event.password,
        role: event.role,
      );
      final users = await _getUsers();
      emit(
        state.copyWith(
          status: UsersStatus.loaded,
          users: users,
          saveStatus: UserSaveStatus.success,
          saveMessage: '${created.name} was added as ${created.role.label}.',
        ),
      );
    } on AppException catch (e) {
      emit(
        state.copyWith(
          saveStatus: UserSaveStatus.failure,
          saveMessage: e.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          saveStatus: UserSaveStatus.failure,
          saveMessage: 'Could not add the user. Please try again.',
        ),
      );
    }
  }
}
