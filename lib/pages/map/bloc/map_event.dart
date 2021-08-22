part of 'map_bloc.dart';

abstract class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object> get props => [];
}

class LoadMyPosition extends MapEvent {
  final LatLng? latLng;
  const LoadMyPosition({this.latLng});
}

class LoadPositionBetweenPoints extends MapEvent {
  final LatLng startLatLng;
  final LatLng endLatLng;
  const LoadPositionBetweenPoints(this.startLatLng, this.endLatLng);
}

class LoadRouteCoordinates extends MapEvent {
  final LatLng startLatLng;
  final LatLng endLatLng;
  const LoadRouteCoordinates(this.startLatLng, this.endLatLng);
}

class SearchAddress extends MapEvent {
  final String query;
  const SearchAddress(this.query);
}
