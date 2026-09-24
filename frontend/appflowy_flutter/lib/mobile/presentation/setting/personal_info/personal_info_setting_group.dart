import 'package:appflowy/mobile/presentation/bottom_sheet/bottom_sheet.dart';
import 'package:appflowy/mobile/presentation/setting/widgets/mobile_setting_trailing.dart';
import 'package:appflowy/startup/startup.dart';
import 'package:appflowy/user/application/auth/auth_service.dart';
import 'package:appflowy/user/application/password/password_bloc.dart';
import 'package:appflowy/workspace/application/user/prelude.dart';
import 'package:appflowy/workspace/presentation/settings/pages/account/password/change_password.dart';
import 'package:appflowy/workspace/presentation/settings/pages/account/password/setup_password.dart';
import 'package:appflowy_backend/protobuf/flowy-user/protobuf.dart';
import 'package:appflowy_ui/appflowy_ui.dart';
import 'package:flowy_infra_ui/widget/spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../widgets/widgets.dart';
import 'personal_info.dart';

class PersonalInfoSettingGroup extends StatelessWidget {
  const PersonalInfoSettingGroup({
    super.key,
    required this.userProfile,
  });

  final UserProfilePB userProfile;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SettingsUserViewBloc>(
          create: (context) => getIt<SettingsUserViewBloc>(
            param1: userProfile,
          )..add(const SettingsUserEvent.initial()),
        ),
        BlocProvider(
          create: (context) => PasswordBloc(userProfile)
            ..add(PasswordEvent.init())
            ..add(PasswordEvent.checkHasPassword()),
        ),
      ],
      child: BlocSelector<SettingsUserViewBloc, SettingsUserState, String>(
        selector: (state) => state.userProfile.name,
        builder: (context, userName) {
          return MobileSettingGroup(
            groupTitle: '我的账户',
            settingItemList: [
              MobileSettingItem(
                name: 'User name',
                trailing: MobileSettingTrailing(
                  text: userName,
                ),
                onTap: () {
                  showMobileBottomSheet(
                    context,
                    showHeader: true,
                    title: '用户名',
                    showCloseButton: true,
                    showDragHandle: true,
                    showDivider: false,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    builder: (_) {
                      return EditUsernameBottomSheet(
                        context,
                        userName: userName,
                        onSubmitted: (value) => context
                            .read<SettingsUserViewBloc>()
                            .add(SettingsUserEvent.updateUserName(name: value)),
                      );
                    },
                  );
                },
              ),
              ...userProfile.userAuthType == AuthTypePB.Server
                  ? [
                      _buildEmailItem(context, userProfile),
                      _buildPasswordItem(context, userProfile),
                    ]
                  : [
                      _buildLoginItem(context, userProfile),
                    ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmailItem(BuildContext context, UserProfilePB userProfile) {
    final theme = AppFlowyTheme.of(context);
    return MobileSettingItem(
      name: '邮箱',
      trailing: Text(
        userProfile.email,
        style: theme.textStyle.heading4.standard(
          color: theme.textColorScheme.secondary,
        ),
      ),
    );
  }

  Widget _buildPasswordItem(BuildContext context, UserProfilePB userProfile) {
    return BlocBuilder<PasswordBloc, PasswordState>(
      builder: (context, state) {
        final hasPassword = state.hasPassword;
        final title = hasPassword
            ? '变更密码'
            : '设置密码';
        final passwordBloc = context.read<PasswordBloc>();
        return MobileSettingItem(
          name: '密码',
          trailing: MobileSettingTrailing(
            text: '',
          ),
          onTap: () {
            showMobileBottomSheet(
              context,
              showHeader: true,
              title: title,
              showCloseButton: true,
              showDragHandle: true,
              showDivider: false,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              builder: (_) {
                Widget child;
                if (hasPassword) {
                  child = ChangePasswordDialogContent(
                    userProfile: userProfile,
                    showTitle: false,
                    showCloseAndSaveButton: false,
                    showSaveButton: true,
                    padding: EdgeInsets.zero,
                  );
                } else {
                  child = SetupPasswordDialogContent(
                    userProfile: userProfile,
                    showTitle: false,
                    showCloseAndSaveButton: false,
                    showSaveButton: true,
                    padding: EdgeInsets.zero,
                  );
                }
                return BlocProvider.value(
                  value: passwordBloc,
                  child: child,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildLoginItem(BuildContext context, UserProfilePB userProfile) {
    final theme = AppFlowyTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '您目前处于本地模式。',
          style: theme.textStyle.body.standard(
            color: theme.textColorScheme.secondary,
          ),
        ),
        VSpace(theme.spacing.m),
        AFOutlinedTextButton.normal(
          text: '登录 AppFlowy Cloud',
          size: AFButtonSize.l,
          alignment: Alignment.center,
          onTap: () async {
            // logout and restart the app
            await getIt<AuthService>().signOut();
            await runAppFlowy();
          },
        ),
        VSpace(theme.spacing.m),
      ],
    );
  }
}
