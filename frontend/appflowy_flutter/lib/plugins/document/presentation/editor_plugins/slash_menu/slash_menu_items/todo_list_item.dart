import 'package:appflowy/generated/flowy_svgs.g.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/base/selectable_svg_widget.dart';
import 'package:appflowy_editor/appflowy_editor.dart';

import 'slash_menu_item_builder.dart';

final _keywords = [
  'checkbox',
  'todo',
  'list',
  'to-do',
  'task',
];

final todoListSlashMenuItem = SelectionMenuItem(
  getName: () => '复选框',
  keywords: _keywords,
  handler: (editorState, _, __) async => insertCheckboxAfterSelection(
    editorState,
  ),
  nameBuilder: slashMenuItemNameBuilder,
  icon: (editorState, isSelected, style) => SelectableSvgWidget(
    data: FlowySvgs.slash_menu_icon_checkbox_s,
    isSelected: isSelected,
    style: style,
  ),
);
