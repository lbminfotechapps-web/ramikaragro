import 'dart:async';

import 'package:demo/features/auth/domain/usecases/login_usecase.dart';
import 'package:demo/features/auth/presentation/bloc/auth_event.dart';
import 'package:demo/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUsecase _loginUsecase;

  AuthBloc(this._loginUsecase) : super(const AuthState()) {
    on<LoginEvent>(_onLogin);
  }

  FutureOr<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(loginStatus: LoginStatus.loading, errorMessage: null));

    try {
      final response = await _loginUsecase.loginUser(
        event.email,
        event.password,
        
      );
      print('Response: ${response}');
      if (response.status == 'success' || response.userId != null) {
        emit(state.copyWith(loginStatus: LoginStatus.success));
      } else {
        emit(
          state.copyWith(
            loginStatus: LoginStatus.failure,
            errorMessage: 'Login failed',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          loginStatus: LoginStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }


  
}
