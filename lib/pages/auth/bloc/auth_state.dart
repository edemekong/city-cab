part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitialState extends AuthState {}

class LoadingAuthState extends AuthState {}

class LoggedInState extends AuthState {
  final String? uid;
  final String? firstname;
  final String? lastname;
  final String? email;

  LoggedInState(this.uid, this.firstname, this.lastname, this.email);
}

class AutoLoggedInState extends LoggedInState {
  AutoLoggedInState(String uid, String firstname, String lastname, String email)
      : super(uid, firstname, lastname, email);
}

class StateErrorSignUp extends AuthState {
  final String message;
  const StateErrorSignUp(this.message);
}

class CodeSentState extends AuthState {
  final String verificationId;
  final int? token;

  const CodeSentState(this.verificationId, this.token);
}
