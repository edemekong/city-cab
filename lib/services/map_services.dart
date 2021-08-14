import 'package:citycab/constant/google_map_key.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'code_generator.dart';

class MapService {
  MapService._();

  final String baseUrl = "https://maps.googleapis.com/maps/api/directions/json";

  static MapService? _instance;

  static MapService? get instance {
    if (_instance == null) {
      _instance = MapService._();
    }
    return _instance;
  }

  ValueNotifier<LatLng?>? currentPosition = ValueNotifier<LatLng?>(null);
  ValueNotifier<Set<Marker>> markers = ValueNotifier<Set<Marker>>({});

  Future<LatLng?> getCurrentPosition() async {
    final check = await requestAndCheckPermission();
    if (check) {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
      currentPosition?.value = LatLng(position.latitude, position.longitude);
      addMarker(CodeGenerator.instance!.generateCode('m'), currentPosition!.value, title: 'Me!');
      return currentPosition?.value;
    } else {
      return null;
    }
  }

  Set<Marker?> addMarker(String markerId, LatLng? position, {required String title}) {
    if (position != null) {
      final marker = Marker(
        markerId: MarkerId(markerId),
        position: position,
        infoWindow: InfoWindow(title: title),
      );
      try {
        final markerPosition = markers.value.firstWhere((marker) => marker.markerId.value == markerId);
        markerPosition.copyWith(positionParam: LatLng(position.latitude, position.longitude));
        return markers.value;
      } catch (e) {
        markers.value.add(marker);
        return markers.value;
      }
    } else {
      return markers.value;
    }
  }

  Stream<void> listenToPositionChanges() async* {
    final check = await requestAndCheckPermission();
    if (check) {
      Stream<Position> position =
          Geolocator.getPositionStream(desiredAccuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 10));
      position.listen((position) {
        try {
          final currentPositionMarker = markers.value.firstWhere((marker) => marker.markerId.value == 'm1');
          currentPositionMarker.copyWith(positionParam: LatLng(position.latitude, position.longitude));
        } catch (_) {}
        currentPosition?.value = LatLng(position.latitude, position.longitude);
      });
    }
  }

  Future<double> getPositionBetweenKilometers(LatLng startLatLng, LatLng endLatLng) async {
    final meters = Geolocator.distanceBetween(
        startLatLng.latitude, startLatLng.longitude, endLatLng.latitude, endLatLng.longitude);
    return meters / 1000;
  }

  Future<List<PointLatLng>> getRouteCoordinates(LatLng? startLatLng, LatLng? endLatLng) async {
    var uri = Uri.parse(
        "https://maps.googleapis.com/maps/api/directions/json?origin=${startLatLng?.latitude},${startLatLng?.longitude}&destination=${endLatLng?.latitude},${endLatLng?.longitude}&key=${GoogleMapKey.key}");

    http.Response response = await http.get(uri);
    Map values = jsonDecode(response.body);

    final points = values['routes'][0]['overview_polyline']['points'];
    final place = values['routes'][0]['legs'][0]['end_address'];

    final polylines = PolylinePoints().decodePolyline(points);

    addMarker(CodeGenerator.instance!.generateCode('m'), endLatLng, title: '$place');
    return polylines;
  }

  Future<bool> requestAndCheckPermission() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      final request = await Geolocator.requestPermission();
      if (request == LocationPermission.always) {
        return true;
      } else {
        return false;
      }
    } else if (permission == LocationPermission.always) {
      return true;
    } else {
      return false;
    }
  }
}

// "https://maps.googleapis.com/maps/api/directions/json?origin=4.824167,7.033611&destination=11.833333,13.150000&key=AIzaSyCbIWmCy0PNQI7TD4xxOBq15S8aMNi0ry4");
