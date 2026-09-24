import 'package:appflowy/generated/flowy_svgs.g.dart';
import 'package:appflowy/user/application/password/password_bloc.dart';
import 'package:appflowy/workspace/presentation/settings/pages/account/password/error_extensions.dart';
import 'package:appflowy/workspace/presentation/settings/pages/account/password/password_suffix_icon.dart';
import 'package:appflowy/workspace/presentation/widgets/dialogs.dart';
import 'package:appflowy_backend/protobuf/flowy-error/code.pbenum.dart';
import 'package:appflowy_backend/protobuf/flowy-user/user_profile.pb.dart';
import 'package:appflowy_ui/appflowy_ui.dart';
import 'package:flowy_infra_ui/flowy_infra_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChangePasswordDialogContent extends StatefulWidget {
  const ChangePasswordDialogContent({
    super.key,
    required this.userProfile,
    this.showTitle = true,
    this.showCloseAndSaveButton = true,
    this.showSaveButton = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
  });

  final UserProfilePB userProfile;

  // display the title
  final bool showTitle;

  // display the desktop style close and save button
  final bool showCloseAndSaveButton;

  // display the mobile style save button
  final bool showSaveButton;

  final EdgeInsets padding;

  @override
  State<ChangePasswordDialogContent> createState() =>
      _ChangePasswordDialogContentState();
}

class _ChangePasswordDialogContentState
    extends State<ChangePasswordDialogContent> {
  final currentPasswordTextFieldKey = GlobalKey<AFTextFieldState>();
  final newPasswordTextFieldKey = GlobalKey<AFTextFieldState>();
  final confirmPasswordTextFieldKey = GlobalKey<AFTextFieldState>();

  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final iconSize = 20.0;

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppFlowyTheme.of(context);
    return BlocListener<PasswordBloc, PasswordState>(
      listener: _onPasswordStateChanged,
      child: Container(
        padding: widget.padding,
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(theme.borderRadius.xl),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.showTitle) ...[
              _buildTitle(context),
              VSpace(theme.spacing.xl),
            ],
            ..._buildCurrentPasswordFields(context),
            VSpace(theme.spacing.xl),
            ..._buildNewPasswordFields(context),
            VSpace(theme.spacing.xl),
            ..._buildConfirmPasswordFields(context),
            VSpace(theme.spacing.xl),
            if (widget.showCloseAndSaveButton) ...[
              _buildSubmitButton(context),
            ],
            if (widget.showSaveButton) ...[
              _buildSaveButton(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    final theme = AppFlowyTheme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '变更密码',
          style: theme.textStyle.heading4.prominent(
            color: theme.textColorScheme.primary,
          ),
        ),
        const Spacer(),
        AFGhostButton.normal(
          size: AFButtonSize.s,
          padding: EdgeInsets.all(theme.spacing.xs),
          onTap: () => Navigator.of(context).pop(),
          builder: (context, isHovering, disabled) => FlowySvg(
            FlowySvgs.password_close_m,
            size: const Size.square(20),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildCurrentPasswordFields(BuildContext context) {
    final theme = AppFlowyTheme.of(context);
    return [
      Text(
        '目前密码',
        style: theme.textStyle.caption.enhanced(
          color: theme.textColorScheme.secondary,
        ),
      ),
      VSpace(theme.spacing.xs),
      AFTextField(
        key: currentPasswordTextFieldKey,
        controller: currentPasswordController,
        hintText: '输入您的目前密码',
        keyboardType: TextInputType.visiblePassword,
        obscureText: true,
        autofillHints: const [AutofillHints.password],
        suffixIconConstraints: BoxConstraints.tightFor(
          width: iconSize + theme.spacing.m,
          height: iconSize,
        ),
        suffixIconBuilder: (context, isObscured) => PasswordSuffixIcon(
          isObscured: isObscured,
          onTap: () {
            currentPasswordTextFieldKey.currentState?.syncObscured(!isObscured);
          },
        ),
      ),
    ];
  }

  List<Widget> _buildNewPasswordFields(BuildContext context) {
    final theme = AppFlowyTheme.of(context);
    return [
      Text(
        '新密码',
        style: theme.textStyle.caption.enhanced(
          color: theme.textColorScheme.secondary,
        ),
      ),
      VSpace(theme.spacing.xs),
      AFTextField(
        key: newPasswordTextFieldKey,
        controller: newPasswordController,
        hintText: '输入您的新密码',
        keyboardType: TextInputType.visiblePassword,
        obscureText: true,
        autofillHints: const [AutofillHints.password],
        suffixIconConstraints: BoxConstraints.tightFor(
          width: iconSize + theme.spacing.m,
          height: iconSize,
        ),
        suffixIconBuilder: (context, isObscured) => PasswordSuffixIcon(
          isObscured: isObscured,
          onTap: () {
            newPasswordTextFieldKey.currentState?.syncObscured(!isObscured);
          },
        ),
      ),
    ];
  }

  List<Widget> _buildConfirmPasswordFields(BuildContext context) {
    final theme = AppFlowyTheme.of(context);
    return [
      Text(
        '确认新密码',
        style: theme.textStyle.caption.enhanced(
          color: theme.textColorScheme.secondary,
        ),
      ),
      VSpace(theme.spacing.xs),
      AFTextField(
        key: confirmPasswordTextFieldKey,
        controller: confirmPasswordController,
        hintText: '确认您的新密码',
        keyboardType: TextInputType.visiblePassword,
        obscureText: true,
        autofillHints: const [AutofillHints.password],
        suffixIconConstraints: BoxConstraints.tightFor(
          width: iconSize + theme.spacing.m,
          height: iconSize,
        ),
        suffixIconBuilder: (context, isObscured) => PasswordSuffixIcon(
          isObscured: isObscured,
          onTap: () {
            confirmPasswordTextFieldKey.currentState?.syncObscured(!isObscured);
          },
        ),
      ),
    ];
  }

  Widget _buildSubmitButton(BuildContext context) {
    final theme = AppFlowyTheme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AFOutlinedTextButton.normal(
          text: '取消',
          textStyle: theme.textStyle.body.standard(
            color: theme.textColorScheme.primary,
            weight: FontWeight.w400,
          ),
          onTap: () => Navigator.of(context).pop(),
        ),
        HSpace(theme.spacing.l),
        AFFilledTextButton.primary(
          text: '保存',
          textStyle: theme.textStyle.body.standard(
            color: theme.textColorScheme.onFill,
            weight: FontWeight.w400,
          ),
          onTap: () => _save(context),
        ),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    final theme = AppFlowyTheme.of(context);
    return AFFilledTextButton.primary(
      text: '保存',
      textStyle: theme.textStyle.body.standard(
        color: theme.textColorScheme.onFill,
      ),
      size: AFButtonSize.l,
      alignment: Alignment.center,
      onTap: () => _save(context),
    );
  }

  void _save(BuildContext context) async {
    _resetError();

    final currentPassword = currentPasswordController.text;
    final newPassword = newPasswordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (currentPassword.isEmpty) {
      currentPasswordTextFieldKey.currentState?.syncError(
        errorText: '需要目前的密码',
      );
      return;
    }

    if (newPassword.isEmpty) {
      newPasswordTextFieldKey.currentState?.syncError(
        errorText: '需要新密码',
      );
      return;
    }

    if (confirmPassword.isEmpty) {
      confirmPasswordTextFieldKey.currentState?.syncError(
        errorText: '确认需要输入密码',
      );
      return;
    }

    if (newPassword != confirmPassword) {
      confirmPasswordTextFieldKey.currentState?.syncError(
        errorText: '密码不相符',
      );
      return;
    }

    if (newPassword == currentPassword) {
      newPasswordTextFieldKey.currentState?.syncError(
        errorText: '新密码与目前密码相同',
      );
      return;
    }

    // all the verification passed, save the new password
    context.read<PasswordBloc>().add(
          PasswordEvent.changePassword(
            oldPassword: currentPassword,
            newPassword: newPassword,
          ),
        );
  }

  void _resetError() {
    currentPasswordTextFieldKey.currentState?.clearError();
    newPasswordTextFieldKey.currentState?.clearError();
    confirmPasswordTextFieldKey.currentState?.clearError();
  }

  void _onPasswordStateChanged(BuildContext context, PasswordState state) {
    bool hasError = false;
    String message = '';

    final changePasswordResult = state.changePasswordResult;
    final setPasswordResult = state.setupPasswordResult;

    if (changePasswordResult != null) {
      changePasswordResult.fold(
        (success) {
          message = '密码已成功更新';
        },
        (error) {
          hasError = true;
          message = '密码更新失败';

          if (AFPasswordErrorExtension.incorrectPasswordPattern
              .hasMatch(error.msg)) {
            currentPasswordTextFieldKey.currentState?.syncError(
              errorText: AFPasswordErrorExtension.getErrorMessage(error),
            );
          } else if (AFPasswordErrorExtension.tooShortPasswordPattern
              .hasMatch(error.msg)) {
            newPasswordTextFieldKey.currentState?.syncError(
              errorText: AFPasswordErrorExtension.getErrorMessage(error),
            );
          } else if (AFPasswordErrorExtension.tooLongPasswordPattern
              .hasMatch(error.msg)) {
            newPasswordTextFieldKey.currentState?.syncError(
              errorText: AFPasswordErrorExtension.getErrorMessage(error),
            );
          } else if (error.code == ErrorCode.NewPasswordTooWeak) {
            newPasswordTextFieldKey.currentState?.syncError(
              errorText: '密码必须包含至少一个字母、一个数字和一个符号。',
            );
          } else {
            newPasswordTextFieldKey.currentState?.syncError(
              errorText: error.msg,
            );
          }
        },
      );
    } else if (setPasswordResult != null) {
      setPasswordResult.fold(
        (success) {
          message = '密码设置成功';
        },
        (error) {
          hasError = true;
        },
      );
    }

    if (!state.isSubmitting && message.isNotEmpty) {
      if (!hasError) {
        showToastNotification(
          message: message,
        );
        Navigator.of(context).pop();
      }
    }
  }
}
