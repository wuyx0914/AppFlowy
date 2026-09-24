import 'package:appflowy/generated/flowy_svgs.g.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/base/selectable_svg_widget.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/plugins.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/slash_menu/slash_menu_items/slash_menu_item_builder.dart';
import 'package:appflowy_editor/appflowy_editor.dart';

final _baseKeywords = [
  'columns',
  'column block',
];

final _twoColumnsKeywords = [
  ..._baseKeywords,
  'two columns',
  '2 columns',
];

final _threeColumnsKeywords = [
  ..._baseKeywords,
  'three columns',
  '3 columns',
];

final _fourColumnsKeywords = [
  ..._baseKeywords,
  'four columns',
  '4 columns',
];

// 2 columns menu item
SelectionMenuItem twoColumnsSlashMenuItem = SelectionMenuItem.node(
  getName: () => '两列',
  keywords: _twoColumnsKeywords,
  nodeBuilder: (editorState, __) => _buildColumnsNode(editorState, 2),
  replace: (_, node) => node.delta?.isEmpty ?? false,
  nameBuilder: slashMenuItemNameBuilder,
  iconBuilder: (_, isSelected, style) => SelectableSvgWidget(
    data: FlowySvgs.slash_menu_icon_two_columns_s,
    isSelected: isSelected,
    style: style,
  ),
  updateSelection: (_, path, __, ___) {
    return Selection.single(
      path: path.child(0).child(0),
      startOffset: 0,
    );
  },
);

// 3 columns menu item
SelectionMenuItem threeColumnsSlashMenuItem = SelectionMenuItem.node(
  getName: () => '三列',
  keywords: _threeColumnsKeywords,
  nodeBuilder: (editorState, __) => _buildColumnsNode(editorState, 3),
  replace: (_, node) => node.delta?.isEmpty ?? false,
  nameBuilder: slashMenuItemNameBuilder,
  iconBuilder: (_, isSelected, style) => SelectableSvgWidget(
    data: FlowySvgs.slash_menu_icon_three_columns_s,
    isSelected: isSelected,
    style: style,
  ),
  updateSelection: (_, path, __, ___) {
    return Selection.single(
      path: path.child(0).child(0),
      startOffset: 0,
    );
  },
);

// 4 columns menu item
SelectionMenuItem fourColumnsSlashMenuItem = SelectionMenuItem.node(
  getName: () => '四列',
  keywords: _fourColumnsKeywords,
  nodeBuilder: (editorState, __) => _buildColumnsNode(editorState, 4),
  replace: (_, node) => node.delta?.isEmpty ?? false,
  nameBuilder: slashMenuItemNameBuilder,
  iconBuilder: (_, isSelected, style) => SelectableSvgWidget(
    data: FlowySvgs.slash_menu_icon_four_columns_s,
    isSelected: isSelected,
    style: style,
  ),
  updateSelection: (_, path, __, ___) {
    return Selection.single(
      path: path.child(0).child(0),
      startOffset: 0,
    );
  },
);

Node _buildColumnsNode(EditorState editorState, int columnCount) {
  return simpleColumnsNode(
    columnCount: columnCount,
    ratio: 1.0 / columnCount,
  );
}
