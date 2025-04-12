import 'package:equatable/equatable.dart';

enum Status {
  initial,
  loading,
  success,
  failure,
}

class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure({
    required this.message,
    this.statusCode,
  });

  @override
  List<Object?> get props => [message, statusCode];
}
