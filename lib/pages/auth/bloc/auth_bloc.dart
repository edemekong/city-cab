import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:citycab/services/auth.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitialState());

  @override
  Stream<AuthState> mapEventToState(AuthEvent event) async* {
    if (event is PhoneNumberVerificationEvent) {
      yield* _phoneAuthVerificationToState(event);
    } else if (event is PhoneAuthCodeVerifiedEvent) {
      final uid = await AuthService.instance.verifyAndLogin(event.verificationId, event.smsCode);
      yield LoggedInState(uid);
    } else if (event is CodeSentEvent) {
      yield CodeSentState(event.verificationId, event.token);
    }
  }

  Stream<AuthState> _phoneAuthVerificationToState(PhoneNumberVerificationEvent event) async* {
    yield LoadingAuthState();
    await AuthService.instance.verifyPhoneSendOtp(event.phone, completed: (credential) {
      print('completed');
      add(CompletedAuthEvent(credential));
    }, failed: (error) {
      print(error);
      add(ErrorOccuredEvent(error.toString()));
    }, codeSent: (String id, int? token) {
      print('code sent $id');
      add(CodeSentEvent(id, token!));
    }, codeAutoRetrievalTimeout: (id) {
      print('timeout $id');
      add(CodeSentEvent(id, 0));
    });
  }
}
