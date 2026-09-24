import 'package:appflowy/generated/flowy_svgs.g.dart';
import 'package:appflowy/plugins/database/application/database_controller.dart';
import 'package:appflowy/plugins/database/calendar/presentation/toolbar/calendar_layout_setting.dart';
import 'package:appflowy/plugins/database/grid/presentation/layout/sizes.dart';
import 'package:appflowy/plugins/database/widgets/group/database_group.dart';
import 'package:appflowy/plugins/database/widgets/setting/database_layout_selector.dart';
import 'package:appflowy/plugins/database/widgets/setting/setting_property_list.dart';
import 'package:flowy_infra/theme_extension.dart';
import 'package:flowy_infra_ui/flowy_infra_ui.dart';
import 'package:flutter/material.dart';

enum DatabaseSettingAction {
  showProperties,
  showLayout,
  showGroup,
  showCalendarLayout,
}

extension DatabaseSettingActionExtension on DatabaseSettingAction {
  FlowySvgData iconData() {
    switch (this) {
      case DatabaseSettingAction.showProperties:
        return FlowySvgs.multiselect_s;
      case DatabaseSettingAction.showLayout:
        return FlowySvgs.database_layout_s;
      case DatabaseSettingAction.showGroup:
        return FlowySvgs.group_s;
      case DatabaseSettingAction.showCalendarLayout:
        return FlowySvgs.calendar_layout_s;
    }
  }

  String title() {
    switch (this) {
      case DatabaseSettingAction.showProperties:
        return '特性';
      case DatabaseSettingAction.showLayout:
        return '布局';
      case DatabaseSettingAction.showGroup:
        return '组';
      case DatabaseSettingAction.showCalendarLayout:
        return '日历布局';
    }
  }

  Widget build(
    BuildContext context,
    DatabaseController databaseController,
    PopoverMutex popoverMutex,
  ) {
    final popover = switch (this) {
      DatabaseSettingAction.showLayout => DatabaseLayoutSelector(
          viewId: databaseController.viewId,
          databaseController: databaseController,
        ),
      DatabaseSettingAction.showGroup => DatabaseGroupList(
          viewId: databaseController.viewId,
          databaseController: databaseController,
          onDismissed: () {},
        ),
      DatabaseSettingAction.showProperties => DatabasePropertyList(
          viewId: databaseController.viewId,
          fieldController: databaseController.fieldController,
        ),
      DatabaseSettingAction.showCalendarLayout => CalendarLayoutSetting(
          databaseController: databaseController,
        ),
    };

    return AppFlowyPopover(
      triggerActions: PopoverTriggerFlags.hover | PopoverTriggerFlags.click,
      direction: PopoverDirection.leftWithTopAligned,
      mutex: popoverMutex,
      margin: EdgeInsets.zero,
      offset: const Offset(-14, 0),
      child: SizedBox(
        height: GridSize.popoverItemHeight,
        child: FlowyButton(
          hoverColor: AFThemeExtension.of(context).lightGreyHover,
          text: FlowyText(
            title(),
            lineHeight: 1.0,
            color: AFThemeExtension.of(context).textColor,
          ),
          leftIcon: FlowySvg(
            iconData(),
            color: Theme.of(context).iconTheme.color,
          ),
          rightIcon: FlowySvg(FlowySvgs.database_settings_arrow_right_s),
        ),
      ),
      popupBuilder: (context) => popover,
    );
  }
}
