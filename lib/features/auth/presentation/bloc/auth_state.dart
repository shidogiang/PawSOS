import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

// Trạng thái ban đầu
class AuthInitial extends AuthState {}

// gọi API
class AuthLoading extends AuthState {}

// trả  thông tin User
class AuthSuccess extends AuthState {
  final UserEntity user;

  const AuthSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

//  Lỗi 
class AuthFailure extends AuthState {
  final String message;

  const AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}
//Chưa đăng nhập đã đăng xuất
class AuthUnauthenticated extends AuthState {} 
