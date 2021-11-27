import 'package:citycab/models/address.dart';
import 'package:citycab/models/rate.dart';
import 'package:citycab/models/ride_option.dart';
import 'package:flutter/material.dart';

enum RideStatus { initial, accepted, moving, arrived, completed, cancel }

@immutable
class Ride {
  final String id;
  final Address startAddress;
  final Address endAddress;
  final String driverUID;
  final String ownerUID;
  final List<String> passengers;
  final Rate rate;
  final RideOption rideOption;
  final RideStatus status;
  final DateTime createdAt;

  const Ride(
      {required this.id,
      required this.startAddress,
      required this.endAddress,
      required this.driverUID,
      required this.ownerUID,
      required this.passengers,
      required this.rate,
      required this.rideOption,
      required this.status,
      required this.createdAt});

  factory Ride.fromMap(Map<String, dynamic> data) {
    return Ride(
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'].millisecondsSinceEpoch),
      driverUID: data['driver_uid'] ?? '',
      endAddress: Address.fromMap(data['end_address'] ?? {}),
      id: data['id'] ?? '',
      ownerUID: data['owner_uid'] ?? '',
      passengers: List<String>.from(data['passengers'] ?? []),
      rate: Rate.fromMap(data['rate']),
      rideOption: RideOption.fromMap(data['ride_option'] ?? {}),
      startAddress: Address.fromMap(data['start_address'] ?? {}),
      status: RideStatus.values[data['status'] ?? 0],
    );
  }
}
