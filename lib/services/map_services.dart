import 'dart:async';
import 'dart:typed_data';

import 'package:citycab/constant/google_map_key.dart';
import 'package:citycab/models/address.dart';
import 'package:citycab/models/citycab_info_window.dart';
import 'package:citycab/ui/info_window/custom_info_window.dart';
import 'package:citycab/ui/info_window/custom_widow.dart';
import 'package:citycab/utils/images_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;
import 'dart:convert';

import 'code_generator.dart';

class Deley {
  final int? milliseconds;
  VoidCallback? action;
  Timer? _timer;

  Deley({this.milliseconds});
  run(VoidCallback action) {
    if (_timer != null) {
      _timer?.cancel();
    }
    _timer = Timer(Duration(microseconds: milliseconds ?? 400), action);
  }
}

class MapService {
  MapService._();

  static MapService? _instance;

  static MapService? get instance {
    if (_instance == null) {
      _instance = MapService._();
    }
    return _instance;
  }

  final String baseUrl = "https://maps.googleapis.com/maps/api/directions/json";

  Duration duration = Duration();
  final _deley = Deley(milliseconds: 2000);

  ValueNotifier<Address?> currentPosition = ValueNotifier<Address?>(null);
  ValueNotifier<Set<Marker>> markers = ValueNotifier<Set<Marker>>({});
  List<Address> searchedAddress = [];

  CustomInfoWindowController controller = CustomInfoWindowController();

  Future<Set<Marker>> addMarker(String markerId, Address? address, BitmapDescriptor icon,
      {required DateTime time, required InfoWindowType type}) async {
    if (address != null) {
      final Uint8List markerIcon =
          await getBytesFromAsset(type == InfoWindowType.position ? ImagesAsset.circlePin : ImagesAsset.pin, 65);
      final icon = BitmapDescriptor.fromBytes(markerIcon);

      final marker = Marker(
          markerId: MarkerId(markerId),
          position: address.latLng,
          icon: icon,
          onTap: () {
            controller.addInfoWindow!(
              CustomWindow(
                info: CityCabInfoWindow(
                  name: "${address.street}, ${address.city}",
                  position: address.latLng,
                  type: type,
                  time: duration,
                ),
              ),
              address.latLng,
            );
          });
      try {
        final markerPosition = markers.value.firstWhere((marker) => marker.markerId.value == markerId);
        markerPosition.copyWith(positionParam: LatLng(address.latLng.latitude, address.latLng.longitude));
        return markers.value;
      } catch (e) {
        markers.value.add(marker);
        return markers.value;
      }
    } else {
      return markers.value;
    }
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  Future<double> getPositionBetweenKilometers(LatLng startLatLng, LatLng endLatLng) async {
    final meters = Geolocator.distanceBetween(
        startLatLng.latitude, startLatLng.longitude, endLatLng.latitude, endLatLng.longitude);
    return meters / 500;
  }

  Future<Address> getAddressFromCoodinate(LatLng position, {List<PointLatLng>? polylines}) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    final placemark = placemarks.first;
    final address = Address(
      street: placemark.street ?? '',
      city: placemark.locality ?? '',
      state: placemark.administrativeArea ?? '',
      country: placemark.country ?? '',
      latLng: position,
      polylines: polylines ?? [],
      postcode: placemark.postalCode ?? '',
    );
    return address;
  }

  Future<Address?> getCurrentPosition() async {
    final check = await requestAndCheckPermission();
    if (check) {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);

      final address = await getAddressFromCoodinate(LatLng(position.latitude, position.longitude));
      currentPosition.value = address;
      currentPosition.notifyListeners();

      final icon = await getMapIcon(ImagesAsset.circlePin);
      addMarker(CodeGenerator.instance!.generateCode('m'), currentPosition.value, icon,
          time: DateTime.now(), type: InfoWindowType.position);
      return currentPosition.value;
    } else {
      return null;
    }
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

  Future<Address> getRouteCoordinates(LatLng? startLatLng, LatLng? endLatLng) async {
    markers.value.clear();

    var uri = Uri.parse(
        "$baseUrl?origin=${startLatLng?.latitude},${startLatLng?.longitude}&destination=${endLatLng?.latitude},${endLatLng?.longitude}&key=${GoogleMapKey.key}");
    http.Response response = await http.get(uri);
    Map values = jsonDecode(response.body);
    final points = values['routes'][0]['overview_polyline']['points'];
    final legs = values['routes'][0]['legs'];
    final polylines = PolylinePoints().decodePolyline(points);

    if (legs != null) {
      final DateTime time = DateTime.fromMillisecondsSinceEpoch(values['routes'][0]['legs'][0]['duration']['value']);
      duration = DateTime.now().difference(time);
    }
    Address endAddress = await _getEndAddressAndAddMarkers(startLatLng, endLatLng, polylines);

    /// Get our end address
    return endAddress;
  }

  Future<Address> _getEndAddressAndAddMarkers(
      LatLng? startLatLng, LatLng? endLatLng, List<PointLatLng> polylines) async {
    final endAddress =
        await getAddressFromCoodinate(LatLng(endLatLng!.latitude, endLatLng.longitude), polylines: polylines);
    BitmapDescriptor icon = await getMapIcon(ImagesAsset.pin);

    await addMarker(CodeGenerator.instance!.generateCode('m2'), endAddress, icon,
        time: DateTime.now(), type: InfoWindowType.destination);

    final startAddress =
        await getAddressFromCoodinate(LatLng(startLatLng!.latitude, startLatLng.longitude), polylines: polylines);
    currentPosition.value = startAddress;

    BitmapDescriptor icon2 = await getMapIcon(ImagesAsset.circlePin);
    await addMarker(CodeGenerator.instance!.generateCode('m1'), currentPosition.value, icon2,
        time: DateTime.now(), type: InfoWindowType.position);

    return endAddress;
  }

  Future<BitmapDescriptor> getMapIcon(String iconPath) async {
    final Uint8List endMarker = await getBytesFromAsset(iconPath, 65);
    final icon = BitmapDescriptor.fromBytes(endMarker);
    return icon;
  }

  Stream<void> listenToPositionChanges() async* {
    final check = await requestAndCheckPermission();
    if (check) {
      Stream<Position> position =
          Geolocator.getPositionStream(desiredAccuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 10));
      position.listen((position) async {
        try {
          final currentPositionMarker = markers.value.firstWhere((marker) => marker.markerId.value == 'm1');
          currentPositionMarker.copyWith(positionParam: LatLng(position.latitude, position.longitude));
        } catch (_) {}
        currentPosition.value = await getAddressFromCoodinate(LatLng(position.latitude, position.longitude));
      });
    }
  }

  Future<List<Address>> getAddressFromQuery(String query) async {
    if (query.length > 3) {
      _deley.run(() async {
        try {
          final locations = await locationFromAddress(query);
          for (var i = 0; i < locations.length; i++) {
            final location = locations[i];
            List<Placemark> placemarks = await placemarkFromCoordinates(location.latitude, location.longitude);
            for (var i = 0; i < placemarks.length; i++) {
              final placemark = placemarks[i];
              final address = Address(
                street: placemark.street ?? '',
                city: placemark.locality ?? '',
                state: placemark.administrativeArea ?? '',
                country: placemark.country ?? '',
                latLng: LatLng(location.latitude, location.longitude),
                polylines: [],
                postcode: placemark.postalCode ?? '',
              );
              searchedAddress.add(address);
            }
          }
        } catch (_) {
          print('Failed to get address');
        }
      });
    }
    return searchedAddress;
  }

  Future<Address?> getPosition(LatLng latLng) async {
    final address = await getAddressFromCoodinate(latLng);

    markers.value.clear();
    controller.hideInfoWindow!();

    final icon = await getMapIcon(ImagesAsset.circlePin);
    await addMarker(CodeGenerator.instance!.generateCode('m1'), currentPosition.value, icon,
        time: DateTime.now(), type: InfoWindowType.position);

    return address;
  }
}
