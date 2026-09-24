import 'package:appflowy/plugins/document/presentation/editor_plugins/plugins.dart';
import 'package:appflowy_editor/appflowy_editor.dart';

final List<List<ContextMenuItem>> customContextMenuItems = [
  [
    ContextMenuItem(
      getName: () => '复制',
      onPressed: (editorState) => customCopyCommand.execute(editorState),
    ),
    ContextMenuItem(
      getName: () => '粘贴',
      onPressed: (editorState) => customPasteCommand.execute(editorState),
    ),
    ContextMenuItem(
      getName: () => '以纯文本粘贴',
      onPressed: (editorState) =>
          customPastePlainTextCommand.execute(editorState),
    ),
    ContextMenuItem(
      getName: () => '剪切',
      onPressed: (editorState) => customCutCommand.execute(editorState),
    ),
  ],
];
