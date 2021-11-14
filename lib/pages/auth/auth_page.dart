import 'package:citycab/pages/auth/auth_state.dart';
import 'package:citycab/pages/auth/widgets/auth_button.dart';
import 'package:citycab/pages/auth/widgets/otp_page.dart';
import 'package:citycab/pages/auth/widgets/phone_page.dart';
import 'package:citycab/pages/auth/widgets/set_up_account.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthPage extends StatefulWidget {
  final int page;
  final String? uid;
  const AuthPage({
    Key? key,
    this.page = 0,
    this.uid,
  }) : super(key: key);

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AuthState>(context);
    final screenSize = MediaQuery.of(context).size;
    return Builder(builder: (context) {
      return Stack(
        children: [
          Container(
            height: screenSize.height,
            width: screenSize.width,
            color: Colors.white,
            child: PageView(
              controller: state.controller,
              onPageChanged: state.onPageChanged,
              physics: NeverScrollableScrollPhysics(),
              children: [
                PhonePage(),
                OtpPage(),
                SetUpAccount(),
              ],
            ),
          ),
          AuthButton(),
        ],
      );
    });
  }
}

class AuthPageWidget extends StatelessWidget {
  final int page;
  final String? uid;

  const AuthPageWidget({
    Key? key,
    required this.page,
    this.uid,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = AuthState(page, uid ?? '');
    return ChangeNotifierProvider(
      create: (_) => state,
      child: ChangeNotifierProvider.value(
        value: state,
        child: AuthPage(page: page, uid: uid),
      ),
    );
  }
}
