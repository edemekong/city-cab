import 'package:citycab/constant/my_address.dart';
import 'package:citycab/models/user.dart';
import 'package:citycab/ui/theme.dart';
import 'package:citycab/ui/widget/buttons/city_cab_button.dart';
import 'package:citycab/ui/widget/cards/address_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';

import '../map_state.dart';

class TakeARide extends StatelessWidget {
  const TakeARide({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<MapState>();

    return Builder(builder: (context) {
      final isUserDriver = state.userRepo.currentUser?.isDriverRole ?? false;

      if (isUserDriver == true) {
        return Padding(
          padding: const EdgeInsets.all(CityTheme.elementSpacing),
          child: CityCabButton(
            title: state.isActive ? 'Go Offline' : 'Go Online',
            textColor: Colors.white,
            color: state.isActive ? Colors.green : Colors.red,
            onTap: () {
              state.changeActivePresence();
            },
          ),
        );
      }
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            InkWell(
              onTap: () {
                state.searchLocation();
              },
              child: Container(
                height: 54,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Enter Your Destination...',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                    Icon(Icons.search, size: 30),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Column(
              children: List.generate(
                myAddresses.length,
                (index) {
                  final address = myAddresses[index];
                  return AddressCard(
                    address: address,
                    onTap: () {
                      state.onTapMyAddresses(address);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }
}
