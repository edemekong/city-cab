import 'package:google_maps_flutter/google_maps_flutter.dart';

enum Roles { passenger, driver, admin }

class User {
  final String uid;
  final String firstname;
  final String lastname;
  final String email;
  final DateTime createdAt;
  final bool isVerified;
  final String licensePlate;
  final String phone;
  final String vehicleType;
  final String vehicleColor;
  final String vehicleManufacturer;
  final Roles role;
  final bool isActive;
  final LatLng? latlng;

  bool get isPassengerRole => role == Roles.passenger;
  bool get isDriverRole => role == Roles.driver;
  bool get isAdminRole => role == Roles.admin;

  String get getFullName => firstname + " " + lastname;

  const User({
    required this.isActive,
    required this.uid,
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.createdAt,
    required this.isVerified,
    required this.licensePlate,
    required this.phone,
    required this.vehicleType,
    required this.vehicleColor,
    required this.vehicleManufacturer,
    required this.role,
    this.latlng,
  });

  factory User.fromMap(Map<String, dynamic> data) {
    return User(
      uid: data['uid'] ?? '',
      isActive: data['is_active'] ?? false,
      firstname: data['firstname'] ?? '',
      lastname: data['lastname'] ?? '',
      email: data['email'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'].millisecondsSinceEpoch),
      isVerified: data['is_verified'] ?? false,
      licensePlate: data['license_plate'] ?? '',
      phone: data['phone'] ?? '',
      vehicleType: data['vehicle_type'] ?? '',
      vehicleColor: data['vehicle_color'] ?? '',
      vehicleManufacturer: data['vehicle_manufacturer'] ?? '',
      role: Roles.values[data['role'] ?? 0],
      latlng: data['latlng'] == null ? LatLng(0, 0) : LatLng(data['latlng']['lat'], data['latlng']['lng']),
    );
  }
}
