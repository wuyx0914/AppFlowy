import 'dart:io';

import 'package:appflowy/generated/flowy_svgs.g.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/actions/block_action_button.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flowy_infra_ui/flowy_infra_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BlockAddButton extends StatelessWidget {
  const BlockAddButton({
    super.key,
    required this.blockComponentContext,
    required this.blockComponentState,
    required this.editorState,
    required this.showSlashMenu,
  });

  final BlockComponentContext blockComponentContext;
  final BlockComponentActionState blockComponentState;

  final EditorState editorState;
  final VoidCallback showSlashMenu;

  @override
  Widget build(BuildContext context) {
    return BlockActionButton(
      svg: FlowySvgs.add_s,
      richMessage: TextSpan(
        children: [
          TextSpan(
            text: '点击下方添加',
            style: context.tooltipTextStyle(),
          ),
          const TextSpan(text: '\n'),
          TextSpan(
            text: Platform.isMacOS
                ? '+单击'
                : 'Alt+单击',
            style: context.tooltipTextStyle(),
          ),
          const TextSpan(text: ' '),
          TextSpan(
            text: '添加上面',
            style: context.tooltipTextStyle(),
          ),
        ],
      ),
      onTap: () {
        final isAltPressed = HardwareKeyboard.instance.isAltPressed;

        final transaction = editorState.transaction;

        // If the current block is not an empty paragraph block,
        // then insert a new block above/below the current block.
        final node = blockComponentContext.node;
        if (node.type != ParagraphBlockKeys.type ||
            (node.delta?.isNotEmpty ?? true)) {
          final path = isAltPressed ? node.path : node.path.next;

          transaction.insertNode(path, paragraphNode());
          transaction.afterSelection = Selection.collapsed(
            Position(path: path),
          );
        } else {
          transaction.afterSelection = Selection.collapsed(
            Position(path: node.path),
          );
        }

        // show the slash menu.
        editorState.apply(transaction).then(
              (_) => WidgetsBinding.instance.addPostFrameCallback(
                (_) => showSlashMenu(),
              ),
            );
      },
    );
  }
}
