import 'package:flutter/material.dart';

import '../../theme.dart';

class RatingCard extends StatelessWidget {
  const RatingCard({
    Key? key,
    this.rating,
  }) : super(key: key);
  final int? rating;
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(rating! < 1 ? 5 + 1 : 5, (index) {
        if (index == 5 && rating! < 1) {
          return Text(
            '(No ratings Available)',
            style: Theme.of(context).textTheme.bodyText1!.copyWith(color: CityTheme.cityGrey),
          ).paddingLeft(CityTheme.elementSpacing / 2);
        }
        if (rating! > index) {
          return Icon(Icons.star_rounded, size: 16, color: CityTheme.cityOrange);
        }
        return Icon(
          Icons.star_border_rounded,
          size: 16,
          color: CityTheme.cityGrey,
        );
      }),
    ).paddingBottom(CityTheme.elementSpacing / 4);
  }
}
