import 'package:citycab/pages/auth/bloc/auth_bloc.dart';
import 'package:citycab/pages/auth/widgets/otp_page.dart';
import 'package:citycab/pages/auth/widgets/phone_page.dart';
import 'package:citycab/ui/theme.dart';
import 'package:citycab/ui/widget/textfields/cab_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthPage extends StatefulWidget {
  final int? page;
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
  PageController? _controller;

  int _pageIndex = 0;

  @override
  void initState() {
    _controller = PageController(initialPage: widget.page!);
    super.initState();
  }

  TextEditingController _phoneController = TextEditingController();
  TextEditingController _otpController = TextEditingController();
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return BlocConsumer<AuthBloc, AuthState>(
        bloc: context.watch<AuthBloc>(),
        listener: (_, state) {
          if (state is LoggedInState) {
            _controller!.animateToPage(2, duration: Duration(milliseconds: 400), curve: Curves.easeIn);
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
                  onPageChanged: onPageChanged,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    PhonePage(numnberController: _phoneController),
                    OtpPage(
                      otpController: _otpController,
                      bloc: context.watch<AuthBloc>(),
                      phoneNumber: _phoneController.text,
                    ),
                    SetUpAccount(
                      firstnameController: _firstNameController,
                      lastnameController: _lastNameController,
                      emailController: _emailController,
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
          child: Icon(_pageIndex == 2 ? Icons.check_rounded : Icons.arrow_forward_ios),
          onPressed: state is LoadingAuthState
              ? null
              : () {
                  if (_phoneController.text.isNotEmpty && state is AuthInitialState && _pageIndex == 0) {
                    BlocProvider.of<AuthBloc>(context)
                        .add(PhoneNumberVerificationEvent('+234${_phoneController.text}'));
                    _controller!.animateToPage(1, duration: Duration(milliseconds: 400), curve: Curves.easeIn);
                  } else if (state is CodeSentState && _pageIndex == 1) {
                    BlocProvider.of<AuthBloc>(context).add(PhoneAuthCodeVerifiedEvent(
                        _otpController.text, state.verificationId, '+234${_phoneController.text}'));
                  } else if (_pageIndex == 2) {
                    BlocProvider.of<AuthBloc>(context).add(SignUpEvent(
                      _firstNameController.text,
                      _lastNameController.text,
                      _emailController.text,
                      state is LoggedInState ? state.uid : widget.uid,
                    ));
                  }
                },
        ),
      ),
    );
  }

  void onPageChanged(int value) {
    setState(() {
      _pageIndex = value;
    });
  }
}

class SetUpAccount extends StatelessWidget {
  final TextEditingController? firstnameController;
  final TextEditingController? lastnameController;
  final TextEditingController? emailController;

  const SetUpAccount({
    Key? key,
    this.firstnameController,
    this.lastnameController,
    this.emailController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: kToolbarHeight * 0.6),
            Text(
              'Set Up Account',
              style: Theme.of(context).textTheme.headline5,
            ).paddingBottom(CityTheme.elementSpacing / 2),
            Text(
              'Fill the details below...',
              style: Theme.of(context).textTheme.bodyText1,
            ).paddingBottom(CityTheme.elementSpacing),
            Row(
              children: [
                Expanded(
                  child: CityTextField(
                    label: 'First Name',
                    controller: firstnameController!,
                  ),
                ),
                SizedBox(width: CityTheme.elementSpacing),
                Expanded(
                  child: CityTextField(
                    label: 'Last Name',
                    controller: lastnameController!,
                  ),
                ),
              ],
            ).paddingBottom(CityTheme.elementSpacing),
            CityTextField(
              label: 'Email',
              controller: emailController!,
            ),
          ],
        ),
      ),
    );
  }
}
