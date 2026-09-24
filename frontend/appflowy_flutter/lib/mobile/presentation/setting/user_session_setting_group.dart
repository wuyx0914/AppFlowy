import 'package:appflowy/generated/flowy_svgs.g.dart';
import 'package:appflowy/mobile/presentation/bottom_sheet/bottom_sheet.dart';
import 'package:appflowy/mobile/presentation/widgets/show_flowy_mobile_confirm_dialog.dart';
import 'package:appflowy/startup/startup.dart';
import 'package:appflowy/user/application/auth/auth_service.dart';
import 'package:appflowy_backend/protobuf/flowy-user/protobuf.dart';
import 'package:appflowy_ui/appflowy_ui.dart';
import 'package:flowy_infra_ui/flowy_infra_ui.dart';
import 'package:flutter/material.dart';

class UserSessionSettingGroup extends StatelessWidget {
  const UserSessionSettingGroup({
    super.key,
    required this.userProfile,
    required this.showThirdPartyLogin,
  });

  final UserProfilePB userProfile;
  final bool showThirdPartyLogin;

  @override
  Widget build(BuildContext context) {
    final theme = AppFlowyTheme.of(context);
    // Local-only build: no third-party sign-in and no account deletion.
    return Column(
      children: [
        // logout button
        MobileLogoutButton(
          text: '登出',
          onPressed: () async => _showLogoutDialog(),
        ),

        VSpace(theme.spacing.xxl),
      ],
    );
  }

  Future<void> _showLogoutDialog() async {
    return showFlowyCupertinoConfirmDialog(
      title: '您确定要登出吗？',
      leftButton: FlowyText(
        '取消',
        fontSize: 17.0,
        figmaLineHeight: 24.0,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF007AFF),
      ),
      rightButton: FlowyText(
        '退出',
        fontSize: 17.0,
        figmaLineHeight: 24.0,
        fontWeight: FontWeight.w400,
        color: const Color(0xFFFE0220),
      ),
      onRightButtonPressed: (context) async {
        Navigator.of(context).pop();
        await getIt<AuthService>().signOut();
        await runAppFlowy();
      },
    );
  }
}
