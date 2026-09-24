import 'package:appflowy/generated/flowy_svgs.g.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/base/selectable_svg_widget.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/plugins.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/slash_menu/slash_menu_items/slash_menu_item_builder.dart';
import 'package:appflowy_editor/appflowy_editor.dart';

final _keywords = [
  'insert date',
  'date',
  'time',
  'reminder',
  'schedule',
];

// date or reminder menu item
SelectionMenuItem dateOrReminderSlashMenuItem = SelectionMenuItem(
  getName: () => '日期或提醒',
  keywords: _keywords,
  handler: (editorState, _, __) async => editorState.insertDateReference(),
  nameBuilder: slashMenuItemNameBuilder,
  icon: (_, isSelected, style) => SelectableSvgWidget(
    data: FlowySvgs.slash_menu_icon_date_or_reminder_s,
    isSelected: isSelected,
    style: style,
  ),
);

extension on EditorState {
  Future<void> insertDateReference() async {
    final selection = this.selection;
    if (selection == null || !selection.isCollapsed) {
      return;
    }

    final node = getNodeAtPath(selection.end.path);
    final delta = node?.delta;
    if (node == null || delta == null) {
      return;
    }

    final transaction = this.transaction
      ..replaceText(
        node,
        selection.start.offset,
        0,
        MentionBlockKeys.mentionChar,
        attributes: MentionBlockKeys.buildMentionDateAttributes(
          date: DateTime.now().toIso8601String(),
          reminderId: null,
          reminderOption: null,
          includeTime: false,
        ),
      );

    await apply(transaction);
  }
}
