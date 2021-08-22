import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:citycab/models/address.dart';
import 'package:citycab/services/map_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

part 'map_event.dart';
part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc() : super(MapInitial());

  final currentPosition = MapService.instance?.currentPosition;

  @override
  Stream<MapState> mapEventToState(MapEvent event) async* {
    if (event is LoadMyPosition) {
      yield* _loadPosition(event);
    } else if (event is SearchAddress) {
      yield* _searchAddress(event.query);
    } else if (event is LoadRouteCoordinates) {
      yield* _getRoute(event);
    }
  }

  Stream<MapState> _loadPosition(LoadMyPosition event) async* {
    if (event.latLng == null) {
      await MapService.instance?.getCurrentPosition();
      MapService.instance?.listenToPositionChanges();
      yield LoadedCurrentPosition(currentPosition?.value);
    } else {
      final myPosition = await MapService.instance?.getPosition(event.latLng!);
      yield LoadedCurrentPosition(myPosition);
    }
  }

  Stream<MapState> _searchAddress(String query) async* {
    await MapService.instance?.getAddressFromQuery(query);
    yield LoadedSearchAddressResults(MapService.instance?.searchedAddress);
  }

  Stream<MapState> _getRoute(LoadRouteCoordinates event) async* {
    final endAddress = await MapService.instance?.getRouteCoordinates(event.startLatLng, event.endLatLng);
    yield LoadedRoutes(currentPosition!.value!, endAddress!);
  }
}
