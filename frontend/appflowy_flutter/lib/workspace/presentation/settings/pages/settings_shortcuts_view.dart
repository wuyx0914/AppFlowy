import 'package:appflowy/generated/flowy_svgs.g.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/align_toolbar_item/custom_text_align_command.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/base/string_extension.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/copy_and_paste/custom_copy_command.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/copy_and_paste/custom_cut_command.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/copy_and_paste/custom_paste_command.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/math_equation/math_equation_shortcut.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/toggle/toggle_block_shortcuts.dart';
import 'package:appflowy/shared/error_page/error_page.dart';
import 'package:appflowy/workspace/application/settings/shortcuts/settings_shortcuts_cubit.dart';
import 'package:appflowy/workspace/application/settings/shortcuts/settings_shortcuts_service.dart';
import 'package:appflowy/workspace/presentation/home/menu/sidebar/space/shared_widget.dart';
import 'package:appflowy/workspace/presentation/settings/shared/settings_alert_dialog.dart';
import 'package:appflowy/workspace/presentation/settings/shared/settings_body.dart';
import 'package:appflowy/workspace/presentation/settings/widgets/emoji_picker/emoji_shortcut_event.dart';
import 'package:appflowy/workspace/presentation/widgets/dialogs.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor_plugins/appflowy_editor_plugins.dart';
import 'package:appflowy_ui/appflowy_ui.dart';
import 'package:flowy_infra/size.dart';
import 'package:flowy_infra/theme_extension.dart';
import 'package:flowy_infra_ui/flowy_infra_ui.dart';
import 'package:flowy_infra_ui/style_widget/hover.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:universal_platform/universal_platform.dart';

class SettingsShortcutsView extends StatefulWidget {
  const SettingsShortcutsView({super.key});

  @override
  State<SettingsShortcutsView> createState() => _SettingsShortcutsViewState();
}

class _SettingsShortcutsViewState extends State<SettingsShortcutsView> {
  String _query = '';
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ShortcutsCubit(SettingsShortcutService())..fetchShortcuts(),
      child: Builder(
        builder: (context) => SettingsBody(
          title: '快捷键',
          autoSeparate: false,
          children: [
            Row(
              children: [
                Flexible(
                  child: _SearchBar(
                    onSearchChanged: (v) => setState(() => _query = v),
                  ),
                ),
                const HSpace(10),
                _ResetButton(
                  onReset: () {
                    showConfirmDialog(
                      context: context,
                      title: '重置快捷键',
                      description: '这将会将所有按键绑定重置为默认，之后无法撤销。你确定要继续吗？',
                      confirmLabel: '重设',
                      onConfirm: (_) {
                        context.read<ShortcutsCubit>().resetToDefault();
                        Navigator.of(context).pop();
                      },
                      style: ConfirmPopupStyle.cancelAndOk,
                    );
                  },
                ),
              ],
            ),
            BlocBuilder<ShortcutsCubit, ShortcutsState>(
              builder: (context, state) {
                final filtered = state.commandShortcutEvents
                    .where(
                      (e) => e.afLabel
                          .toLowerCase()
                          .contains(_query.toLowerCase()),
                    )
                    .toList();

                return Column(
                  children: [
                    const VSpace(16),
                    if (state.status.isLoading) ...[
                      const CircularProgressIndicator(),
                    ] else if (state.status.isFailure) ...[
                      FlowyErrorPage.message(
                        '加载快捷键失败: {state.error}',
                        howToFix: '请再次尝试，如果该问题依然存在，请在 Github 上联系我们',
                      ),
                    ] else ...[
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: filtered.length,
                        itemBuilder: (context, index) => ShortcutSettingTile(
                          command: filtered[index],
                          canStartEditing: () => !_isEditing,
                          onStartEditing: () =>
                              setState(() => _isEditing = true),
                          onFinishEditing: () =>
                              setState(() => _isEditing = false),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({this.onSearchChanged});

  final void Function(String)? onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return AFTextField(
      onChanged: onSearchChanged,
      hintText: '搜索',
    );
  }
}

class _ResetButton extends StatelessWidget {
  const _ResetButton({this.onReset});

  final void Function()? onReset;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onReset,
      child: FlowyHover(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 4.0,
            horizontal: 6,
          ),
          child: Row(
            children: [
              const FlowySvg(
                FlowySvgs.restore_s,
                size: Size.square(20),
              ),
              const HSpace(6),
              SizedBox(
                height: 16,
                child: FlowyText.regular(
                  '重置为默认',
                  color: AFThemeExtension.of(context).strongText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ShortcutSettingTile extends StatefulWidget {
  const ShortcutSettingTile({
    super.key,
    required this.command,
    required this.onStartEditing,
    required this.onFinishEditing,
    required this.canStartEditing,
  });

  final CommandShortcutEvent command;
  final VoidCallback onStartEditing;
  final VoidCallback onFinishEditing;
  final bool Function() canStartEditing;

  @override
  State<ShortcutSettingTile> createState() => _ShortcutSettingTileState();
}

class _ShortcutSettingTileState extends State<ShortcutSettingTile> {
  final keybindController = TextEditingController();

  late final FocusNode focusNode;

  bool isHovering = false;
  bool isEditing = false;
  bool canClickOutside = false;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode(
      onKeyEvent: (focusNode, key) {
        if (key is! KeyDownEvent && key is! KeyRepeatEvent) {
          return KeyEventResult.ignored;
        }

        if (key.logicalKey == LogicalKeyboardKey.enter &&
            !HardwareKeyboard.instance.isShiftPressed) {
          if (keybindController.text == widget.command.command) {
            _finishEditing();
            return KeyEventResult.handled;
          }

          final conflict = context.read<ShortcutsCubit>().getConflict(
                widget.command,
                keybindController.text,
              );

          if (conflict != null) {
            canClickOutside = true;
            SettingsAlertDialog(
              title: '{keybindController.text} 目前正在使用中',
              confirm: () {
                conflict.clearCommand();
                _updateCommand();
                Navigator.of(context).pop();
              },
              confirmLabel: '继续',
              children: [
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                    children: [
                      TextSpan(
                        text: '这个快捷键目前使用中由',
                      ),
                      TextSpan(
                        text: conflict.afLabel,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      TextSpan(
                        text: '. 如果您取代此快捷键，它将从 {keybindController.text} 中移除。',
                      ),
                    ],
                  ),
                ),
              ],
            ).show(context).then((_) => canClickOutside = false);
          } else {
            _updateCommand();
          }
        } else if (key.logicalKey == LogicalKeyboardKey.escape) {
          _finishEditing();
        } else {
          // Extract complete keybinding
          setState(() => keybindController.text = key.toCommand);
        }

        return KeyEventResult.handled;
      },
    );
  }

  void _finishEditing() => setState(() {
        isEditing = false;
        keybindController.clear();
        widget.onFinishEditing();
      });

  void _updateCommand() {
    widget.command.updateCommand(command: keybindController.text);
    context.read<ShortcutsCubit>().updateAllShortcuts();
    _finishEditing();
  }

  @override
  void dispose() {
    focusNode.dispose();
    keybindController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: FlowyHover(
        cursor: MouseCursor.defer,
        style: HoverStyle(
          hoverColor: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.zero,
        ),
        resetHoverOnRebuild: false,
        builder: (context, isHovering) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              const HSpace(8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: FlowyText.regular(
                    widget.command.afLabel,
                    fontSize: 14,
                    lineHeight: 1,
                    maxLines: 2,
                    color: AFThemeExtension.of(context).strongText,
                  ),
                ),
              ),
              Expanded(
                child: isEditing
                    ? _renderKeybindEditor()
                    : _renderKeybindings(isHovering),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _renderKeybindings(bool isHovering) => Row(
        children: [
          if (widget.command.keybindings.isNotEmpty) ...[
            ..._toParts(widget.command.keybindings.first).map(
              (key) => KeyBadge(keyLabel: key),
            ),
          ] else ...[
            const SizedBox(height: 24),
          ],
          const Spacer(),
          if (isHovering)
            GestureDetector(
              onTap: () {
                if (widget.canStartEditing()) {
                  setState(() {
                    widget.onStartEditing();
                    isEditing = true;
                  });
                }
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: FlowyTooltip(
                  message: '按一下以开始编辑快捷键。',
                  child: const FlowySvg(
                    FlowySvgs.edit_s,
                    size: Size.square(16),
                  ),
                ),
              ),
            ),
          const HSpace(8),
        ],
      );

  Widget _renderKeybindEditor() => TapRegion(
        onTapOutside: canClickOutside ? null : (_) => _finishEditing(),
        child: FlowyTextField(
          focusNode: focusNode,
          controller: keybindController,
          hintText: '输入新的绑定',
          onChanged: (_) => setState(() {}),
          suffixIcon: keybindController.text.isNotEmpty
              ? MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => setState(() => keybindController.clear()),
                    child: const FlowySvg(
                      FlowySvgs.close_s,
                      size: Size.square(10),
                    ),
                  ),
                )
              : null,
        ),
      );

  List<String> _toParts(Keybinding binding) {
    final List<String> keys = [];

    if (binding.isControlPressed) {
      keys.add('ctrl');
    }
    if (binding.isMetaPressed) {
      keys.add('meta');
    }
    if (binding.isShiftPressed) {
      keys.add('shift');
    }
    if (binding.isAltPressed) {
      keys.add('alt');
    }

    return keys..add(binding.keyLabel);
  }
}

@visibleForTesting
class KeyBadge extends StatelessWidget {
  const KeyBadge({super.key, required this.keyLabel});

  final String keyLabel;

  @override
  Widget build(BuildContext context) {
    if (iconData == null && keyLabel.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 24,
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AFThemeExtension.of(context).greySelect,
        borderRadius: Corners.s4Border,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: iconData != null
            ? FlowySvg(iconData!, color: Colors.black)
            : FlowyText.medium(
                keyLabel.toLowerCase(),
                fontSize: 12,
                color: Colors.black,
              ),
      ),
    );
  }

  FlowySvgData? get iconData => switch (keyLabel) {
        'meta' => FlowySvgs.keyboard_meta_s,
        'arrow left' => FlowySvgs.keyboard_arrow_left_s,
        'arrow right' => FlowySvgs.keyboard_arrow_right_s,
        'arrow up' => FlowySvgs.keyboard_arrow_up_s,
        'arrow down' => FlowySvgs.keyboard_arrow_down_s,
        'shift' => FlowySvgs.keyboard_shift_s,
        'tab' => FlowySvgs.keyboard_tab_s,
        'enter' || 'return' => FlowySvgs.keyboard_return_s,
        'opt' || 'option' => FlowySvgs.keyboard_option_s,
        _ => null,
      };
}

extension ToCommand on KeyEvent {
  String get toCommand {
    String command = '';
    if (HardwareKeyboard.instance.isControlPressed) {
      command += 'ctrl+';
    }
    if (HardwareKeyboard.instance.isMetaPressed) {
      command += 'meta+';
    }
    if (HardwareKeyboard.instance.isShiftPressed) {
      command += 'shift+';
    }
    if (HardwareKeyboard.instance.isAltPressed) {
      command += 'alt+';
    }

    if ([
      LogicalKeyboardKey.control,
      LogicalKeyboardKey.controlLeft,
      LogicalKeyboardKey.controlRight,
      LogicalKeyboardKey.meta,
      LogicalKeyboardKey.metaLeft,
      LogicalKeyboardKey.metaRight,
      LogicalKeyboardKey.alt,
      LogicalKeyboardKey.altLeft,
      LogicalKeyboardKey.altRight,
      LogicalKeyboardKey.shift,
      LogicalKeyboardKey.shiftLeft,
      LogicalKeyboardKey.shiftRight,
    ].contains(logicalKey)) {
      return command;
    }

    final keyPressed = keyToCodeMapping.keys.firstWhere(
      (k) => keyToCodeMapping[k] == logicalKey.keyId,
      orElse: () => '',
    );

    return command += keyPressed;
  }
}

extension CommandLabel on CommandShortcutEvent {
  String get afLabel {
    String? label;

    if (key == toggleToggleListCommand.key) {
      label = '切换至待办事项清单';
    } else if (key == insertNewParagraphNextToCodeBlockCommand('').key) {
      label = '插入新的段落';
    } else if (key == pasteInCodeblock('').key) {
      label =
          '粘贴为代码块';
    } else if (key == selectAllInCodeBlockCommand('').key) {
      label =
          '全选';
    } else if (key == tabToInsertSpacesInCodeBlockCommand('').key) {
      label = '在行首插入两个空格';
    } else if (key == tabToDeleteSpacesInCodeBlockCommand('').key) {
      label = '删除行首的两个空格';
    } else if (key == tabSpacesAtCurosrInCodeBlockCommand('').key) {
      label = '在光标处插入两个空格';
    } else if (key == customCopyCommand.key) {
      label = '复制选中的内容';
    } else if (key == customPasteCommand.key) {
      label = '粘贴内容';
    } else if (key == customCutCommand.key) {
      label = '剪切选取项目';
    } else if (key == customTextLeftAlignCommand.key) {
      label = '文本居左对齐';
    } else if (key == customTextCenterAlignCommand.key) {
      label = '文本居中对齐';
    } else if (key == customTextRightAlignCommand.key) {
      label = '文本居右对齐';
    } else if (key == insertInlineMathEquationCommand.key) {
      label = '插入行内数学方程序';
    } else if (key == undoCommand.key) {
      label = '撤销';
    } else if (key == redoCommand.key) {
      label = '重做';
    } else if (key == convertToParagraphCommand.key) {
      label =
          '将块转换为段落';
    } else if (key == backspaceCommand.key) {
      label = '删除';
    } else if (key == deleteLeftWordCommand.key) {
      label = '删除左侧文字';
    } else if (key == deleteLeftSentenceCommand.key) {
      label =
          '删除左侧句子';
    } else if (key == deleteCommand.key) {
      label = UniversalPlatform.isMacOS
          ? '删除左侧字符'
          : '删除右侧字符';
    } else if (key == deleteRightWordCommand.key) {
      label =
          '删除右侧文字';
    } else if (key == moveCursorLeftCommand.key) {
      label = '将光标移至左侧';
    } else if (key == moveCursorToBeginCommand.key) {
      label = '将光标移至开头';
    } else if (key == moveCursorToLeftWordCommand.key) {
      label =
          '将光标移至文字左侧';
    } else if (key == moveCursorLeftSelectCommand.key) {
      label = '选取并将光标向左移动';
    } else if (key == moveCursorBeginSelectCommand.key) {
      label = '选取并将光标移至开头';
    } else if (key == moveCursorLeftWordSelectCommand.key) {
      label = '选取并将光标向左移动一个单字';
    } else if (key == moveCursorRightCommand.key) {
      label =
          '将光标移至右侧';
    } else if (key == moveCursorToEndCommand.key) {
      label = '将光标移至末尾';
    } else if (key == moveCursorToRightWordCommand.key) {
      label = '将光标移至文字右侧';
    } else if (key == moveCursorRightSelectCommand.key) {
      label = '选取并将光标向右移动一个位置';
    } else if (key == moveCursorEndSelectCommand.key) {
      label = '选取并将光标移至结尾';
    } else if (key == moveCursorRightWordSelectCommand.key) {
      label = '选取并将光标向右移动一个单字';
    } else if (key == moveCursorUpCommand.key) {
      label = '向上移动光标';
    } else if (key == moveCursorTopSelectCommand.key) {
      label = '选取并将光标移至顶端';
    } else if (key == moveCursorTopCommand.key) {
      label = '将光标移至顶端';
    } else if (key == moveCursorUpSelectCommand.key) {
      label =
          '选取并将光标向上移动';
    } else if (key == moveCursorDownCommand.key) {
      label = '将光标向下移动';
    } else if (key == moveCursorBottomSelectCommand.key) {
      label = '选取并将光标移到底部';
    } else if (key == moveCursorBottomCommand.key) {
      label =
          '将光标移到底部';
    } else if (key == moveCursorDownSelectCommand.key) {
      label = '选取并将光标向下移动';
    } else if (key == homeCommand.key) {
      label = '滚动至顶部';
    } else if (key == endCommand.key) {
      label = '滚动至底部';
    } else if (key == toggleBoldCommand.key) {
      label = '切换粗体';
    } else if (key == toggleItalicCommand.key) {
      label = '切换斜体';
    } else if (key == toggleUnderlineCommand.key) {
      label =
          '切换底线';
    } else if (key == toggleStrikethroughCommand.key) {
      label = '切换删除线';
    } else if (key == toggleCodeCommand.key) {
      label = '切换行内代码';
    } else if (key == toggleHighlightCommand.key) {
      label =
          '切换标示重点';
    } else if (key == showLinkMenuCommand.key) {
      label = '显示链接菜单';
    } else if (key == openInlineLinkCommand.key) {
      label = '打开行内链接';
    } else if (key == openLinksCommand.key) {
      label = '打开所有已选取的链接';
    } else if (key == indentCommand.key) {
      label = '缩进';
    } else if (key == outdentCommand.key) {
      label = '取消缩进';
    } else if (key == exitEditingCommand.key) {
      label = '结束编辑模式';
    } else if (key == pageUpCommand.key) {
      label = '向上滚动一页';
    } else if (key == pageDownCommand.key) {
      label = '向下滚动一页';
    } else if (key == selectAllCommand.key) {
      label = '全选';
    } else if (key == pasteTextWithoutFormattingCommand.key) {
      label = '粘贴内容，不含格式';
    } else if (key == emojiShortcutEvent.key) {
      label =
          '显示表情符号选择器';
    } else if (key == enterInTableCell.key) {
      label =
          '在表格中添加换行符号';
    } else if (key == leftInTableCell.key) {
      label =
          '在表格中向左移动一个保存格';
    } else if (key == rightInTableCell.key) {
      label =
          '在表格中向右移动一个保存格';
    } else if (key == upInTableCell.key) {
      label = '在表格中向上移动一个保存格';
    } else if (key == downInTableCell.key) {
      label =
          '在表格中向下移动一个保存格';
    } else if (key == tabInTableCell.key) {
      label = '前往表格中的下一个可用保存格';
    } else if (key == shiftTabInTableCell.key) {
      label = '前往表格中先前可用的保存格';
    } else if (key == backSpaceInTableCell.key) {
      label = '在保存格开头停止';
    }

    return label ?? description?.capitalize() ?? '';
  }
}
