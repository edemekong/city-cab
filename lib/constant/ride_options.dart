import 'package:citycab/models/ride_option.dart';
import 'package:citycab/utils/icons_assets.dart';

List<RideOption> rideOptions = [
  RideOption(
    id: '00',
    title: 'Stardard',
    timeOfArrival: DateTime.now().add(Duration(minutes: 5)),
    price: 500,
    icon: IconsAssets.stardard_car,
  ),
  RideOption(
    id: '01',
    title: 'Premium',
    timeOfArrival: DateTime.now().add(Duration(minutes: 3)),
    price: 1000,
    icon: IconsAssets.premium_car,
  ),
  RideOption(
    id: '02',
    title: 'VIP',
    timeOfArrival: DateTime.now().add(Duration(minutes: 2)),
    price: 2000,
    icon: IconsAssets.vip_car,
  ),
];
