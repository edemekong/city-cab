import 'dart:async';
import 'dart:typed_data';

import 'package:citycab/constant/google_map_key.dart';
import 'package:citycab/models/address.dart';
import 'package:citycab/models/citycab_info_window.dart';
import 'package:citycab/models/user.dart';
import 'package:citycab/repositories/user_repository.dart';
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

  StreamSubscription<Position>? positionStream;

  Duration duration = Duration();
  final _deley = Deley(milliseconds: 5000);

  String get getUserMapIcon {
    Roles? userRoles = UserRepository.instance.currentUserRole;
    return (() {
      if (userRoles == Roles.driver) {
        return ImagesAsset.car;
      } else {
        return ImagesAsset.circlePin;
      }
    })();
  }

  void dispose() {
    positionStream?.cancel();
  }

  ValueNotifier<Address?> currentPosition = ValueNotifier<Address?>(null);
  ValueNotifier<List<Marker>> markers = ValueNotifier<List<Marker>>([]);
  List<Address> searchedAddress = [];

  CustomInfoWindowController controller = CustomInfoWindowController();

  Future<Address?> getCurrentPosition() async {
    final check = await requestAndCheckPermission();
    if (check == true) {
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
      final address = await getAddressFromCoodinate(LatLng(position.latitude, position.longitude));

      final icon = await getMapIcon(getUserMapIcon);
      await addMarker(address, icon, time: DateTime.now(), type: InfoWindowType.position);

      currentPosition.value = address;

      // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
      currentPosition.notifyListeners();
      return currentPosition.value;
    } else {
      return null;
    }
  }

  Stream<void> listenToPositionChanges({required Function(Address?) eventFiring}) async* {
    final check = await requestAndCheckPermission();
    if (check) {
      print('started location');

      positionStream =
          Geolocator.getPositionStream(desiredAccuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 60))
              .listen((position) async {
        eventFiring(currentPosition.value);

        currentPosition.value = await getAddressFromCoodinate(LatLng(position.latitude, position.longitude));

        final icon = await getMapIcon(getUserMapIcon);
        await addMarker(currentPosition.value, icon,
            time: DateTime.now(), type: InfoWindowType.position, position: position);
        // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
        currentPosition.notifyListeners();

        print('updating location');
      });
    }
  }

  Future<Address> getAddressFromCoodinate(LatLng latLng, {List<PointLatLng>? polylines, String? id}) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
    final placemark = placemarks.first;
    final address = Address(
      id: id ?? UserRepository.instance.currentUser?.uid ?? '',
      street: placemark.street ?? '',
      city: placemark.locality ?? '',
      state: placemark.administrativeArea ?? '',
      country: placemark.country ?? '',
      latLng: latLng,
      polylines: polylines ?? [],
      postcode: placemark.postalCode ?? '',
    );
    return address;
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
                id: CodeGenerator.instance!.generateCode('m'),
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

    final icon = await getMapIcon(getUserMapIcon);
    await addMarker(address, icon, time: DateTime.now(), type: InfoWindowType.position);
    // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
    currentPosition.notifyListeners();

    return address;
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
    final endAddress = await getAddressFromCoodinate(LatLng(endLatLng!.latitude, endLatLng.longitude),
        polylines: polylines, id: CodeGenerator.instance?.generateCode('m'));

    BitmapDescriptor icon = await getMapIcon(ImagesAsset.pin);
    await addMarker(endAddress, icon, time: DateTime.now(), type: InfoWindowType.destination);

    final startAddress =
        await getAddressFromCoodinate(LatLng(startLatLng!.latitude, startLatLng.longitude), polylines: polylines);

    BitmapDescriptor startMapIcon = await getMapIcon(getUserMapIcon);
    await addMarker(startAddress, startMapIcon, time: DateTime.now(), type: InfoWindowType.position);

    currentPosition.value = startAddress;
    // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
    currentPosition.notifyListeners();

    return endAddress;
  }

  Future<List<Marker>> addMarker(Address? address, BitmapDescriptor icon,
      {required DateTime time, required InfoWindowType type, Position? position}) async {
    if (address != null) {
      final marker = Marker(
          markerId: MarkerId(address.id),
          position: address.latLng,
          icon: icon,
          rotation: position?.heading ?? 0,
          anchor: Offset(0.5, 0.5),
          zIndex: 2,
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

      final markerPositionIndex = markers.value.indexWhere((marker) => marker.markerId.value == address.id);

      if (markerPositionIndex != -1) {
        markers.value.removeAt(markerPositionIndex);
        markers.value.insert(markerPositionIndex, marker);
      } else {
        markers.value.add(marker);
      }
      // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
      markers.notifyListeners();

      return markers.value;
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

  Future<BitmapDescriptor> getMapIcon(String iconPath) async {
    final Uint8List endMarker = await getBytesFromAsset(iconPath, 65);
    final icon = BitmapDescriptor.fromBytes(endMarker);
    return icon;
  }
}
