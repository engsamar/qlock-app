import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:q_lock/core/constants/app_keys.dart';
import 'package:q_lock/core/network/api_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/models/user_model.dart';
import '../../data/repos/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  final SharedPreferences _sharedPreferences;

  AuthCubit({
    required AuthRepository authRepository,
    required SharedPreferences sharedPreferences,
  }) : _authRepository = authRepository,
       _sharedPreferences = sharedPreferences,
       super(const AuthInitialState());

  UserModel? get currentUser {
    final currentState = state;
    if (currentState is AuthenticatedState) {
      return currentState.user;
    }
    return null;
  }

  void syncUserData(UserModel updatedUser) {
    final currentState = state;
    if (currentState is AuthenticatedState) {
      emit(AuthenticatedState(user: updatedUser));
    }
  }

  Future<void> checkAuthStatus() async {
    emit(const AuthLoadingState());
    final userText = _sharedPreferences.getString(AppKeys.userModel);
    if (userText == null) {
      emit(const UnauthenticatedState());
    } else {
      final userModel = UserModel.fromJson(json.decode(userText));
      emit(AuthenticatedState(user: userModel));
    }
  }

  Future<void> verifyPhoneNumber(String phoneNumber) async {
    emit(const AuthLoadingState());

    final result = await _authRepository.verifyPhoneNumber(
      phoneNumber: phoneNumber,
    );

    result.fold(
      (failure) {
        emit(AuthErrorState(message: failure.message));
      },
      (success) {
        if (success.data == null) {
          emit(
            const AuthErrorState(
              message: 'Something went wrong, please try again later',
            ),
          );
        } else {
          emit(OtpSentState(code: success.data!));
        }
      },
    );
  }

  Future<void> verifyOtpCode({
    required String phoneNumber,
    required String otp,
  }) async {
    emit(const OtpVerificationInProgressState());

    final result = await _authRepository.verifyOtpCode(
      phoneNumber: phoneNumber,
      otp: otp,
    );

    result.fold(
      (failure) {
        emit(AuthErrorState(message: failure.message));
      },
      (success) async {
        await _sharedPreferences.setString(
          ApiKeys.bearerToken,
          success.data.token,
        );
        await _sharedPreferences.setString(
          AppKeys.userModel,
          json.encode(success.data.user.toJson()),
        );
        emit(AuthenticatedState(user: success.data.user));
      },
    );
  }

  Future<void> logout() async {
    emit(const AuthLoadingState());

    await _sharedPreferences.clear();
    emit(const UnauthenticatedState());
  }
}
