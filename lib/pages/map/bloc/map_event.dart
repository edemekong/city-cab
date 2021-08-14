part of 'map_bloc.dart';

abstract class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object> get props => [];
}

class LoadCurrentPosition extends MapEvent {
  const LoadCurrentPosition();
}

class LoadPositionBetweenPoints extends MapEvent {
  final LatLng startLatLng;
  final LatLng endLatLng;
  const LoadPositionBetweenPoints(this.startLatLng, this.endLatLng);
}

class LoadouteCoordinates extends MapEvent {
  final LatLng startLatLng;
  final LatLng endLatLng;
  const LoadouteCoordinates(this.startLatLng, this.endLatLng);
}
