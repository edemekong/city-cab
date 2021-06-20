part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class SignUpEvent extends AuthEvent {
  final String uid;
  final String firstname;
  final String lastname;
  final String email;
  final String phone;

  const SignUpEvent(this.firstname, this.lastname, this.email, this.phone, this.uid);
}

class PhoneNumberVerificationEvent extends AuthEvent {
  final String phone;
  const PhoneNumberVerificationEvent(this.phone);
}

class PhoneAuthCodeVerifiedEvent extends AuthEvent {
  final String phone;
  final String smsCode;

  final String verificationId;
  const PhoneAuthCodeVerifiedEvent(this.smsCode, this.verificationId, this.phone);
}

class CompletedAuthEvent extends AuthEvent {
  final AuthCredential credential;
  const CompletedAuthEvent(this.credential);
}

class ErrorOccuredEvent extends AuthEvent {
  final String error;
  const ErrorOccuredEvent(this.error);
}

class CodeSentEvent extends AuthEvent {
  final int token;
  final String verificationId;
  const CodeSentEvent(this.verificationId, this.token);
}
