import 'package:appflowy/user/application/sign_in_bloc.dart';
import 'package:appflowy/user/presentation/screens/sign_in_screen/widgets/continue_with/continue_with_email.dart';
import 'package:appflowy/user/presentation/screens/sign_in_screen/widgets/continue_with/continue_with_password.dart';
import 'package:appflowy/user/presentation/screens/sign_in_screen/widgets/continue_with/continue_with_password_page.dart';
import 'package:appflowy_ui/appflowy_ui.dart';
import 'package:flowy_infra_ui/flowy_infra_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:string_validator/string_validator.dart';

class ContinueWithEmailAndPassword extends StatefulWidget {
  const ContinueWithEmailAndPassword({super.key});

  @override
  State<ContinueWithEmailAndPassword> createState() =>
      _ContinueWithEmailAndPasswordState();
}

class _ContinueWithEmailAndPasswordState
    extends State<ContinueWithEmailAndPassword> {
  final controller = TextEditingController();
  final focusNode = FocusNode();
  final emailKey = GlobalKey<AFTextFieldState>();

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppFlowyTheme.of(context);

    return BlocListener<SignInBloc, SignInState>(
      listener: (context, state) {
        final successOrFail = state.successOrFail;
        // only push the continue with magic link or passcode page if the magic link is sent successfully
        if (successOrFail != null) {
          successOrFail.fold(
            (_) => emailKey.currentState?.clearError(),
            (error) => emailKey.currentState?.syncError(
              errorText: error.msg,
            ),
          );
        } else if (successOrFail == null && !state.isSubmitting) {
          emailKey.currentState?.clearError();
        }
      },
      child: Column(
        children: [
          AFTextField(
            key: emailKey,
            controller: controller,
            hintText: '请输入邮箱地址',
            onSubmitted: (value) => _signInWithEmail(
              context,
              value,
            ),
          ),
          VSpace(theme.spacing.l),
          ContinueWithEmail(
            onTap: () => _signInWithEmail(
              context,
              controller.text,
            ),
          ),
          VSpace(theme.spacing.l),
          ContinueWithPassword(
            onTap: () {
              final email = controller.text;

              if (!isEmail(email)) {
                emailKey.currentState?.syncError(
                  errorText: '请输入一个有效的邮箱地址',
                );
                return;
              }

              _pushContinueWithPasswordPage(
                context,
                email,
              );
            },
          ),
        ],
      ),
    );
  }

  void _signInWithEmail(BuildContext context, String email) {
    if (!isEmail(email)) {
      emailKey.currentState?.syncError(
        errorText: '请输入一个有效的邮箱地址',
      );
      return;
    }

    // Local-only build: magic-link sign-in requires cloud services.
    _pushContinueWithPasswordPage(context, email);
  }

  void _pushContinueWithPasswordPage(
    BuildContext context,
    String email,
  ) {
    final signInBloc = context.read<SignInBloc>();
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: '/continue-with-password'),
        builder: (context) => BlocProvider.value(
          value: signInBloc,
          child: ContinueWithPasswordPage(
            email: email,
            backToLogin: () {
              emailKey.currentState?.clearError();
              Navigator.pop(context);
            },
            onEnterPassword: (password) => signInBloc.add(
              SignInEvent.signInWithEmailAndPassword(
                email: email,
                password: password,
              ),
            ),
            onForgotPassword: () {
              // todo: implement forgot password
            },
          ),
        ),
      ),
    );
  }
}
