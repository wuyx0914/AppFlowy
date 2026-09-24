import 'package:appflowy/generated/flowy_svgs.g.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/base/selectable_svg_widget.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor_plugins/appflowy_editor_plugins.dart';

final codeBlockSelectionMenuItem = SelectionMenuItem.node(
  getName: () => '代码块',
  iconBuilder: (editorState, onSelected, style) => SelectableSvgWidget(
    data: FlowySvgs.icon_code_block_s,
    isSelected: onSelected,
    style: style,
  ),
  keywords: ['code', 'codeblock'],
  nodeBuilder: (_, __) => codeBlockNode(),
  replace: (_, node) => node.delta?.isEmpty ?? false,
);
