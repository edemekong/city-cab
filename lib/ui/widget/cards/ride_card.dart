import 'package:citycab/models/ride_option.dart';
import 'package:citycab/ui/theme.dart';
import 'package:flutter/material.dart';

class RideOptionCard extends StatelessWidget {
  final RideOption option;
  final bool isSelected;
  final void Function(RideOption option) onTap;

  const RideOptionCard({
    Key? key,
    required this.option,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: () {
        onTap(option);
      },
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: isSelected ? CityTheme.cityblue.withOpacity(.02) : Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              width: 1,
              color: isSelected ? CityTheme.cityblue : Colors.grey.shade400,
            )),
        child: Column(
          children: [
            Expanded(
              child: Image.asset(
                option.icon,
                color: isSelected ? CityTheme.cityblue : Colors.grey[600],
              ),
            ),
            Text(
              '${option.title}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${option.timeOfArrival.difference(DateTime.now()).inMinutes} min',
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? CityTheme.cityblue : Colors.grey[800],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '\₦${option.price}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[900],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
