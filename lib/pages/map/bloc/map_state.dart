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
  final Address? address;
  const LoadedCurrentPosition(this.address);
}

class LoadingAddress extends MapState {}

class LoadedSearchAddressResults extends MapState {
  final List<Address>? address;
  const LoadedSearchAddressResults(this.address);
}

class LoadedRoutes extends MapState {
  final Address startAddress;
  final Address endAddress;

  const LoadedRoutes(this.startAddress, this.endAddress);
}
