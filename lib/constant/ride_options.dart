import 'package:citycab/models/ride_option.dart';
import 'package:citycab/utils/icons_assets.dart';

const List<RideOption> rideOptions = const [
  const RideOption(
    title: 'Stardard',
    timeOfArrival: const Duration(minutes: 5),
    price: 500,
    icon: IconsAssets.stardard_car,
  ),
  const RideOption(
    title: 'Premium',
    timeOfArrival: const Duration(minutes: 3),
    price: 1000,
    icon: IconsAssets.premium_car,
  ),
  const RideOption(
    title: 'VIP',
    timeOfArrival: const Duration(minutes: 2),
    price: 2000,
    icon: IconsAssets.vip_car,
  ),
];
