import 'package:appflowy/mobile/presentation/home/tab/_round_underline_tab_indicator.dart';
import 'package:flutter/material.dart';

enum NotificationTabType {
  inbox,
  unread,
  archive;

  String get tr {
    switch (this) {
      case NotificationTabType.inbox:
        return '收件匣';
      case NotificationTabType.unread:
        return '未读';
      case NotificationTabType.archive:
        return '已归档';
    }
  }
}

class NotificationTabBar extends StatelessWidget {
  const NotificationTabBar({
    super.key,
    required this.tabController,
    this.height = 32,
    required this.tabs,
  });

  final double height;
  final List<NotificationTabType> tabs;
  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    final baseStyle = Theme.of(context).textTheme.bodyMedium;
    final labelStyle = baseStyle?.copyWith(
      fontWeight: FontWeight.w500,
      fontSize: 16.0,
      height: 22.0 / 16.0,
    );
    final unselectedLabelStyle = baseStyle?.copyWith(
      fontWeight: FontWeight.w400,
      fontSize: 15.0,
      height: 22.0 / 15.0,
    );

    return Container(
      height: height,
      padding: const EdgeInsets.only(left: 16),
      child: TabBar(
        controller: tabController,
        tabs: tabs.map((e) => Tab(text: e.tr)).toList(),
        indicatorSize: TabBarIndicatorSize.label,
        isScrollable: true,
        labelStyle: labelStyle,
        labelColor: baseStyle?.color,
        labelPadding: const EdgeInsets.only(right: 20),
        unselectedLabelStyle: unselectedLabelStyle,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        indicator: const RoundUnderlineTabIndicator(
          width: 28.0,
          borderSide: BorderSide(
            color: Color(0xFF00C8FF),
            width: 3,
          ),
        ),
      ),
    );
  }
}
