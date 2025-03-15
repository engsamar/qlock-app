import '../../../../core/models/user_model.dart';

abstract class AuthState {
  const AuthState();
}

class AuthInitialState extends AuthState {
  const AuthInitialState();
}

class AuthLoadingState extends AuthState {
  const AuthLoadingState();
}

class AuthErrorState extends AuthState {
  final String message;

  const AuthErrorState({required this.message});
}

class OtpSentState extends AuthState {
  final int code;

  const OtpSentState({required this.code});
}

class OtpVerificationInProgressState extends AuthState {
  const OtpVerificationInProgressState();
}

class UnauthenticatedState extends AuthState {
  const UnauthenticatedState();
}

class AuthenticatedState extends AuthState {
  final UserModel user;

  const AuthenticatedState({required this.user});
}
