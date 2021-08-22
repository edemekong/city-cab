import 'dart:async';

import 'package:citycab/models/address.dart';
import 'package:citycab/pages/map/bloc/map_bloc.dart';
import 'package:citycab/services/map_services.dart';
import 'package:citycab/ui/info_window/custom_info_window.dart';
import 'package:citycab/ui/theme.dart';
import 'package:citycab/ui/widget/textfields/cab_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapView extends StatefulWidget {
  MapView({Key? key}) : super(key: key);

  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  GoogleMapController? _controller;
  final currentAddressController = TextEditingController();
  final destinationAddressController = TextEditingController();

  List<Address> searchedAddress = [];

  MapBloc bloc = MapBloc();

  FocusNode? _focusNode;

  @override
  void initState() {
    _focusNode = FocusNode();
    bloc.add(LoadMyPosition());

    super.initState();
  }

  @override
  void dispose() {
    bloc.close();
    MapService.instance?.controller.dispose();
    super.dispose();
  }

  _animateCamera(LatLng latLng) async {
    await _controller?.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: LatLng(latLng.latitude, latLng.longitude), zoom: 16.5),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MapBloc>(
      create: (context) => bloc,
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: BlocConsumer<MapBloc, MapState>(
            listener: (context, state) {
              if (state is LoadedCurrentPosition) {
                setState(() {
                  currentAddressController.text = "${state.address?.street}, ${state.address?.city}";
                });
              }
            },
            bloc: bloc,
            builder: (context, state) {
              if (state is LoadingCurrentPosition) {
                return Center(child: const CircularProgressIndicator());
              } else if (state is LoadedCurrentPosition ||
                  state is LoadedSearchAddressResults ||
                  state is LoadedRoutes) {
                final address =
                    state is LoadedCurrentPosition ? state.address : MapService.instance?.currentPosition?.value;
                return Stack(
                  children: [
                    Builder(builder: (context) {
                      return GoogleMap(
                        mapType: MapType.normal,
                        polylines: {
                          if (state is LoadedRoutes)
                            if (state.endAddress.polylines != [])
                              Polyline(
                                polylineId: const PolylineId('overview_polyline'),
                                color: CityTheme.cityBlack,
                                width: 5,
                                points: state.endAddress.polylines.map((e) => LatLng(e.latitude, e.longitude)).toList(),
                              ),
                        },
                        markers: MapService.instance?.markers.value ?? {},
                        initialCameraPosition: CameraPosition(target: address!.latLng!, zoom: 15),
                        onMapCreated: (GoogleMapController controller) {
                          setState(() {
                            _controller = controller;
                            MapService.instance?.controller.googleMapController = controller;
                          });
                          _animateCamera(address.latLng!);
                        },
                        onTap: (position) {
                          MapService.instance?.controller.hideInfoWindow!();
                        },
                        onCameraMove: (controller) {
                          MapService.instance?.controller.onCameraMove!();
                        },
                      );
                    }),
                    CustomInfoWindow(
                      controller: MapService.instance!.controller,
                      height: MediaQuery.of(context).size.width * 0.12,
                      width: MediaQuery.of(context).size.width * 0.4,
                      offset: 50,
                    ),
                    Positioned(
                      top: 10,
                      left: 15,
                      right: 15,
                      child: SafeArea(
                        child: Container(
                          decoration: BoxDecoration(
                            color: CityTheme.cityWhite,
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(color: CityTheme.cityBlack.withOpacity(.2), spreadRadius: 2, blurRadius: 5),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Column(
                                    children: [
                                      Icon(Icons.circle, size: 16, color: CityTheme.cityblue),
                                      Container(width: 4, height: 40, color: CityTheme.cityblue),
                                      Icon(Icons.place, color: CityTheme.cityblue),
                                    ],
                                  ).paddingHorizontal(4),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Focus(
                                          focusNode: _focusNode,
                                          child: CityTextField(
                                            label: 'My Address',
                                            controller: currentAddressController,
                                            onChanged: (v) {
                                              bloc.add(SearchAddress(v));
                                            },
                                          ).paddingBottom(12),
                                        ),
                                        Focus(
                                          focusNode: _focusNode,
                                          child: CityTextField(
                                            label: 'Destination Address',
                                            controller: destinationAddressController,
                                            onChanged: (v) {
                                              bloc.add(SearchAddress(v));
                                              setState(() {
                                                searchedAddress = MapService.instance?.searchedAddress
                                                        .where(
                                                            (q) => v.contains("${q.street}") || v.contains("${q.city}"))
                                                        .toList() ??
                                                    [];
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ).paddingRight(12).paddingVertical(12),
                                  ),
                                ],
                              ),
                              Builder(builder: (context) {
                                if (state is LoadedSearchAddressResults) {
                                  print(state.address);
                                  return Container(
                                    width: double.infinity,
                                    height: 350,
                                    color: Colors.grey.withOpacity(.1),
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: searchedAddress.length,
                                      itemBuilder: (context, index) {
                                        final address = searchedAddress[index];
                                        return ListTile(
                                          title: Text('${address.street}, ${address.city}'),
                                          subtitle: Text('${address.state}, ${address.country}'),
                                          trailing: Icon(Icons.place_outlined, size: 12),
                                          onTap: () {
                                            _focusNode?.unfocus();

                                            bloc.add(LoadMyPosition(latLng: address.latLng));
                                            if (currentAddressController.text.isNotEmpty &&
                                                destinationAddressController.text.isEmpty) {
                                              setState(() {
                                                currentAddressController.text = "${address.street}, ${address.city}";
                                                MapService.instance?.currentPosition?.value = address;
                                              });
                                              _animateCamera(address.latLng!);
                                            } else if (currentAddressController.text.isNotEmpty &&
                                                destinationAddressController.text.isNotEmpty) {
                                              bloc.add(LoadRouteCoordinates(
                                                  MapService.instance!.currentPosition!.value!.latLng!,
                                                  address.latLng!));
                                              _animateCamera(address.latLng!);
                                            }
                                          },
                                        );
                                      },
                                    ),
                                  );
                                } else {
                                  return SizedBox.shrink();
                                }
                              }),
                            ],
                          ),
                        ).paddingAll(8),
                      ),
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
