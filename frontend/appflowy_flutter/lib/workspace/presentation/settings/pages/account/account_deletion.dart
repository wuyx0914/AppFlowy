import 'package:appflowy/generated/flowy_svgs.g.dart';
import 'package:appflowy/shared/loading.dart';
import 'package:appflowy/startup/startup.dart';
import 'package:appflowy/user/application/user_service.dart';
import 'package:appflowy/util/navigator_context_extension.dart';
import 'package:appflowy/workspace/presentation/home/menu/sidebar/space/shared_widget.dart';
import 'package:appflowy/workspace/presentation/widgets/dialogs.dart';
import 'package:appflowy_backend/log.dart';
import 'package:appflowy_result/appflowy_result.dart';
import 'package:appflowy_ui/appflowy_ui.dart';
import 'package:flowy_infra_ui/flowy_infra_ui.dart';
import 'package:flutter/material.dart';
import 'package:universal_platform/universal_platform.dart';

const _acceptableConfirmTexts = [
  'delete my account',
  'deletemyaccount',
  'DELETE MY ACCOUNT',
  'DELETEMYACCOUNT',
];

class AccountDeletionButton extends StatefulWidget {
  const AccountDeletionButton({
    super.key,
  });

  @override
  State<AccountDeletionButton> createState() => _AccountDeletionButtonState();
}

class _AccountDeletionButtonState extends State<AccountDeletionButton> {
  final textEditingController = TextEditingController();
  final isCheckedNotifier = ValueNotifier(false);

  @override
  void dispose() {
    textEditingController.dispose();
    isCheckedNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppFlowyTheme.of(context);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '删除账户',
                style: theme.textStyle.heading4.enhanced(
                  color: theme.textColorScheme.primary,
                ),
              ),
              const VSpace(4),
              Text(
                '永久删除你的账户，并移除所有工作区的访问权限。',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textStyle.caption.standard(
                  color: theme.textColorScheme.secondary,
                ),
              ),
            ],
          ),
        ),
        AFOutlinedTextButton.destructive(
          text: '删除账户',
          textStyle: theme.textStyle.body.standard(
            color: theme.textColorScheme.error,
            weight: FontWeight.w400,
          ),
          onTap: () {
            isCheckedNotifier.value = false;
            textEditingController.clear();

            showCancelAndDeleteDialog(
              context: context,
              title: '删除帐户',
              description: '',
              builder: (_) => _AccountDeletionDialog(
                controller: textEditingController,
                isChecked: isCheckedNotifier,
              ),
              onDelete: () => deleteMyAccount(
                context,
                textEditingController.text.trim(),
                isCheckedNotifier.value,
                onSuccess: () {
                  context.popToHome();
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class _AccountDeletionDialog extends StatelessWidget {
  const _AccountDeletionDialog({
    required this.controller,
    required this.isChecked,
  });

  final TextEditingController controller;
  final ValueNotifier<bool> isChecked;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        FlowyText.regular(
          '请输入 "删除我的账户" 以确认。',
          fontSize: 14.0,
          figmaLineHeight: 18.0,
          maxLines: 2,
          color: ConfirmPopupColor.descriptionColor(context),
        ),
        const VSpace(12.0),
        FlowyTextField(
          hintText:
              '删除我的账户',
          controller: controller,
        ),
        const VSpace(16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => isChecked.value = !isChecked.value,
              child: ValueListenableBuilder<bool>(
                valueListenable: isChecked,
                builder: (context, isChecked, _) {
                  return FlowySvg(
                    isChecked ? FlowySvgs.check_filled_s : FlowySvgs.uncheck_s,
                    size: const Size.square(16.0),
                    blendMode: isChecked ? null : BlendMode.srcIn,
                  );
                },
              ),
            ),
            const HSpace(6.0),
            Expanded(
              child: FlowyText.regular(
                '我理解此操作是不可逆的，并且将永久删除我的帐户和所有关联数据。',
                fontSize: 14.0,
                figmaLineHeight: 16.0,
                maxLines: 3,
                color: ConfirmPopupColor.descriptionColor(context),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

bool _isConfirmTextValid(String text) {
  // don't convert the text to lower case or upper case,
  //  just check if the text is in the list
  return _acceptableConfirmTexts.contains(text) ||
      text == '删除我的账户';
}

Future<void> deleteMyAccount(
  BuildContext context,
  String confirmText,
  bool isChecked, {
  VoidCallback? onSuccess,
  VoidCallback? onFailure,
}) async {
  final bottomPadding = UniversalPlatform.isMobile
      ? MediaQuery.of(context).viewInsets.bottom
      : 0.0;

  if (!isChecked) {
    showToastNotification(
      type: ToastificationType.warning,
      bottomPadding: bottomPadding,
      message: '你必须勾选以确认删除。',
    );
    return;
  }
  if (!context.mounted) {
    return;
  }

  if (confirmText.isEmpty || !_isConfirmTextValid(confirmText)) {
    showToastNotification(
      type: ToastificationType.warning,
      bottomPadding: bottomPadding,
      message: '你的确认文本不匹配 "删除我的账户"',
    );
    return;
  }

  final loading = Loading(context)..start();

  await UserBackendService.deleteCurrentAccount().fold(
    (s) {
      Log.info('account deletion success');

      loading.stop();
      showToastNotification(
        message: '账户删除成功',
      );

      // delay 1 second to make sure the toast notification is shown
      Future.delayed(const Duration(seconds: 1), () async {
        onSuccess?.call();

        // restart the application
        await runAppFlowy();
      });
    },
    (f) {
      Log.error('account deletion failed, error: $f');

      loading.stop();
      showToastNotification(
        type: ToastificationType.error,
        bottomPadding: bottomPadding,
        message: f.msg,
      );

      onFailure?.call();
    },
  );
}
