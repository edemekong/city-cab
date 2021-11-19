import 'package:citycab/pages/map/widgets/at_destination.dart';
import 'package:citycab/pages/map/widgets/confirm_ride.dart';
import 'package:citycab/pages/map/widgets/driver_on_the_way.dart';
import 'package:citycab/pages/map/widgets/in_motion.dart';
import 'package:citycab/pages/map/widgets/select_ride.dart';
import 'package:citycab/pages/map/widgets/take_a_ride.dart';
import 'package:citycab/ui/theme.dart';
import 'package:citycab/ui/widget/buttons/city_cab_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';

import '../map_state.dart';

class BottomSlider extends StatefulWidget {
  const BottomSlider({
    Key? key,
  }) : super(key: key);

  @override
  State<BottomSlider> createState() => _BottomSliderState();
}

class _BottomSliderState extends State<BottomSlider> {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<MapState>();
    final size = MediaQuery.of(context).size;

    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      padding: const EdgeInsets.only(bottom: CityTheme.elementSpacing, top: CityTheme.elementSpacing),
      height: _getSliderHeight(state, size),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        color: CityTheme.cityWhite,
        boxShadow: [
          BoxShadow(
            color: CityTheme.cityBlack.withOpacity(.1),
            spreadRadius: 6,
            blurRadius: 6,
          )
        ],
      ),
      child: PageView(
        onPageChanged: state.onPageChanged,
        controller: state.pageController,
        physics: NeverScrollableScrollPhysics(),
        children: [
          TakeARide(),
          ConfirmLocation(),
          SelectRide(),
          ConfirmRide(),
          DriverOnTheWay(),
          InMotion(),
          ArrivedAtDestination(),
        ],
      ),
    );
  }

  double _getSliderHeight(MapState state, Size size) {
    var checkSearching = state.rideState == RideState.searchingAddress;

    if (checkSearching) {
      if (state.endAddress != null) {
        return size.height * 0.2;
      } else {
        return size.height;
      }
    } else {
      return size.height * 0.4;
    }
  }
}

class ConfirmLocation extends StatelessWidget {
  const ConfirmLocation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<MapState>();
    var checkSearchingEndLocation = state.rideState == RideState.searchingAddress && state.endAddress != null;

    return GestureDetector(
      onTap: () {
        state.closeSearching();
      },
      child: Container(
        color: Colors.transparent,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Wrap(
            runAlignment: WrapAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(CityTheme.elementSpacing),
                child: Column(
                  children: [
                    state.endAddress != null
                        ? SizedBox.shrink()
                        : SizedBox(
                            height: MediaQuery.of(context).size.height * 0.65,
                            child: Builder(builder: (context) {
                              if (state.searchedAddress.isEmpty) {
                                return Center(
                                  child: Text('No Address Found'),
                                );
                              }
                              return ListView.builder(
                                shrinkWrap: true,
                                itemCount: state.searchedAddress.length,
                                itemBuilder: (context, index) {
                                  final address = state.searchedAddress[index];
                                  return ListTile(
                                    contentPadding: const EdgeInsets.all(0),
                                    horizontalTitleGap: 0,
                                    trailing: Icon(Icons.north_west, size: 16),
                                    title: Text('${address.street}, ${address.city}'),
                                    subtitle: Text('${address.state}, ${address.country}'),
                                    leading: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.place_outlined, color: CityTheme.cityblue, size: 18),
                                      ],
                                    ),
                                    onTap: () {
                                      state.onTapAddressList(address);
                                    },
                                  );
                                },
                              );
                            }),
                          ),
                    const SizedBox(height: CityTheme.elementSpacing * 2),
                    CityCabButton(
                      title: 'Request Ride',
                      color: CityTheme.cityblue,
                      textColor: CityTheme.cityWhite,
                      disableColor: CityTheme.cityLightGrey,
                      buttonState: checkSearchingEndLocation ? ButtonState.initial : ButtonState.disabled,
                      onTap: () {
                        state.requestRide();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
