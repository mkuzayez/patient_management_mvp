part of 'authentication_bloc.dart';

// sealed class AuthenticationState {}
//
// final class AuthenticationInitial extends AuthenticationState {}



class AuthenticationState extends Equatable {
  final Status status;
  final String? message;

  const AuthenticationState({
    this.status = Status.initial,
    this.message
  });

  @override
  List<Object?> get props => [
    status,
  ];

  // Custom copyWith method to create a new instance with updated values
  AuthenticationState copyWith({
    Status? status,
    String? message,
  }) {
    return AuthenticationState(
      status: status ?? this.status,
      message: message
    );
  }
}
