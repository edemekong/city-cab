import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Address {
  final String? title;
  final String street;
  final String city;
  final String state;
  final String country;
  final String postcode;
  final LatLng latLng;
  final List<PointLatLng> polylines;

  const Address(
      {this.title,
      required this.polylines,
      required this.latLng,
      required this.street,
      required this.city,
      required this.state,
      required this.country,
      required this.postcode});
}
