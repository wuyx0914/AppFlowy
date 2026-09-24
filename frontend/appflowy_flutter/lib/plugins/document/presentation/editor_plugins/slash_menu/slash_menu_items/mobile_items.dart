import 'package:appflowy/generated/flowy_svgs.g.dart';
import 'package:appflowy/mobile/presentation/selection_menu/mobile_selection_menu_item.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/base/selectable_svg_widget.dart';
import 'package:appflowy_editor/appflowy_editor.dart';

import 'slash_menu_items.dart';

final List<SelectionMenuItem> mobileItems = [
  textStyleMobileSlashMenuItem,
  listMobileSlashMenuItem,
  toggleListMobileSlashMenuItem,
  fileAndMediaMobileSlashMenuItem,
  mobileTableSlashMenuItem,
  visualsMobileSlashMenuItem,
  dateOrReminderSlashMenuItem,
  buildSubpageSlashMenuItem(svg: FlowySvgs.type_page_m),
  advancedMobileSlashMenuItem,
];

final List<SelectionMenuItem> mobileItemsInTale = [
  textStyleMobileSlashMenuItem,
  listMobileSlashMenuItem,
  toggleListMobileSlashMenuItem,
  fileAndMediaMobileSlashMenuItem,
  visualsMobileSlashMenuItem,
  dateOrReminderSlashMenuItem,
  buildSubpageSlashMenuItem(svg: FlowySvgs.type_page_m),
  advancedMobileSlashMenuItem,
];

SelectionMenuItemHandler _handler = (_, __, ___) {};

MobileSelectionMenuItem textStyleMobileSlashMenuItem = MobileSelectionMenuItem(
  getName: () => '文本样式',
  handler: _handler,
  icon: (_, isSelected, style) => SelectableSvgWidget(
    data: FlowySvgs.slash_menu_icon_text_s,
    isSelected: isSelected,
    style: style,
  ),
  nameBuilder: slashMenuItemNameBuilder,
  children: [
    paragraphSlashMenuItem,
    heading1SlashMenuItem,
    heading2SlashMenuItem,
    heading3SlashMenuItem,
  ],
);

MobileSelectionMenuItem listMobileSlashMenuItem = MobileSelectionMenuItem(
  getName: () => '列表',
  handler: _handler,
  icon: (_, isSelected, style) => SelectableSvgWidget(
    data: FlowySvgs.slash_menu_icon_bulleted_list_s,
    isSelected: isSelected,
    style: style,
  ),
  nameBuilder: slashMenuItemNameBuilder,
  children: [
    todoListSlashMenuItem,
    bulletedListSlashMenuItem,
    numberedListSlashMenuItem,
  ],
);

MobileSelectionMenuItem toggleListMobileSlashMenuItem = MobileSelectionMenuItem(
  getName: () => '切换',
  handler: _handler,
  icon: (_, isSelected, style) => SelectableSvgWidget(
    data: FlowySvgs.slash_menu_icon_toggle_s,
    isSelected: isSelected,
    style: style,
  ),
  nameBuilder: slashMenuItemNameBuilder,
  children: [
    toggleListSlashMenuItem,
    toggleHeading1SlashMenuItem,
    toggleHeading2SlashMenuItem,
    toggleHeading3SlashMenuItem,
  ],
);

MobileSelectionMenuItem fileAndMediaMobileSlashMenuItem =
    MobileSelectionMenuItem(
  getName: () => '文件与媒体',
  handler: _handler,
  icon: (_, isSelected, style) => SelectableSvgWidget(
    data: FlowySvgs.slash_menu_icon_file_s,
    isSelected: isSelected,
    style: style,
  ),
  nameBuilder: slashMenuItemNameBuilder,
  children: [
    buildImageSlashMenuItem(svg: FlowySvgs.slash_menu_image_m),
    photoGallerySlashMenuItem,
    fileSlashMenuItem,
  ],
);

MobileSelectionMenuItem visualsMobileSlashMenuItem = MobileSelectionMenuItem(
  getName: () => '视觉元素',
  handler: _handler,
  icon: (_, isSelected, style) => SelectableSvgWidget(
    data: FlowySvgs.slash_menu_icon_visuals_s,
    isSelected: isSelected,
    style: style,
  ),
  nameBuilder: slashMenuItemNameBuilder,
  children: [
    calloutSlashMenuItem,
    dividerSlashMenuItem,
    quoteSlashMenuItem,
  ],
);

MobileSelectionMenuItem advancedMobileSlashMenuItem = MobileSelectionMenuItem(
  getName: () => '高级',
  handler: _handler,
  icon: (_, isSelected, style) => SelectableSvgWidget(
    data: FlowySvgs.drag_element_s,
    isSelected: isSelected,
    style: style,
  ),
  nameBuilder: slashMenuItemNameBuilder,
  children: [
    codeBlockSlashMenuItem,
    mathEquationSlashMenuItem,
  ],
);
