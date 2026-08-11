import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

// Đăng ký
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

//  Đăng nhập
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

// Đăng xuất
class AuthLogoutRequested extends AuthEvent {}