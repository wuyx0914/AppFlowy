import 'package:appflowy/generated/flowy_svgs.g.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/base/selectable_svg_widget.dart';
import 'package:appflowy_editor/appflowy_editor.dart';

import 'slash_menu_item_builder.dart';

final _keywords = [
  'bulleted list',
  'list',
  'unordered list',
  'ul',
];

/// Bulleted list menu item
final bulletedListSlashMenuItem = SelectionMenuItem(
  getName: () => '项目符号列表',
  keywords: _keywords,
  handler: (editorState, _, __) {
    insertBulletedListAfterSelection(editorState);
  },
  nameBuilder: slashMenuItemNameBuilder,
  icon: (editorState, isSelected, style) => SelectableSvgWidget(
    data: FlowySvgs.slash_menu_icon_bulleted_list_s,
    isSelected: isSelected,
    style: style,
  ),
);
