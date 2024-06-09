// ignore_for_file: unused_local_variable

import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthState {
  var seconds;

  var isResend;
}

class TimerState extends AuthState {
  final int seconds;
  final bool isResend;

  TimerState(this.seconds, this.isResend);
}

//All these states are for authentication purposes
class AuthInitialState extends AuthState {}

class AuthLoadingState extends AuthState {}

class AuthUserPhoneNewState extends AuthState {}

class AuthUserPhoneLoggedInState extends AuthState {
  final String userId;
  AuthUserPhoneLoggedInState({
    required this.userId,
  });
}

class AuthUserEmailNewState extends AuthState {}

class AuthUserEmailLoggedInState extends AuthState {
  final String userId;
  AuthUserEmailLoggedInState({
    required this.userId,
  });
}

class AuthCodeSentState extends AuthState {}

class AuthLoggedOutState extends AuthState {}

class AuthEmailErrorState extends AuthState {
  final String error;

  AuthEmailErrorState(this.error);
}

class AuthSendErrorState extends AuthState {
  final String error;

  AuthSendErrorState(this.error);
}

class AuthVerifyErrorState extends AuthState {
  final String error;

  AuthVerifyErrorState(this.error);
}

//And below states are for checking if the user exist or not
class AuthCheckExists extends AuthState {
  final String userId;
  AuthCheckExists({
    required this.userId,
  });
}

class AuthCheckNewState extends AuthState {}
