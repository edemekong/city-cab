import 'package:citycab/models/address.dart';
import 'package:flutter/material.dart';

import '../../theme.dart';

class AddressCard extends StatelessWidget {
  final Address? address;

  final void Function()? onTap;
  const AddressCard({
    Key? key,
    this.address,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.all(0),
      leading: Icon(address?.title?.toLowerCase() == 'office' ? Icons.work_outline : Icons.home_outlined,
          size: 30, color: CityTheme.cityblue),
      title: Text(
        '${address?.title}',
        style: TextStyle(
          fontSize: 18,
          color: Colors.grey[800],
        ),
      ),
      subtitle: Text(
        '${address?.street}, ${address?.city} , ${address?.country} ',
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_sharp,
        size: 15,
        color: Colors.grey[600],
      ),
    );
  }
}
