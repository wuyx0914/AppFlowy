import 'dart:io';

import 'package:appflowy/plugins/document/presentation/editor_plugins/plugins.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

List<ContextMenuButtonItem> buildMobileFloatingToolbarItems(
  EditorState editorState,
  Offset offset,
  Function closeToolbar,
) {
  // copy, paste, select, select all, cut
  final selection = editorState.selection;
  if (selection == null) {
    return [];
  }
  final toolbarItems = <ContextMenuButtonItem>[];

  if (!selection.isCollapsed) {
    toolbarItems.add(
      ContextMenuButtonItem(
        label: '复制',
        onPressed: () {
          customCopyCommand.execute(editorState);
          closeToolbar();
        },
      ),
    );
  }

  toolbarItems.add(
    ContextMenuButtonItem(
      label: '粘贴',
      onPressed: () {
        customPasteCommand.execute(editorState);
        closeToolbar();
      },
    ),
  );

  if (!selection.isCollapsed) {
    toolbarItems.add(
      ContextMenuButtonItem(
        label: '剪切',
        onPressed: () {
          cutCommand.execute(editorState);
          closeToolbar();
        },
      ),
    );
  }

  toolbarItems.add(
    ContextMenuButtonItem(
      label: '选择',
      onPressed: () {
        editorState.selectWord(offset);
        closeToolbar();
      },
    ),
  );

  toolbarItems.add(
    ContextMenuButtonItem(
      label: '全选',
      onPressed: () {
        selectAllCommand.execute(editorState);
        closeToolbar();
      },
    ),
  );

  return toolbarItems;
}

extension on EditorState {
  void selectWord(Offset offset) {
    final node = service.selectionService.getNodeInOffset(offset);
    final selection = node?.selectable?.getWordBoundaryInOffset(offset);
    if (selection == null) {
      return;
    }
    updateSelectionWithReason(selection);
  }
}

class CustomMobileFloatingToolbar extends StatelessWidget {
  const CustomMobileFloatingToolbar({
    super.key,
    required this.editorState,
    required this.anchor,
    required this.closeToolbar,
  });

  final EditorState editorState;
  final Offset anchor;
  final VoidCallback closeToolbar;

  @override
  Widget build(BuildContext context) {
    return Animate(
      autoPlay: true,
      effects: _getEffects(context),
      child: AdaptiveTextSelectionToolbar.buttonItems(
        buttonItems: buildMobileFloatingToolbarItems(
          editorState,
          anchor,
          closeToolbar,
        ),
        anchors: TextSelectionToolbarAnchors(
          primaryAnchor: anchor,
        ),
      ),
    );
  }

  List<Effect> _getEffects(BuildContext context) {
    if (Platform.isIOS) {
      final Size(:width, :height) = MediaQuery.of(context).size;
      final alignmentX = (anchor.dx - width / 2) / (width / 2);
      final alignmentY = (anchor.dy - height / 2) / (height / 2);
      return [
        ScaleEffect(
          curve: Curves.easeInOut,
          alignment: Alignment(alignmentX, alignmentY),
          duration: 250.milliseconds,
        ),
      ];
    } else if (Platform.isAndroid) {
      return [
        const FadeEffect(
          duration: SelectionOverlay.fadeDuration,
        ),
        MoveEffect(
          curve: Curves.easeOutCubic,
          begin: const Offset(0, 16),
          duration: 100.milliseconds,
        ),
      ];
    } else {
      return [];
    }
  }
}
