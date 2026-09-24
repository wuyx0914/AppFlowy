import 'package:appflowy/generated/flowy_svgs.g.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/base/selectable_svg_widget.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/plugins.dart';
import 'package:appflowy_editor/appflowy_editor.dart';

import 'slash_menu_item_builder.dart';

final _keywords = [
  'collapsed list',
  'toggle list',
  'list',
  'dropdown',
];

// toggle menu item
SelectionMenuItem toggleListSlashMenuItem = SelectionMenuItem.node(
  getName: () => '切换列表',
  keywords: _keywords,
  nodeBuilder: (editorState, _) => toggleListBlockNode(),
  replace: (_, node) => node.delta?.isEmpty ?? false,
  nameBuilder: slashMenuItemNameBuilder,
  iconBuilder: (editorState, isSelected, style) => SelectableSvgWidget(
    data: FlowySvgs.slash_menu_icon_toggle_s,
    isSelected: isSelected,
    style: style,
  ),
);
