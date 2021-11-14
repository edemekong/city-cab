import 'package:citycab/pages/map/map_state.dart';
import 'package:citycab/ui/theme.dart';
import 'package:citycab/ui/widget/textfields/cab_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchMapBar extends StatelessWidget {
  const SearchMapBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<MapState>();

    return SafeArea(
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
                        focusNode: state.focusNode,
                        child: CityTextField(
                          label: 'My Address',
                          controller: state.currentAddressController,
                          onChanged: (v) {
                            state.searchAddress(v);
                          },
                        ).paddingBottom(12),
                      ),
                      Focus(
                        focusNode: state.focusNode,
                        child: CityTextField(
                          label: 'Destination Address',
                          controller: state.destinationAddressController,
                          onChanged: (v) {
                            state.searchAddress(v);
                          },
                        ),
                      ),
                    ],
                  ).paddingRight(12).paddingVertical(12),
                ),
              ],
            ),
            Builder(builder: (context) {
              if (state.searchedAddress.isNotEmpty && state.focusNode!.hasFocus) {
                return Container(
                  width: double.infinity,
                  height: 350,
                  color: Colors.grey.withOpacity(.1),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: state.searchedAddress.length,
                    itemBuilder: (context, index) {
                      final address = state.searchedAddress[index];
                      return ListTile(
                        title: Text('${address.street}, ${address.city}'),
                        subtitle: Text('${address.state}, ${address.country}'),
                        trailing: Icon(Icons.place_outlined, size: 12),
                        onTap: () {
                          state.onTapAddressList(address);
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
    );
  }
}
