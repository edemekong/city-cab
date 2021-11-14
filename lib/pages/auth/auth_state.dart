import 'dart:async';

import 'package:citycab/repositories/user_repository.dart';
import 'package:citycab/services/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum PhoneAuthState { initial, success, loading, codeSent, error }

class AuthState extends ChangeNotifier {
  final authService = AuthService.instance;
  final userRepo = UserRepository.instance;

  PhoneAuthState _phoneAuthState = PhoneAuthState.initial;

  TextEditingController phoneController = TextEditingController();
  TextEditingController otpController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  PageController? controller;
  int pageIndex = 0;
  String uid = '';

  String verificationId = '';
  int timeOut = 30;

  AuthState(int page, String uid) {
    this.uid = uid;
    controller = PageController(initialPage: page);
    pageIndex = page;
    notifyListeners();
    siginCurrentUser();
  }

  PhoneAuthState get phoneAuthState => _phoneAuthState;

  set phoneAuthStateChange(PhoneAuthState phoneAuthState) {
    _phoneAuthState = phoneAuthState;
    notifyListeners();
  }

  void animateToNextPage(int page) {
    controller!.animateToPage(page, duration: Duration(milliseconds: 400), curve: Curves.easeIn);
    pageIndex = page;
    notifyListeners();
  }

  void onPageChanged(int value) {
    pageIndex = value;
    notifyListeners();
  }

  Future<void> signUp(final String? uid, final String firstname, final String lastname, final String email) async {
    phoneAuthStateChange = PhoneAuthState.loading;
    try {
      await userRepo?.setUpAccount(uid, email, firstname, lastname);
      phoneAuthStateChange = PhoneAuthState.success;
    } on FirebaseException catch (e) {
      print(e.message);
      phoneAuthStateChange = PhoneAuthState.error;
    }
  }

  Future<void> phoneNumberVerification(String phone) async {
    await AuthService.instance!.verifyPhoneSendOtp(phone, completed: (credential) async {
      if (credential.smsCode != null && credential.verificationId != null) {
        verificationId = credential.verificationId ?? '';
        notifyListeners();
        await verifyAndLogin(credential.verificationId!, credential.smsCode!, phoneController.text);
      }
    }, failed: (error) {
      phoneAuthStateChange = PhoneAuthState.error;
    }, codeSent: (String id, int? token) {
      verificationId = id;
      notifyListeners();

      phoneAuthStateChange = PhoneAuthState.codeSent;
      codeSentEvent();
      print('code sent $id');
    }, codeAutoRetrievalTimeout: (id) {
      verificationId = id;
      notifyListeners();

      phoneAuthStateChange = PhoneAuthState.codeSent;
      animateToNextPage(1);
      print('timeout $id');
    });
    animateToNextPage(1);
    notifyListeners();
  }

  Future<void> verifyAndLogin(String verificationId, String smsCode, String phone) async {
    phoneAuthStateChange = PhoneAuthState.loading;

    final uid = await authService?.verifyAndLogin(verificationId, smsCode, phone);
    await userRepo?.getUser(uid);
    this.uid = uid ?? '';
    animateToNextPage(2);
    notifyListeners();
    phoneAuthStateChange = PhoneAuthState.success;
    print('completed');
  }

  Future<void> siginCurrentUser() async {
    await userRepo?.signInCurrentUser();
  }

  Future<void> codeSentEvent() async {
    animateToNextPage(1);
    _startCountDown();
  }

  void _startCountDown() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (timer.tick > 30) {
        timer.cancel();
      } else {
        --timeOut;
      }
      notifyListeners();
    });
  }
}
