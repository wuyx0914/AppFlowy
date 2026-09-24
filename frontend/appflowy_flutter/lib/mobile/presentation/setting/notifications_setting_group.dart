import 'package:flutter/material.dart';


import 'widgets/widgets.dart';

class NotificationsSettingGroup extends StatefulWidget {
  const NotificationsSettingGroup({super.key});

  @override
  State<NotificationsSettingGroup> createState() =>
      _NotificationsSettingGroupState();
}

class _NotificationsSettingGroupState extends State<NotificationsSettingGroup> {
  bool isPushNotificationOn = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MobileSettingGroup(
      groupTitle: '通知',
      settingItemList: [
        MobileSettingItem(
          name: '推送通知',
          trailing: Switch.adaptive(
            activeColor: theme.colorScheme.primary,
            value: isPushNotificationOn,
            onChanged: (bool value) {
              setState(() {
                isPushNotificationOn = value;
              });
            },
          ),
        ),
      ],
    );
  }
}
