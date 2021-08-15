import 'dart:async';

import 'package:citycab/pages/map/bloc/map_bloc.dart';
import 'package:citycab/services/map_services.dart';
import 'package:citycab/ui/info_window/custom_info_window.dart';
import 'package:citycab/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapView extends StatefulWidget {
  MapView({Key? key}) : super(key: key);

  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final Completer<GoogleMapController> _controller = Completer();

  MapBloc bloc = MapBloc();

  @override
  void initState() {
    bloc.add(LoadCurrentPosition());

    super.initState();
  }

  @override
  void dispose() {
    bloc.close();
    MapService.instance?.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MapBloc>(
      create: (context) => bloc,
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: BlocBuilder<MapBloc, MapState>(
            bloc: bloc,
            builder: (context, state) {
              if (state is LoadingCurrentPosition) {
                return Center(child: const CircularProgressIndicator());
              } else if (state is LoadedCurrentPosition) {
                return Stack(
                  children: [
                    GoogleMap(
                      mapType: MapType.normal,
                      polylines: {
                        if (state.polyline != null)
                          Polyline(
                            polylineId: const PolylineId('overview_polyline'),
                            color: CityTheme.cityBlack,
                            width: 5,
                            points: state.polyline?.map((e) => LatLng(e.latitude, e.longitude)).toList() ?? [],
                          ),
                      },
                      markers: state.currentPositionMarker!,
                      initialCameraPosition: CameraPosition(target: state.position!, zoom: 15),
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                        MapService.instance?.controller.googleMapController = controller;
                      },
                      onTap: (position) {
                        MapService.instance?.controller.hideInfoWindow!();
                      },
                      onCameraMove: (controller) {
                        MapService.instance?.controller.onCameraMove!();
                      },
                    ),
                    CustomInfoWindow(
                      controller: MapService.instance!.controller,
                      height: MediaQuery.of(context).size.width * 0.12,
                      width: MediaQuery.of(context).size.width * 0.4,
                      offset: 30,
                    ),
                  ],
                );
              } else {
                return SizedBox.shrink();
              }
            }),
      ),
    );
  }
}
