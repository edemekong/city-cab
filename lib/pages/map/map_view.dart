import 'package:citycab/pages/map/map_state.dart';
import 'package:citycab/pages/map/widgets/bottom_slide.dart';
import 'package:citycab/pages/map/widgets/search_map_address.dart';
import 'package:citycab/services/map_services.dart';
import 'package:citycab/ui/info_window/custom_info_window.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class MapView extends StatelessWidget {
  const MapView({Key? key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<MapState>();
    return SizedBox(
      key: key,
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Builder(
        builder: (context) {
          if (state.currentPosition?.value == null) {
            return Center(child: const CircularProgressIndicator());
          }

          return Stack(
            children: [
              Builder(builder: (context) {
                return GoogleMap(
                  mapType: MapType.normal,
                  polylines: state.polylines,
                  markers: MapService.instance?.markers.value ?? {},
                  initialCameraPosition: CameraPosition(
                    target: state.currentPosition?.value?.latLng ?? LatLng(0, 0),
                    zoom: 15,
                  ),
                  onMapCreated: state.onMapCreated,
                  onTap: state.onTapMap,
                  onCameraMove: state.onCameraMove,
                );
              }),
              CustomInfoWindow(
                controller: MapService.instance!.controller,
                height: MediaQuery.of(context).size.width * 0.12,
                width: MediaQuery.of(context).size.width * 0.4,
                offset: 50,
              ),
              Positioned(
                bottom: 0,
                child: BottomSlider(),
              ),
              state.rideState == RideState.searchingAddress
                  ? Positioned(top: 10, left: 15, right: 15, child: SearchMapBar())
                  : SizedBox.shrink(),
            ],
          );
        },
      ),
    );
  }
}

class MapViewWidget extends StatelessWidget {
  const MapViewWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = MapState();
    return ChangeNotifierProvider(
      create: (_) => state,
      child: MapView(key: ValueKey('map')),
    );
  }
}
