import 'dart:io';

import 'package:appflowy/generated/flowy_svgs.g.dart';
import 'package:appflowy/user/application/reminder/reminder_bloc.dart';
import 'package:appflowy/workspace/application/home/home_setting_bloc.dart';
import 'package:appflowy/workspace/presentation/widgets/dialogs.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_ui/appflowy_ui.dart';
import 'package:flowy_infra_ui/flowy_infra_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'widgets/notification_tab.dart';
import 'widgets/notification_tab_bar.dart';

class NotificationPanel extends StatefulWidget {
  const NotificationPanel({super.key});

  @override
  State<NotificationPanel> createState() => _NotificationPanelState();
}

class _NotificationPanelState extends State<NotificationPanel>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  final PopoverController moreActionController = PopoverController();

  final tabs = [
    NotificationTabType.inbox,
    NotificationTabType.unread,
    NotificationTabType.archive,
  ];

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    moreActionController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingBloc = context.read<HomeSettingBloc>();
    final theme = AppFlowyTheme.of(context);
    return GestureDetector(
      onTap: () =>
          settingBloc.add(HomeSettingEvent.collapseNotificationPanel()),
      child: Container(
        color: Colors.transparent,
        child: Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: 380,
              decoration: BoxDecoration(
                color: theme.backgroundColorScheme.primary,
                boxShadow: theme.shadow.small,
              ),
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildTitle(
                    context: context,
                    onHide: () => settingBloc
                        .add(HomeSettingEvent.collapseNotificationPanel()),
                  ),
                  const VSpace(12),
                  NotificationTabBar(
                    tabController: tabController,
                    tabs: tabs,
                  ),
                  const VSpace(14),
                  Expanded(
                    child: TabBarView(
                      controller: tabController,
                      children:
                          tabs.map((e) => NotificationTab(tabType: e)).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTitle({
    required BuildContext context,
    required VoidCallback onHide,
  }) {
    final theme = AppFlowyTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 24,
      child: Row(
        children: [
          FlowyText.medium(
            '通知',
            fontSize: 16,
            figmaLineHeight: 24,
          ),
          Spacer(),
          FlowyIconButton(
            width: 24,
            icon: FlowySvg(
              FlowySvgs.double_back_arrow_m,
              color: theme.iconColorScheme.secondary,
            ),
            richTooltipText: colappsedButtonTooltip(context),
            onPressed: onHide,
          ),
          HSpace(8),
          buildMoreActionButton(context),
        ],
      ),
    );
  }

  Widget buildMoreActionButton(BuildContext context) {
    final theme = AppFlowyTheme.of(context);
    return AppFlowyPopover(
      constraints: BoxConstraints.loose(const Size(240, 78)),
      offset: const Offset(-24, 24),
      margin: EdgeInsets.zero,
      controller: moreActionController,
      onOpen: () => keepEditorFocusNotifier.increase(),
      onClose: () => keepEditorFocusNotifier.decrease(),
      popupBuilder: (_) => buildMoreActions(),
      child: FlowyIconButton(
        width: 24,
        icon: FlowySvg(
          FlowySvgs.three_dots_m,
          color: theme.iconColorScheme.secondary,
        ),
        onPressed: () {
          keepEditorFocusNotifier.increase();
          moreActionController.show();
        },
      ),
    );
  }

  Widget buildMoreActions() {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.all(Radius.circular(8)),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 4),
            blurRadius: 24,
            color: Color(0x0000001F),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 30,
            child: FlowyButton(
              text: FlowyText.regular(
                '全部标记为已读',
              ),
              leftIcon: FlowySvg(FlowySvgs.m_notification_mark_as_read_s),
              onTap: () {
                showToastNotification(
                  message:
                      '已成功将所有项目标记为已读取',
                );
                context
                    .read<ReminderBloc>()
                    .add(const ReminderEvent.markAllRead());
                moreActionController.close();
              },
            ),
          ),
          VSpace(2),
          SizedBox(
            height: 30,
            child: FlowyButton(
              text: FlowyText.regular(
                '全部存盘',
              ),
              leftIcon: FlowySvg(FlowySvgs.m_notification_archived_s),
              onTap: () {
                showToastNotification(
                  message: '已成功归档全部项目',
                );
                context
                    .read<ReminderBloc>()
                    .add(const ReminderEvent.archiveAll());
                moreActionController.close();
              },
            ),
          ),
        ],
      ),
    );
  }

  TextSpan colappsedButtonTooltip(BuildContext context) {
    return TextSpan(
      children: [
        TextSpan(
          text: '${'关闭通知'}\n',
          style: context.tooltipTextStyle(),
        ),
        TextSpan(
          text: Platform.isMacOS ? '⌘+.' : 'Ctrl+\\',
          style: context
              .tooltipTextStyle()
              ?.copyWith(color: Theme.of(context).hintColor),
        ),
      ],
    );
  }
}
