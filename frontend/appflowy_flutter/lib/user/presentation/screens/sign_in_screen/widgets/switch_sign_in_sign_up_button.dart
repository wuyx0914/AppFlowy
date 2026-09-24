import 'package:appflowy/user/application/sign_in_bloc.dart';
import 'package:flowy_infra_ui/flowy_infra_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SwitchSignInSignUpButton extends StatelessWidget {
  const SwitchSignInSignUpButton({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignInBloc, SignInState>(
      builder: (context, state) {
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: onTap,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FlowyText(
                  switch (state.loginType) {
                    LoginType.signIn =>
                      '没有账户?',
                    LoginType.signUp =>
                      '已经有账户了？',
                  },
                  fontSize: 12,
                ),
                const HSpace(4),
                FlowyText(
                  switch (state.loginType) {
                    LoginType.signIn => '新建账户',
                    LoginType.signUp => '登陆',
                  },
                  color: Colors.blue,
                  fontSize: 12,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
