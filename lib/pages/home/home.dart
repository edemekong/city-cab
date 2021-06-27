import 'package:citycab/models/user.dart';
import 'package:citycab/pages/auth/auth_page.dart';
import 'package:citycab/repositories/user_repository.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: ValueListenableBuilder<User?>(
        valueListenable: UserRepository.instance.userNotifier,
        builder: (context, value, child) {
          if (value != null && value.email != null) {
            return Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
              child: Center(child: Text('Successfully Logged In')),
            );
          } else if (value?.email == null) {
            return AuthPage(page: 2, uid: value!.uid);
          }
          return AuthPage();
        },
      ),
    );
  }
}
