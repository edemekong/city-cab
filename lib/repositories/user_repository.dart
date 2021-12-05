import 'package:citycab/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserRepository {
  UserRepository._();
  static UserRepository? _instance;

  static UserRepository get instance {
    if (_instance == null) {
      _instance = UserRepository._();
    }
    return _instance!;
  }

  Roles? get currentUserRole => currentUser?.role;

  ValueNotifier<User?> userNotifier = ValueNotifier<User?>(null);

  User? get currentUser {
    return userNotifier.value;
  }

  Future<User?> setUpAccount(User user) async {
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'email': user.email,
      'firstname': user.firstname,
      'lastname': user.lastname,
      'role': user.role.index,
      'is_verified': user.isVerified,
      'license_plate': user.licensePlate,
      'vehicle_type': user.vehicleType,
      'vehicle_color': user.vehicleColor,
      'vehicle_manufacturer': user.vehicleManufacturer,
      'is_active': user.isActive,
      'latlng': {
        'lat': user.latlng?.latitude,
        'lng': user.latlng?.longitude,
      },
    });
    userNotifier.value = await UserRepository.instance.getUser(user.uid);
    // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
    userNotifier.notifyListeners();
    return userNotifier.value;
  }

  Future<User?> getUser(String? uid) async {
    userNotifier.value = null;
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (!userSnapshot.exists) {
      return null;
    } else {
      Map<String, dynamic> data = userSnapshot.data() as Map<String, dynamic>;
      userNotifier.value = User.fromMap(data);
    }

    userNotifier.notifyListeners();
    return userNotifier.value;
  }

  Future<void> signInCurrentUser() async {
    if (UserRepository.instance.currentUser == null) {
      auth.User? authUser = auth.FirebaseAuth.instance.currentUser;
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

  Future<User?> updateDriverLocation(String? uid, LatLng position) async {
    if (uid != null) {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'latlng': {
          'lat': position.latitude,
          'lng': position.longitude,
        },
      });

      return userNotifier.value;
    }
  }

  Future<User?> updateOnlinePresense(String? uid, bool isActive) async {
    if (uid != null) {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({'is_active': isActive});
      return userNotifier.value;
    }
  }
}
