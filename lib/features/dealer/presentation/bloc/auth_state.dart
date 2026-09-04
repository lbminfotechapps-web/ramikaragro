enum LoginStatus { initial, loading, success, failure }

class AuthState {
  final LoginStatus loginStatus;
  final String? errorMessage;

  const AuthState({this.loginStatus = LoginStatus.initial, this.errorMessage});

  AuthState copyWith({LoginStatus? loginStatus, String? errorMessage}) {
    return AuthState(
      loginStatus: loginStatus ?? this.loginStatus,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
