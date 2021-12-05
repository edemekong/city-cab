import 'package:citycab/pages/auth/auth_state.dart';
import 'package:citycab/ui/widget/textfields/phone_textfield.dart';
import 'package:citycab/utils/images_assets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PhonePage extends StatelessWidget {
  const PhonePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AuthState>(context);
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration:
                    BoxDecoration(image: DecorationImage(image: AssetImage(ImagesAsset.cabBg), fit: BoxFit.cover)),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  PhoneTextField(numnberController: state.phoneController),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
