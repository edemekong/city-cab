import 'package:citycab/ui/widget/textfields/phone_textfield.dart';
import 'package:citycab/utils/images_assets.dart';
import 'package:flutter/material.dart';

class PhonePage extends StatelessWidget {
  const PhonePage({
    Key? key,
    required TextEditingController numnberController,
  })  : _numnberController = numnberController,
        super(key: key);

  final TextEditingController _numnberController;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(image: AssetImage(ImagesAsset.cabBg), fit: BoxFit.fitWidth))),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  PhoneTextField(numnberController: _numnberController),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
