import 'dart:async';

import 'package:citycab/pages/auth/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../../../ui/theme.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({
    Key key,
    TextEditingController otpController,
    this.bloc,
    this.phoneNumber,
  })  : _otpController = otpController,
        super(key: key);

  final TextEditingController _otpController;
  final AuthBloc bloc;
  final String phoneNumber;

  @override
  _OtpPageState createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  int count = 30;
  @override
  void initState() {
    super.initState();
  }

  void _startCountDown() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (timer.tick > 30) {
        timer.cancel();
      } else {
        setState(() {
          --count;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (_, state) {
        if (state is CodeSentState) {
          _startCountDown();
        }
      },
      builder: (context, state) {
        return Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: kToolbarHeight * 0.6),
                Text(
                  'Enter Code',
                  style: Theme.of(context).textTheme.headline5,
                ).paddingBottom(CityTheme.elementSpacing),
                Text(
                  'A 6 digit code has been sent to',
                  style: Theme.of(context).textTheme.bodyText1,
                ).paddingBottom(8),
                Text(
                  '+234 ${widget.phoneNumber}',
                  style: Theme.of(context).textTheme.headline6.copyWith(fontWeight: FontWeight.bold),
                ).paddingBottom(CityTheme.elementSpacing),
                PinFieldAutoFill(
                  controller: widget._otpController,
                  decoration: BoxLooseDecoration(
                    textStyle: TextStyle(fontSize: 20, color: Colors.black),
                    strokeColorBuilder: FixedColorBuilder(Colors.grey),
                  ),
                  currentCode: '',
                  onCodeSubmitted: (code) {},
                  onCodeChanged: (code) {
                    if (code.length == 6) {
                      FocusScope.of(context).requestFocus(FocusNode());
                    }
                  },
                ),
                Spacer(),
                state is LoadingAuthState
                    ? Text(
                        'Verifying...',
                        style: Theme.of(context).textTheme.bodyText1.copyWith(fontWeight: FontWeight.w400),
                      ).paddingBottom(8)
                    : SizedBox.shrink(),
                state is CodeSentState
                    ? Row(
                        children: [
                          Text(
                            'Resend code in ',
                            style: Theme.of(context).textTheme.bodyText1.copyWith(fontWeight: FontWeight.w400),
                          ),
                          Text(
                            '0:$count',
                            style: Theme.of(context).textTheme.subtitle1.copyWith(fontWeight: FontWeight.bold),
                          )
                        ],
                      ).paddingBottom(8)
                    : SizedBox.shrink(),
              ],
            ),
          ),
        );
      },
    );
  }
}
