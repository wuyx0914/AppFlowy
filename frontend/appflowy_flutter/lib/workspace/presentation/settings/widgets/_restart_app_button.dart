import 'package:appflowy/user/presentation/screens/sign_in_screen/widgets/sign_in_or_logout_button.dart';
import 'package:flowy_infra_ui/flowy_infra_ui.dart';
import 'package:flutter/material.dart';
import 'package:universal_platform/universal_platform.dart';

class RestartButton extends StatelessWidget {
  const RestartButton({
    super.key,
    required this.showRestartHint,
    required this.onClick,
  });

  final bool showRestartHint;
  final VoidCallback onClick;

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [_buildRestartButton(context)];
    if (showRestartHint) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: FlowyText(
            '重新启动应用程序以使更改生效。请注意，这可能会注销您当前的帐户',
            maxLines: null,
          ),
        ),
      );
    }

    return Column(children: children);
  }

  Widget _buildRestartButton(BuildContext context) {
    if (UniversalPlatform.isDesktopOrWeb) {
      return Row(
        children: [
          SizedBox(
            height: 42,
            child: PrimaryRoundedButton(
              text: '重启',
              margin: const EdgeInsets.symmetric(horizontal: 24),
              fontWeight: FontWeight.w600,
              radius: 12.0,
              onTap: onClick,
            ),
          ),
        ],
      );
      // Row(
      //   children: [
      //     FlowyButton(
      //       isSelected: true,
      //       useIntrinsicWidth: true,
      //       margin: const EdgeInsets.symmetric(
      //         horizontal: 30,
      //         vertical: 10,
      //       ),
      //       text: FlowyText(
      //         '重启',
      //       ),
      //       onTap: onClick,
      //     ),
      //     const Spacer(),
      //   ],
      // );
    } else {
      return MobileLogoutButton(
        text: '重启',
        onPressed: onClick,
      );
    }
  }
}
