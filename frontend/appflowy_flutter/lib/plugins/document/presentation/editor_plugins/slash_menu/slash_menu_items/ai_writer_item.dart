import 'package:appflowy/plugins/document/presentation/editor_plugins/ai/operations/ai_writer_entities.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/base/selectable_svg_widget.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/plugins.dart';
import 'package:appflowy_editor/appflowy_editor.dart';

import 'slash_menu_item_builder.dart';

final _keywords = [
  'ai',
  'openai',
  'writer',
  'ai writer',
  'autogenerator',
];

SelectionMenuItem aiWriterSlashMenuItem = SelectionMenuItem(
  getName: () => '向AI提问',
  keywords: [
    ..._keywords,
    '向AI提问',
  ],
  handler: (editorState, _, __) async =>
      _insertAiWriter(editorState, AiWriterCommand.userQuestion),
  icon: (_, isSelected, style) => SelectableSvgWidget(
    data: AiWriterCommand.userQuestion.icon,
    isSelected: isSelected,
    style: style,
  ),
  nameBuilder: slashMenuItemNameBuilder,
);

SelectionMenuItem continueWritingSlashMenuItem = SelectionMenuItem(
  getName: () => '继续写作',
  keywords: [
    ..._keywords,
    '继续写作',
  ],
  handler: (editorState, _, __) async =>
      _insertAiWriter(editorState, AiWriterCommand.continueWriting),
  icon: (_, isSelected, style) => SelectableSvgWidget(
    data: AiWriterCommand.continueWriting.icon,
    isSelected: isSelected,
    style: style,
  ),
  nameBuilder: slashMenuItemNameBuilder,
);

Future<void> _insertAiWriter(
  EditorState editorState,
  AiWriterCommand action,
) async {
  final selection = editorState.selection;
  if (selection == null || !selection.isCollapsed) {
    return;
  }

  final node = editorState.getNodeAtPath(selection.end.path);
  if (node == null || node.delta == null) {
    return;
  }
  final newNode = aiWriterNode(
    selection: selection,
    command: action,
  );

  // default insert after
  final path = node.path.next;
  final transaction = editorState.transaction
    ..insertNode(path, newNode)
    ..afterSelection = null;

  await editorState.apply(
    transaction,
    options: const ApplyOptions(
      recordUndo: false,
      inMemoryUpdate: true,
    ),
  );
}
