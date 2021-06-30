import 'package:citycab/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';

class UserRepository {
  UserRepository._();
  static UserRepository _instance;

  static UserRepository get instance {
    if (_instance == null) {
      _instance = UserRepository._();
    }
    return _instance;
  }

  ValueNotifier<User> userNotifier = ValueNotifier<User>(null);

  User get currentUser {
    return userNotifier.value;
  }

  Future<User> setUpAccount(String uid, String email, String firstname, String lastname) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'email': email,
      'firstname': firstname,
      'lastname': lastname,
      'role': '0',
      'isVerified': true,
    });
    userNotifier.value = await UserRepository.instance.getUser(uid);
    return userNotifier.value;
  }

  Future<User> getUser(String uid) async {
    userNotifier.value = null;
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (!userSnapshot.exists) {
      return null;
    } else {
      Map<String, dynamic> data = userSnapshot.data() as Map<String, dynamic>;
      print(data['email']);
      userNotifier.value = User.fromJson(uid, data);
    }

    return userNotifier.value;
  }

  Future<void> signInCurrentUser() async {
    if (UserRepository.instance.currentUser == null) {
      auth.User authUser = auth.FirebaseAuth.instance.currentUser;
      if (authUser == null) {
        print("no current user");
        try {
          authUser = await auth.FirebaseAuth.instance.authStateChanges().first;
        } catch (_) {}
      }
      if (authUser == null) {
        print("no state change user");
      } else {
        await UserRepository.instance.getUser(authUser.uid);
      }
    }
  }
}
