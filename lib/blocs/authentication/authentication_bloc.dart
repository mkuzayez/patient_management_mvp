import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:patient_management_app/services/auth_service.dart';

import '../base_state.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  final AuthService _authService = AuthService();

  AuthenticationBloc() : super(const AuthenticationState()) {
    on<AuthenticationEvent>((event, emit) {
      on<LoginEvent>(_onLogin);
    });
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthenticationState> emit) async {
    emit(state.copyWith(status: Status.loading));

    try {
      final result = await _authService.login(username: event.username, password: event.password);
      emit(state.copyWith(
        status: Status.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: Status.failure,
        message: e.toString(),
      ));
    }
  }
}
