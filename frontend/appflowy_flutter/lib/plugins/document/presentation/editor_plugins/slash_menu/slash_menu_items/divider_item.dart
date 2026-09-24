import 'package:appflowy/generated/flowy_svgs.g.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/base/selectable_svg_widget.dart';
import 'package:appflowy_editor/appflowy_editor.dart';

import 'slash_menu_item_builder.dart';

final _keywords = [
  'divider',
  'separator',
  'line',
  'break',
  'horizontal line',
];

/// Divider menu item
final dividerSlashMenuItem = SelectionMenuItem(
  getName: () => '分隔符',
  keywords: _keywords,
  handler: (editorState, _, __) async => editorState.insertDividerBlock(),
  nameBuilder: slashMenuItemNameBuilder,
  icon: (editorState, isSelected, style) => SelectableSvgWidget(
    data: FlowySvgs.slash_menu_icon_divider_s,
    isSelected: isSelected,
    style: style,
  ),
);

extension on EditorState {
  Future<void> insertDividerBlock() async {
    final selection = this.selection;
    if (selection == null || !selection.isCollapsed) {
      return;
    }
    final path = selection.end.path;
    final node = getNodeAtPath(path);
    final delta = node?.delta;
    if (node == null || delta == null) {
      return;
    }
    final insertedPath = delta.isEmpty ? path : path.next;
    final transaction = this.transaction
      ..insertNode(insertedPath, dividerNode())
      ..insertNode(insertedPath, paragraphNode())
      ..afterSelection = Selection.collapsed(Position(path: insertedPath.next));
    await apply(transaction);
  }
}
