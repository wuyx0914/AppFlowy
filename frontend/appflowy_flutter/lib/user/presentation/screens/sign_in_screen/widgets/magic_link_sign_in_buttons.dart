import 'package:appflowy/user/application/sign_in_bloc.dart';
import 'package:appflowy/workspace/presentation/widgets/dialogs.dart';
import 'package:flowy_infra/size.dart';
import 'package:flowy_infra_ui/flowy_infra_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:string_validator/string_validator.dart';
import 'package:universal_platform/universal_platform.dart';

class SignInWithMagicLinkButtons extends StatefulWidget {
  const SignInWithMagicLinkButtons({super.key});

  @override
  State<SignInWithMagicLinkButtons> createState() =>
      _SignInWithMagicLinkButtonsState();
}

class _SignInWithMagicLinkButtonsState
    extends State<SignInWithMagicLinkButtons> {
  final controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: UniversalPlatform.isMobile ? 38.0 : 48.0,
          child: FlowyTextField(
            autoFocus: false,
            focusNode: _focusNode,
            controller: controller,
            borderRadius: BorderRadius.circular(4.0),
            hintText: '请输入邮箱地址',
            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 14.0,
                  color: Theme.of(context).hintColor,
                ),
            textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 14.0,
                ),
            keyboardType: TextInputType.emailAddress,
            onSubmitted: (_) => _sendMagicLink(context, controller.text),
            onTapOutside: (_) => _focusNode.unfocus(),
          ),
        ),
        const VSpace(12),
        _ConfirmButton(
          onTap: () => _sendMagicLink(context, controller.text),
        ),
      ],
    );
  }

  void _sendMagicLink(BuildContext context, String email) {
    if (!isEmail(email)) {
      showToastNotification(
        message: '请输入一个有效的邮箱地址',
        type: ToastificationType.error,
      );
      return;
    }

    context
        .read<SignInBloc>()
        .add(SignInEvent.signInWithMagicLink(email: email));

    showConfirmDialog(
      context: context,
      title: '魔法链接已经发送到您的邮箱，请检查！',
      description: '一个验证链接已发送到您的电子邮箱。点击该链接即可完成登录。该链接将在 5 分钟后失效。',
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  const _ConfirmButton({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignInBloc, SignInState>(
      builder: (context, state) {
        final name = switch (state.loginType) {
          LoginType.signIn => '使用魔法链接登录',
          LoginType.signUp => '使用魔法链接注册',
        };
        if (UniversalPlatform.isMobile) {
          return ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 32),
              maximumSize: const Size(double.infinity, 38),
            ),
            onPressed: onTap,
            child: FlowyText(
              name,
              fontSize: 14,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          );
        } else {
          return SizedBox(
            height: 48,
            child: FlowyButton(
              isSelected: true,
              onTap: onTap,
              hoverColor: Theme.of(context).colorScheme.primary,
              text: FlowyText.medium(
                name,
                textAlign: TextAlign.center,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              radius: Corners.s6Border,
            ),
          );
        }
      },
    );
  }
}
