import 'package:citycab/models/user.dart';
import 'package:citycab/pages/auth/auth_page.dart';
import 'package:citycab/repositories/user_repository.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: ValueListenableBuilder<User>(
        valueListenable: UserRepository.instance.userNotifier,
        builder: (context, value, child) {
          final v = value;
          if (v != null) {
            return value?.isVerified != null && v.isVerified == true
                ? Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.white,
                    child: Center(child: Text('Successfully Logged In \n\n${value.email}')),
                  )
                : AuthPage(page: 2, uid: value.uid);
          } else {
            print(v?.email);
            return AuthPage();
          }
        },
      ),
    );
  }
}
