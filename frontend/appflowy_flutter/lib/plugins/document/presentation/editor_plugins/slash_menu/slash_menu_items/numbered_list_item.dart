import 'package:appflowy/generated/flowy_svgs.g.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/base/selectable_svg_widget.dart';
import 'package:appflowy_editor/appflowy_editor.dart';

import 'slash_menu_item_builder.dart';

final _keywords = [
  'numbered list',
  'list',
  'ordered list',
  'ol',
];

/// Numbered list menu item
final numberedListSlashMenuItem = SelectionMenuItem(
  getName: () => '编号列表',
  keywords: _keywords,
  handler: (editorState, _, __) async => insertNumberedListAfterSelection(
    editorState,
  ),
  nameBuilder: slashMenuItemNameBuilder,
  icon: (editorState, isSelected, style) => SelectableSvgWidget(
    data: FlowySvgs.slash_menu_icon_numbered_list_s,
    isSelected: isSelected,
    style: style,
  ),
);
