import 'package:appflowy/generated/flowy_svgs.g.dart';
import 'package:appflowy/workspace/presentation/notifications/widgets/notification_tab_bar.dart';
import 'package:flowy_infra_ui/flowy_infra_ui.dart';
import 'package:flutter/material.dart';

class EmptyNotification extends StatelessWidget {
  const EmptyNotification({
    super.key,
    required this.type,
  });

  final NotificationTabType type;

  @override
  Widget build(BuildContext context) {
    final title = switch (type) {
      NotificationTabType.inbox =>
        '收件匣清零!',
      NotificationTabType.archive =>
        '没有归档',
      NotificationTabType.unread =>
        '没有未读取的通知',
    };
    final desc = switch (type) {
      NotificationTabType.inbox =>
        '在此处设置提醒以接收通知。',
      NotificationTabType.archive =>
        '在此设置提醒，以接收通知。',
      NotificationTabType.unread =>
        '您已完成所有更新!',
    };
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const FlowySvg(FlowySvgs.m_empty_notification_xl),
        const VSpace(12.0),
        FlowyText(
          title,
          fontSize: 16.0,
          figmaLineHeight: 24.0,
          fontWeight: FontWeight.w500,
        ),
        const VSpace(4.0),
        Opacity(
          opacity: 0.45,
          child: FlowyText(
            desc,
            fontSize: 15.0,
            figmaLineHeight: 22.0,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
