import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthRegisterSubmitted extends AuthEvent {
  final String fullName;
  final String phone;
  final String password;

  const AuthRegisterSubmitted({
    required this.fullName,
    required this.phone,
    required this.password,
  });

  @override
  List<Object?> get props => [fullName, phone, password];
}

class AuthLoginSubmitted extends AuthEvent {
  final String phone;
  final String password;

  const AuthLoginSubmitted({
    required this.phone,
    required this.password,
  });

  @override
  List<Object?> get props => [phone, password];
}

class AuthLogoutRequested extends AuthEvent {}