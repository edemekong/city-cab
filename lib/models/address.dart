import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Address {
  final String? street;
  final String? city;
  final String? state;
  final String? country;
  final String? postcode;
  final LatLng? latLng;
  List<PointLatLng> polylines = [];

  Address({required this.polylines, this.latLng, this.street, this.city, this.state, this.country, this.postcode});
}
