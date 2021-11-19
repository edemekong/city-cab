import 'package:citycab/ui/theme.dart';
import 'package:citycab/ui/widget/titles/bottom_slider_title.dart';
import 'package:citycab/utils/icons_assets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InMotion extends StatelessWidget {
  const InMotion({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: BottomSliderTitle(title: 'You Are In Motion'),
        ),
        const SizedBox(height: 16),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: CityTheme.cityblue.withOpacity(.08),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Standard',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '\₦5,000',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.grey[900],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.timelapse_rounded,
                            color: Colors.grey[600],
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Drop-off in 20 mins',
                            style: TextStyle(
                              fontSize: 12,
                              color: CityTheme.cityblue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Icon(Icons.bolt, color: Colors.orange[300]),
                  Image.asset(
                    IconsAssets.vip_car,
                    height: 60,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Estimated Time:',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                  ),
                  Text(
                    '20 mins',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: CityTheme.cityblue,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: CityTheme.elementSpacing),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Stack(
            children: [
              Positioned(
                left: 10,
                top: 20,
                bottom: 25,
                child: Container(
                  width: 2.5,
                  color: Colors.grey[400],
                  height: 80,
                ),
              ),
              Column(
                children: [
                  Row(
                    children: [
                      Icon(CupertinoIcons.circle_fill, color: CityTheme.cityblue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SizedBox(
                          height: 45,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Woji, Port Harcourt, Nigeria',
                              maxLines: 2,
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.5,
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: CityTheme.elementSpacing),
                  Row(
                    children: [
                      Icon(CupertinoIcons.placemark_fill, color: CityTheme.cityblue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SizedBox(
                          height: 45,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '25, Patterson Trans-Amadi Okujagu, Port Harcourt Nigeria',
                              maxLines: 2,
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.5,
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
