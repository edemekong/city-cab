import 'package:citycab/constant/ride_options.dart';
import 'package:citycab/models/address.dart';
import 'package:citycab/models/rate.dart';
import 'package:citycab/models/ride.dart';
import 'package:citycab/models/ride_option.dart';
import 'package:citycab/models/user.dart';
import 'package:citycab/repositories/ride_repository.dart';
import 'package:citycab/repositories/user_repository.dart';
import 'package:citycab/services/code_generator.dart';
import 'package:citycab/services/map_services.dart';
import 'package:citycab/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum RideState { initial, searchingAddress, confirmAddress, selectRide, requestRide, driverIsComing, inMotion, arrived }

class MapState extends ChangeNotifier {
  GoogleMapController? controller;
  final currentPosition = MapService.instance!.currentPosition;
  final userRepo = UserRepository.instance;
  final rideRepo = RideRepository.instance;

  final currentAddressController = TextEditingController();
  final destinationAddressController = TextEditingController();

  Address? startAddress;
  Address? endAddress;

  RideOption? selectedOption;

  List<Address> searchedAddress = [];
  List<bool> isSelectedOptions = [];

  FocusNode? focusNode;
  RideState _rideState = RideState.initial;

  bool isActive = false;

  RideState get rideState {
    return _rideState;
  }

  set changeRideState(RideState state) {
    _rideState = state;
    notifyListeners();
  }

  final pageController = PageController();

  int pageIndex = 0;

  MapState() {
    focusNode = FocusNode();
    isSelectedOptions = List.generate(rideOptions.length, (index) => index == 0 ? true : false);
    selectedOption = rideOptions[0];
    destinationAddressController
      ..addListener(() {
        if (destinationAddressController.text.isEmpty) {
          searchedAddress.clear();
          notifyListeners();
        }
        endAddress = null;
        notifyListeners();
      });
    getCurrentLocation();
    isActive = userRepo.currentUser?.isActive ?? false;
    notifyListeners();
  }

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

  Future<Address?> loadMyPosition(LatLng? position) async {
    if (position == null) {
      final position = await MapService.instance?.getCurrentPosition();
      startAddress = position;

      MapService.instance?.listenToPositionChanges(eventFiring: (Address? address) async {
        if (address != null) {
          if (userRepo.currentUserRole == Roles.driver) {
            await userRepo.updateDriverLocation(UserRepository.instance.currentUser?.uid, address.latLng);
          }
        }

        startAddress = address;
        notifyListeners();
        print('updating address');
      }).listen((event) {});
      animateCamera(startAddress!.latLng);
      notifyListeners();
    } else {
      final myPosition = await MapService.instance?.getPosition(position);
      startAddress = myPosition;

      animateCamera(startAddress!.latLng);
      notifyListeners();
    }
    MapService.instance?.markers.notifyListeners();

    notifyListeners();
    return startAddress;
  }

  Future<void> loadRouteCoordinates(LatLng start, LatLng end) async {
    final endPosition = await MapService.instance?.getRouteCoordinates(start, end);
    startAddress = MapService.instance?.currentPosition.value;
    endAddress = endPosition;
    notifyListeners();
  }

  Future<void> searchAddress(String query) async {
    if (query.length >= 3) {
      await MapService.instance!.getAddressFromQuery(query);
      searchedAddress = MapService.instance?.searchedAddress
              .where((q) => query.contains("${q.street}") || query.contains("${q.city}"))
              .toList() ??
          [];
    }

    notifyListeners();
  }

  void onMapCreated(GoogleMapController controller) {
    this.controller = controller;
    MapService.instance?.controller.googleMapController = controller;
    animateCamera(currentPosition.value?.latLng ?? LatLng(0, 0));
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
      animateCamera(address.latLng);
    } else if (currentAddressController.text.isNotEmpty && destinationAddressController.text.isNotEmpty) {
      destinationAddressController.text = "${address.street}, ${address.city}";
      notifyListeners();
      loadRouteCoordinates(MapService.instance!.currentPosition.value!.latLng, address.latLng);
      animateCamera(address.latLng);
    }
  }

  void getCurrentLocation() async {
    final address = await loadMyPosition(null);
    currentAddressController.text = "${address?.street}, ${address?.city}";
    notifyListeners();
  }

  void onTapRideOption(RideOption option, int index) {
    for (var i = 0; i < isSelectedOptions.length; i++) {
      isSelectedOptions[i] = false;
    }
    isSelectedOptions[index] = true;
    selectedOption = option;
    notifyListeners();
  }

  void onPageChanged(int value) {
    pageIndex = value;
    notifyListeners();
  }

  void animateToPage({required int pageIndex, required RideState state}) {
    pageController.jumpToPage(pageIndex);
    changeRideState = state;
  }

  void searchLocation() {
    animateToPage(pageIndex: 1, state: RideState.searchingAddress);
  }

  void proceedRide() {
    animateToPage(pageIndex: 3, state: RideState.confirmAddress);
  }

  void confirmRide() async {
    animateToPage(pageIndex: 4, state: RideState.confirmAddress);
    final ownerUID = userRepo.currentUser?.uid;
    if (ownerUID != null && ownerUID != '') {
      final ride = _initializeRide(ownerUID);
      await rideRepo?.boardRide(ride);
    }
  }

  Ride _initializeRide(String uid) {
    final id = CodeGenerator.instance!.generateCode('city-id');
    final ride = Ride(
      createdAt: DateTime.now(),
      driverUID: '',
      endAddress: endAddress!,
      id: id,
      ownerUID: uid,
      passengers: [uid],
      rate: Rate(uid: uid, subject: '', body: '', stars: 0),
      rideOption: selectedOption!,
      startAddress: startAddress!,
      status: RideStatus.initial,
    );

    return ride;
  }

  void callDriver() {}

  void cancelRide() {
    animateToPage(pageIndex: 0, state: RideState.initial);
  }

  void closeSearching() {
    animateToPage(pageIndex: 0, state: RideState.initial);
  }

  void requestRide() {
    animateToPage(pageIndex: 2, state: RideState.requestRide);
  }

  void onTapMyAddresses(Address address) {
    destinationAddressController.text = "${address.street}, ${address.city}";
    notifyListeners();
    loadRouteCoordinates(MapService.instance!.currentPosition.value!.latLng, address.latLng);
    animateCamera(address.latLng);
    searchLocation();
  }

  void changeActivePresence() async {
    isActive = !isActive;
    notifyListeners();
    await userRepo.updateOnlinePresense(userRepo.currentUser?.uid, isActive);
  }
}
