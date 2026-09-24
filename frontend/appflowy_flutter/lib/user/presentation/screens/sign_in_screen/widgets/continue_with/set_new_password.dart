import 'package:appflowy/user/application/sign_in_bloc.dart';
import 'package:appflowy/user/presentation/screens/sign_in_screen/widgets/continue_with/back_to_login_in_button.dart';
import 'package:appflowy/user/presentation/screens/sign_in_screen/widgets/continue_with/continue_with_button.dart';
import 'package:appflowy/user/presentation/screens/sign_in_screen/widgets/continue_with/title_logo.dart';
import 'package:appflowy/user/presentation/screens/sign_in_screen/widgets/continue_with/verifying_button.dart';
import 'package:appflowy/workspace/presentation/widgets/dialogs.dart';
import 'package:appflowy_backend/protobuf/flowy-error/code.pbenum.dart';
import 'package:appflowy_ui/appflowy_ui.dart';
import 'package:flowy_infra_ui/widget/spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SetNewPasswordWidget extends StatefulWidget {
  const SetNewPasswordWidget({
    super.key,
    required this.backToLogin,
    required this.email,
  });

  final String email;
  final VoidCallback backToLogin;

  @override
  State<SetNewPasswordWidget> createState() => _SetNewPasswordWidgetState();
}

class _SetNewPasswordWidgetState extends State<SetNewPasswordWidget> {
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final newPasswordKey = GlobalKey<AFTextFieldState>();
  final confirmPasswordKey = GlobalKey<AFTextFieldState>();

  bool isSubmitting = false;

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppFlowyTheme.of(context);
    final spacing = theme.spacing.xxl;
    return BlocConsumer<SignInBloc, SignInState>(
      listener: (context, state) {
        final successOrFail = state.resetPasswordSuccessOrFail;
        if (successOrFail != null) {
          successOrFail.fold(
            (success) {
              showToastNotification(
                message: '密码已成功重设',
              );
              // pop until the login screen is found
              Navigator.popUntil(context, (route) {
                return route.settings.name == '/continue-with-password';
              });
            },
            (error) {
              if (error.code == ErrorCode.NewPasswordTooWeak) {
                newPasswordKey.currentState?.syncError(
                  errorText: '密码必须包含至少一个字母、一个数字和一个符号。',
                );
              } else {
                newPasswordKey.currentState?.syncError(
                  errorText: error.msg,
                );
              }
            },
          );
        }
        // Handle state changes and validation results here
        if (state.isSubmitting != isSubmitting) {
          setState(() => isSubmitting = state.isSubmitting);
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLogoAndTitle(),
                  _buildPasswordFields(),
                  VSpace(spacing),
                  _buildResetButton(),
                  VSpace(spacing),
                  BackToLoginButton(
                    onTap: widget.backToLogin,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogoAndTitle() {
    final theme = AppFlowyTheme.of(context);
    return TitleLogo(
      title: '重设密码',
      informationBuilder: (context) => RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '输入新密码为',
              style: theme.textStyle.body.standard(
                color: theme.textColorScheme.primary,
              ),
            ),
            TextSpan(
              text: widget.email,
              style: theme.textStyle.body.enhanced(
                color: theme.textColorScheme.primary,
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildPasswordFields() {
    final theme = AppFlowyTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '新密码',
          style: theme.textStyle.caption.enhanced(
            color: theme.textColorScheme.secondary,
          ),
        ),
        const VSpace(8),
        AFTextField(
          key: newPasswordKey,
          controller: newPasswordController,
          obscureText: true,
          autofillHints: const [AutofillHints.password],
          hintText: '输入新密码',
          onSubmitted: (_) => _validateAndSubmit(),
        ),
        const VSpace(16),
        Text(
          '确认密码',
          style: theme.textStyle.caption.enhanced(
            color: theme.textColorScheme.secondary,
          ),
        ),
        const VSpace(8),
        AFTextField(
          key: confirmPasswordKey,
          controller: confirmPasswordController,
          obscureText: true,
          autofillHints: const [AutofillHints.password],
          hintText: '输入新密码',
          onSubmitted: (_) => _validateAndSubmit(),
        ),
      ],
    );
  }

  Widget _buildResetButton() {
    return isSubmitting
        ? const VerifyingButton()
        : ContinueWithButton(
            text: '重设密码',
            onTap: _validateAndSubmit,
          );
  }

  void _validateAndSubmit() {
    final newPassword = newPasswordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (newPassword.isEmpty) {
      newPasswordKey.currentState?.syncError(
        errorText: '新密码不能为空',
      );
      return;
    }

    if (confirmPassword.isEmpty) {
      confirmPasswordKey.currentState?.syncError(
        errorText: '确认密码不能为空',
      );
      return;
    }

    if (newPassword != confirmPassword) {
      confirmPasswordKey.currentState?.syncError(
        errorText: '密码不相符。请重新输入',
      );
      return;
    }

    // Add the reset password event to the bloc
    context.read<SignInBloc>().add(
          ResetPassword(
            email: widget.email,
            newPassword: newPassword,
          ),
        );
  }
}
