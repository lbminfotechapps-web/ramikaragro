import 'package:equatable/equatable.dart';

class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginEvent({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class ChangePasswordEvent extends AuthEvent {
  final String oldPassword;
  final String newPassword;
  final String empId;

  const ChangePasswordEvent({
    required this.oldPassword,
    required this.newPassword,
    required this.empId,
  });

  @override
  List<Object> get props => [oldPassword, newPassword, empId];
}
