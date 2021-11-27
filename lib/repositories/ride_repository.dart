import 'package:citycab/models/ride.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RideRepository {
  RideRepository._();
  static RideRepository? _instance;

  static RideRepository? get instance {
    if (_instance == null) {
      _instance = RideRepository._();
    }
    return _instance;
  }

  final _firestoreRideCollection = FirebaseFirestore.instance.collection('rides');

  ValueNotifier<List<Ride>> ridesNotifier = ValueNotifier<List<Ride>>([]);
  List<Ride> get rides => ridesNotifier.value;

  Future<Ride?> loadRide(String id) async {
    try {
      final ride = rides.firstWhere((Ride ride) => ride.id == id);
      return ride;
    } catch (_) {
      try {
        final doc = await _firestoreRideCollection.doc(id).get();
        final ride = Ride.fromMap(doc.data() ?? {});
        ridesNotifier.value.add(ride);
        ridesNotifier.notifyListeners();

        return ride;
      } on FirebaseException catch (e) {
        print(e.message);
        return null;
      }
    }
  }

  Future<List<Ride>> loadAllUserRides(String ownerUID) async {
    try {
      final snapshot = _firestoreRideCollection.where('owner_uid', isEqualTo: ownerUID).snapshots();
      snapshot.listen((query) {
        _addToRides(query);
      });
      return rides;
    } on FirebaseException catch (_) {
      print('something occurred');
      return rides;
    }
  }

  void _addToRides(QuerySnapshot<Map<String, dynamic>> query) {
    Future.wait(query.docs.map((doc) async {
      final ride = Ride.fromMap(doc.data());
      final index = rides.indexWhere((rideX) => rideX.id == ride.id);
      if (index != -1) {
        ridesNotifier.value.removeAt(index);
        ridesNotifier.value.insert(index, ride);
      } else {
        ridesNotifier.value.add(ride);
      }
      ridesNotifier.notifyListeners();
    }));
  }

  Future<Ride?> cancelRide(String id) async {
    try {
      await _firestoreRideCollection.doc(id).update({'status': 5});
      final ride = await loadRide(id);
      return ride;
    } on FirebaseException catch (_) {
      return null;
    }
  }

  Future<Ride?> boardRide(Ride ride) async {
    try {
      final startAddress = ride.startAddress;
      final endAddress = ride.endAddress;
      final rideOption = ride.rideOption;

      await _firestoreRideCollection.doc(ride.id).set({
        'id': ride.id,
        'createdAt': ride.createdAt,
        'driver_uid': '',
        'owner_uid': ride.ownerUID,
        'status': ride.status.index,
        'passengers': ride.passengers,
        'rate': {
          'uid': ride.ownerUID,
          'subject': '',
          'body': '',
          'stars': 0,
        },
        'ride_option': {
          'id': rideOption.id,
          'price': rideOption.price,
          'ride_type': rideOption.title,
          'time_of_arrival': rideOption.timeOfArrival,
        },
        'start_address': {
          'city': startAddress.city,
          'country': startAddress.country,
          'latlng': {
            'lat': startAddress.latLng.latitude,
            'lng': startAddress.latLng.longitude,
          },
          'post_code': startAddress.postcode,
          'state': startAddress.state,
        },
        'end_address': {
          'city': endAddress.city,
          'country': endAddress.country,
          'latlng': {
            'lat': endAddress.latLng.latitude,
            'lng': endAddress.latLng.longitude,
          },
          'post_code': endAddress.postcode,
          'state': endAddress.state,
        },
      });
      final addedRide = await loadRide(ride.id);
      return addedRide;
    } on FirebaseException catch (_) {
      print('could not board ride');
      return null;
    }
  }
}
