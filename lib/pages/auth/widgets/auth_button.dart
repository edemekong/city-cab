import 'package:citycab/pages/auth/auth_state.dart';
import 'package:citycab/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthButton extends StatelessWidget {
  const AuthButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthState>();
    return Positioned(
      bottom: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FloatingActionButton(
          backgroundColor:
              state.phoneAuthState == PhoneAuthState.loading || state.phoneAuthState == PhoneAuthState.codeSent
                  ? Colors.grey[300]
                  : CityTheme.cityblue,
          child: Icon(state.pageIndex == 2 ? Icons.check_rounded : Icons.arrow_forward_ios),
          onPressed: state.phoneAuthState == PhoneAuthState.loading
              ? null
              : () {
                  if (state.phoneController.text.isNotEmpty &&
                      state.phoneAuthState == PhoneAuthState.initial &&
                      state.pageIndex == 0) {
                    state.phoneNumberVerification("+234${state.phoneController.text}");
                  } else if (state.phoneAuthState == PhoneAuthState.codeSent && state.pageIndex == 1) {
                    state.verifyAndLogin(state.verificationId, state.otpController.text, state.phoneController.text);
                  } else if (state.pageIndex == 2) {
                    state.signUp();
                  }
                },
        ),
      ),
    );
  }
}
