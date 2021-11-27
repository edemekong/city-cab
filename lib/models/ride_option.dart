import 'package:citycab/utils/icons_assets.dart';

class RideOption {
  final String id;
  final String title;
  final DateTime timeOfArrival;
  final double price;
  final String icon;

  const RideOption({
    required this.id,
    required this.title,
    required this.timeOfArrival,
    required this.price,
    required this.icon,
  });

  factory RideOption.fromMap(Map<String, dynamic> data) {
    getIcon(String id) {
      if (id == '3') {
        return car_list[3];
      } else if (id == '1') {
        return car_list[1];
      } else {
        return car_list[0];
      }
    }

    return RideOption(
      id: data['id'] ?? '',
      price: data['price'] ?? 0.0,
      timeOfArrival: data['time_of_arrival'] ?? DateTime.now(),
      title: data['ride_type'],
      icon: getIcon(data['id']),
    );
  }
}
