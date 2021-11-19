import 'package:citycab/ui/theme.dart';
import 'package:citycab/ui/widget/buttons/city_cab_button.dart';
import 'package:citycab/ui/widget/cards/rating_card.dart';
import 'package:citycab/ui/widget/titles/bottom_slider_title.dart';
import 'package:citycab/utils/icons_assets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';

import '../map_state.dart';

class DriverOnTheWay extends StatelessWidget {
  const DriverOnTheWay({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<MapState>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: BottomSliderTitle(title: 'YOUR DRIVER IS ON THE WAY'),
        ),
        const SizedBox(height: CityTheme.elementSpacing),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Icon(
                Icons.timelapse_rounded,
                color: Colors.grey[600],
                size: 18,
              ),
              const SizedBox(width: 4),
              Text(
                'Pickup in 4:49',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: CityTheme.cityblue,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey[300],
                    child: Icon(
                      Icons.person,
                      color: CityTheme.cityBlack,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mr Kelvin Feige',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: CityTheme.cityBlack,
                    ),
                  ),
                  const SizedBox(height: 4),
                  RatingCard(rating: 4),
                ],
              ),
              const SizedBox(width: 16),
              Column(
                children: [
                  Image.asset(
                    IconsAssets.vip_car,
                    height: 60,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'BMW EOS 400',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: CityTheme.cityBlack,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'CITY-2342534',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: CityTheme.cityblue,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: CityCabButton(
                  title: 'Call',
                  color: CityTheme.cityblue,
                  textColor: CityTheme.cityWhite,
                  disableColor: CityTheme.cityLightGrey,
                  buttonState: ButtonState.initial,
                  onTap: () {
                    state.callDriver();
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CityCabButton(
                  title: 'Cancel',
                  color: CityTheme.cityWhite,
                  textColor: CityTheme.cityBlack,
                  disableColor: CityTheme.cityLightGrey,
                  buttonState: ButtonState.initial,
                  borderColor: Colors.grey[800],
                  onTap: () {
                    state.cancelRide();
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
