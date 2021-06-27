import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:citycab/repositories/user_repository.dart';
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
      final uid = await AuthService.instance.verifyAndLogin(event.verificationId, event.smsCode, event.phone);
      final user = await UserRepository.instance.getUser(uid);
      yield LoggedInState(user!.uid, user.firstname, user.lastname, user.email);
    } else if (event is CodeSentEvent) {
      yield CodeSentState(event.verificationId, event.token);
    } else if (event is SignUpEvent) {
      yield* _setUpAccount(event);
    } else if (event is LoginCurrentUserEvent) {
      await UserRepository.instance.signInCurrentUser();
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

  Stream<AuthState> _setUpAccount(SignUpEvent event) async* {
    yield LoadingAuthState();
    final user =
        await UserRepository.instance.setUpAccount(event.uid!, event.email!, event.firstname!, event.lastname!);
    yield LoggedInState(user!.uid, user.firstname, user.lastname, user.email);
  }
}
