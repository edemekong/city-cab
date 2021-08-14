part of 'map_bloc.dart';

abstract class MapState extends Equatable {
  const MapState();

  @override
  List<Object> get props => [];
}

class MapInitial extends MapState {}

class LoadingCurrentPosition extends MapState {
  const LoadingCurrentPosition();
}

class LoadedCurrentPosition extends MapState {
  final LatLng? position;
  final Set<Marker>? currentPositionMarker;
  final List<PointLatLng>? polyline;

  const LoadedCurrentPosition(this.position, this.currentPositionMarker, this.polyline);
}
