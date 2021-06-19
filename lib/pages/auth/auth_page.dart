import 'package:citycab/pages/auth/bloc/auth_bloc.dart';
import 'package:citycab/pages/auth/widgets/otp_page.dart';
import 'package:citycab/pages/auth/widgets/phone_page.dart';
import 'package:citycab/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  PageController _controller = PageController();

  @override
  void initState() {
    super.initState();
  }

  TextEditingController _phoneController = TextEditingController();
  TextEditingController _otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return BlocConsumer<AuthBloc, AuthState>(
        bloc: context.watch<AuthBloc>(),
        listener: (_, state) {
          if (state is LoggedInState) {
            _controller.animateToPage(2, duration: Duration(milliseconds: 400), curve: Curves.easeIn);
          }
        },
        builder: (context, state) {
          print('build $state');
          return Stack(
            children: [
              Container(
                height: screenSize.height,
                width: screenSize.width,
                color: Colors.white,
                child: PageView(
                  controller: _controller,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    PhonePage(numnberController: _phoneController),
                    OtpPage(
                      otpController: _otpController,
                      bloc: context.watch<AuthBloc>(),
                      phoneNumber: _phoneController.text,
                    ),
                    //Create acount or if user already exit navigate to home
                    Container(
                      child: Center(
                        child: Text(
                          state is LoggedInState ? 'Welcome User with UID\n ${state.uid}' : '',
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildFloatActionButton(state, context)
            ],
          );
        });
  }

  Positioned _buildFloatActionButton(AuthState state, BuildContext context) {
    return Positioned(
      bottom: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FloatingActionButton(
          backgroundColor: state is LoadingAuthState ? Colors.grey[300] : CityTheme.cityblue,
          child: Icon(Icons.arrow_forward_ios),
          onPressed: state is LoadingAuthState
              ? null
              : () {
                  if (_phoneController.text.isNotEmpty && state is AuthInitialState) {
                    BlocProvider.of<AuthBloc>(context)
                        .add(PhoneNumberVerificationEvent('+234${_phoneController.text}'));
                    _controller.animateToPage(1, duration: Duration(milliseconds: 400), curve: Curves.easeIn);
                  } else if (state is CodeSentState) {
                    BlocProvider.of<AuthBloc>(context).add(PhoneAuthCodeVerifiedEvent(
                        _otpController.text, state.verificationId, '+234${_phoneController.text}'));
                  }
                },
        ),
      ),
    );
  }
}
