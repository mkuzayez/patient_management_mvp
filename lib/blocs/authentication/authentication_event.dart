part of 'authentication_bloc.dart';



abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object?> get props => [];
}

class LoginEvent extends AuthenticationEvent {
  final String username;
  final String password;

  const LoginEvent({required this.username, required this.password});
}
