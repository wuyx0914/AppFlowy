import 'package:appflowy/workspace/application/settings/notifications/notification_settings_cubit.dart';
import 'package:appflowy/workspace/presentation/settings/shared/setting_list_tile.dart';
import 'package:appflowy/workspace/presentation/settings/shared/settings_body.dart';
import 'package:appflowy/workspace/presentation/widgets/toggle/toggle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsNotificationsView extends StatelessWidget {
  const SettingsNotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationSettingsCubit, NotificationSettingsState>(
      builder: (context, state) {
        return SettingsBody(
          title: '通知',
          children: [
            SettingListTile(
              label: '启用通知',
              hint: '关闭以阻止本地通知出现。',
              trailing: [
                Toggle(
                  value: state.isNotificationsEnabled,
                  onChanged: (_) => context
                      .read<NotificationSettingsCubit>()
                      .toggleNotificationsEnabled(),
                ),
              ],
            ),
            SettingListTile(
              label: '显示通知图标',
              hint: '关闭开关以隐藏侧边栏中的通知图标。',
              trailing: [
                Toggle(
                  value: state.isShowNotificationsIconEnabled,
                  onChanged: (_) => context
                      .read<NotificationSettingsCubit>()
                      .toggleShowNotificationIconEnabled(),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
