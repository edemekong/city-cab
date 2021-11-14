import 'package:citycab/models/address.dart';
import 'package:citycab/services/map_services.dart';
import 'package:citycab/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapState extends ChangeNotifier {
  GoogleMapController? controller;
  final currentPosition = MapService.instance?.currentPosition;

  final currentAddressController = TextEditingController();
  final destinationAddressController = TextEditingController();

  Address? startAddress;
  Address? endAddress;

  List<Address> searchedAddress = [];

  FocusNode? focusNode;

  Set<Polyline> get polylines {
    return {
      if (endAddress?.polylines != [])
        Polyline(
          polylineId: const PolylineId('overview_polyline'),
          color: CityTheme.cityBlack,
          width: 5,
          points: endAddress?.polylines.map((e) => LatLng(e.latitude, e.longitude)).toList() ?? [],
        ),
    };
  }

  MapState() {
    focusNode = FocusNode();
    getCurrentLocation();
  }

  @override
  void dispose() {
    MapService.instance?.controller.dispose();
    super.dispose();
  }

  Future<void> animateCamera(LatLng latLng) async {
    await controller?.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: LatLng(latLng.latitude, latLng.longitude), zoom: 16.5),
    ));
  }

  Future<void> loadMyPosition(LatLng? position) async {
    if (position == null) {
      final position = await MapService.instance?.getCurrentPosition();
      MapService.instance?.listenToPositionChanges();
      startAddress = position;
      notifyListeners();
    } else {
      final myPosition = await MapService.instance?.getPosition(position);
      startAddress = myPosition;
      notifyListeners();
    }
  }

  Future<void> loadRouteCoordinates(LatLng start, LatLng end) async {
    final endPosition = await MapService.instance?.getRouteCoordinates(start, end);
    startAddress = MapService.instance?.currentPosition.value;
    endAddress = endPosition;
    notifyListeners();
  }

  Future<void> searchAddress(String query) async {
    await MapService.instance!.getAddressFromQuery(query);
    searchedAddress = MapService.instance?.searchedAddress
            .where((q) => query.contains("${q.street}") || query.contains("${q.city}"))
            .toList() ??
        [];
    notifyListeners();
    print('searching..');
  }

  void onMapCreated(GoogleMapController controller) {
    this.controller = controller;
    MapService.instance?.controller.googleMapController = controller;
    animateCamera(currentPosition?.value?.latLng ?? LatLng(0, 0));
  }

  void onTapMap(LatLng argument) {
    MapService.instance?.controller.hideInfoWindow!();
  }

  void onCameraMove(CameraPosition position) {
    MapService.instance?.controller.onCameraMove!();
  }

  void onTapAddressList(Address address) {
    focusNode?.unfocus();
    loadMyPosition(address.latLng);
    if (currentAddressController.text.isNotEmpty && destinationAddressController.text.isEmpty) {
      currentAddressController.text = "${address.street}, ${address.city}";
      MapService.instance?.currentPosition.value = address;
      notifyListeners();
      animateCamera(address.latLng!);
    } else if (currentAddressController.text.isNotEmpty && destinationAddressController.text.isNotEmpty) {
      loadRouteCoordinates(MapService.instance!.currentPosition.value!.latLng!, address.latLng!);
      animateCamera(address.latLng!);
    }
  }

  void getCurrentLocation() async {
    final address = await MapService.instance?.getCurrentPosition();
    currentAddressController.text = "${address?.street}, ${address?.city}";
    notifyListeners();
  }
}
