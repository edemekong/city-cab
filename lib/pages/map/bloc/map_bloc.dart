import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:citycab/services/map_services.dart';
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
    if (event is LoadCurrentPosition) {
      yield* _loadPosition();
    }
  }

  Stream<MapState> _loadPosition() async* {
    yield LoadingCurrentPosition();
    await MapService.instance?.getCurrentPosition();
    MapService.instance?.listenToPositionChanges();
    final route = await MapService.instance
        ?.getRouteCoordinates(MapService.instance?.currentPosition?.value, LatLng(4.824167, 7.033611));
    yield LoadedCurrentPosition(currentPosition?.value, MapService.instance!.markers.value, route);
  }
}
