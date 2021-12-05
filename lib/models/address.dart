import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Address {
  final String id;
  final String? title;
  final String street;
  final String city;
  final String state;
  final String country;
  final String postcode;
  final LatLng latLng;
  final List<PointLatLng> polylines;

  const Address(
      {required this.id,
      this.title,
      required this.polylines,
      required this.latLng,
      required this.street,
      required this.city,
      required this.state,
      required this.country,
      required this.postcode});

  factory Address.fromMap(Map<String, dynamic> data) {
    return Address(
      id: data['id'],
      city: data['city'] ?? '',
      country: data['country'] ?? '',
      latLng: LatLng(data['latlng']['lat'], data['latlng']['lng']),
      polylines: [],
      postcode: data['post_code'] ?? '',
      state: data['state'] ?? '',
      street: data['street'] ?? '',
    );
  }
}
