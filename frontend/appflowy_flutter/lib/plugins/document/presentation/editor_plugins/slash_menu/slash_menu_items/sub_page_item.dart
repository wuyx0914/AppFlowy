import 'package:appflowy/generated/flowy_svgs.g.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/base/selectable_svg_widget.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/plugins.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/shared_context/shared_context.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'slash_menu_items.dart';

final _keywords = [
  '子页面',
  '页面',
  '子页面',
  '插入页面',
  '嵌入页面',
  '新页面',
  '创建页面',
  '文档',
];

// Sub-page menu item
SelectionMenuItem subPageSlashMenuItem = buildSubpageSlashMenuItem();

SelectionMenuItem buildSubpageSlashMenuItem({FlowySvgData? svg}) =>
    SelectionMenuItem.node(
      getName: () => '文档',
      keywords: _keywords,
      updateSelection: (editorState, path, __, ___) {
        final context = editorState.document.root.context;
        if (context != null) {
          final isInDatabase =
              context.read<SharedEditorContext>().isInDatabaseRowPage;
          if (isInDatabase) {
            Navigator.of(context).pop();
          }
        }
        return Selection.collapsed(Position(path: path));
      },
      replace: (_, node) => node.delta?.isEmpty ?? false,
      nodeBuilder: (_, __) => subPageNode(),
      nameBuilder: slashMenuItemNameBuilder,
      iconBuilder: (_, isSelected, style) => SelectableSvgWidget(
        data: svg ?? FlowySvgs.insert_document_s,
        isSelected: isSelected,
        style: style,
      ),
    );
