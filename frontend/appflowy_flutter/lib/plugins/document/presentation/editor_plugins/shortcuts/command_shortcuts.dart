import 'package:appflowy/plugins/document/presentation/editor_plugins/align_toolbar_item/custom_text_align_command.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/math_equation/math_equation_shortcut.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/plugins.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/shortcuts/custom_delete_command.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/undo_redo/custom_undo_redo_commands.dart';
import 'package:appflowy/workspace/presentation/settings/widgets/emoji_picker/emoji_picker.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor_plugins/appflowy_editor_plugins.dart';

import 'exit_edit_mode_command.dart';

final List<CommandShortcutEvent> defaultCommandShortcutEvents = [
  ...commandShortcutEvents.map((e) => e.copyWith()),
];

// Command shortcuts are order-sensitive. Verify order when modifying.
List<CommandShortcutEvent> commandShortcutEvents = [
  ...simpleTableCommands,

  customExitEditingCommand,
  backspaceToTitle,
  removeToggleHeadingStyle,

  arrowUpToTitle,
  arrowLeftToTitle,

  toggleToggleListCommand,

  ...localizedCodeBlockCommands,

  customCopyCommand,
  customPasteCommand,
  customPastePlainTextCommand,
  customCutCommand,
  customUndoCommand,
  customRedoCommand,

  ...customTextAlignCommands,

  customDeleteCommand,
  insertInlineMathEquationCommand,

  // remove standard shortcuts for copy, cut, paste, todo
  ...standardCommandShortcutEvents
    ..removeWhere(
      (shortcut) => [
        copyCommand,
        cutCommand,
        pasteCommand,
        pasteTextWithoutFormattingCommand,
        toggleTodoListCommand,
        undoCommand,
        redoCommand,
        exitEditingCommand,
        ...tableCommands,
        deleteCommand,
      ].contains(shortcut),
    ),

  emojiShortcutEvent,
];

final _codeBlockLocalization = CodeBlockLocalizations(
  codeBlockNewParagraph:
      '在代码区块旁边插入一个新段落',
  codeBlockIndentLines:
      '在代码区块开头插入两个空格',
  codeBlockOutdentLines:
      '删除代码区块开头的两个空格',
  codeBlockSelectAll:
      '选取代码区块内的所有内容',
  codeBlockPasteText:
      '将文本贴到代码区块中',
  codeBlockAddTwoSpaces:
      '在代码区块中光标位置插入两个空格',
);

final localizedCodeBlockCommands = codeBlockCommands(
  localizations: _codeBlockLocalization,
);
