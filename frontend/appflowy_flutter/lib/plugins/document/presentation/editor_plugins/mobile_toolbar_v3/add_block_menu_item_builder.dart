import 'dart:async';

import 'package:appflowy/generated/flowy_svgs.g.dart';
import 'package:appflowy/mobile/presentation/base/type_option_menu_item.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/image/image_placeholder.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/image/multi_image_block_component/multi_image_placeholder.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/mention/mention_page_block.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/mention/mobile_page_selector_sheet.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/mobile_toolbar_item/mobile_add_block_toolbar_item.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/plugins.dart';
import 'package:appflowy/startup/startup.dart';
import 'package:appflowy/startup/tasks/app_widget.dart';
import 'package:appflowy/workspace/presentation/home/menu/menu_shared_state.dart';
import 'package:appflowy_editor/appflowy_editor.dart'
    hide QuoteBlockComponentBuilder, quoteNode, QuoteBlockKeys;
import 'package:appflowy_editor_plugins/appflowy_editor_plugins.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddBlockMenuItemBuilder {
  AddBlockMenuItemBuilder({
    required this.editorState,
    required this.selection,
  });

  final EditorState editorState;
  final Selection selection;

  List<TypeOptionMenuItemValue<String>> buildTypeOptionMenuItemValues(
    BuildContext context,
  ) {
    if (selection.isCollapsed) {
      final node = editorState.getNodeAtPath(selection.end.path);
      if (node?.parentTableCellNode != null) {
        return _buildTableTypeOptionMenuItemValues(context);
      }
    }
    return _buildDefaultTypeOptionMenuItemValues(context);
  }

  /// Build the default type option menu item values.

  List<TypeOptionMenuItemValue<String>> _buildDefaultTypeOptionMenuItemValues(
    BuildContext context,
  ) {
    final colorMap = _colorMap(context);
    return [
      ..._buildHeadingMenuItems(colorMap),
      ..._buildParagraphMenuItems(colorMap),
      ..._buildTodoListMenuItems(colorMap),
      ..._buildTableMenuItems(colorMap),
      ..._buildQuoteMenuItems(colorMap),
      ..._buildListMenuItems(colorMap),
      ..._buildToggleHeadingMenuItems(colorMap),
      ..._buildImageMenuItems(colorMap),
      ..._buildPhotoGalleryMenuItems(colorMap),
      ..._buildFileMenuItems(colorMap),
      ..._buildMentionMenuItems(context, colorMap),
      ..._buildDividerMenuItems(colorMap),
      ..._buildCalloutMenuItems(colorMap),
      ..._buildCodeMenuItems(colorMap),
      ..._buildMathEquationMenuItems(colorMap),
    ];
  }

  /// Build the table type option menu item values.
  List<TypeOptionMenuItemValue<String>> _buildTableTypeOptionMenuItemValues(
    BuildContext context,
  ) {
    final colorMap = _colorMap(context);
    return [
      ..._buildHeadingMenuItems(colorMap),
      ..._buildParagraphMenuItems(colorMap),
      ..._buildTodoListMenuItems(colorMap),
      ..._buildQuoteMenuItems(colorMap),
      ..._buildListMenuItems(colorMap),
      ..._buildToggleHeadingMenuItems(colorMap),
      ..._buildImageMenuItems(colorMap),
      ..._buildFileMenuItems(colorMap),
      ..._buildMentionMenuItems(context, colorMap),
      ..._buildDividerMenuItems(colorMap),
      ..._buildCalloutMenuItems(colorMap),
      ..._buildCodeMenuItems(colorMap),
      ..._buildMathEquationMenuItems(colorMap),
    ];
  }

  List<TypeOptionMenuItemValue<String>> _buildHeadingMenuItems(
    Map<String, Color> colorMap,
  ) {
    return [
      TypeOptionMenuItemValue(
        value: HeadingBlockKeys.type,
        backgroundColor: colorMap[HeadingBlockKeys.type]!,
        text: '一级标题',
        icon: FlowySvgs.m_add_block_h1_s,
        onTap: (_, __) => _insertBlock(headingNode(level: 1)),
      ),
      TypeOptionMenuItemValue(
        value: HeadingBlockKeys.type,
        backgroundColor: colorMap[HeadingBlockKeys.type]!,
        text: '二级标题',
        icon: FlowySvgs.m_add_block_h2_s,
        onTap: (_, __) => _insertBlock(headingNode(level: 2)),
      ),
      TypeOptionMenuItemValue(
        value: HeadingBlockKeys.type,
        backgroundColor: colorMap[HeadingBlockKeys.type]!,
        text: '三级标题',
        icon: FlowySvgs.m_add_block_h3_s,
        onTap: (_, __) => _insertBlock(headingNode(level: 3)),
      ),
    ];
  }

  List<TypeOptionMenuItemValue<String>> _buildParagraphMenuItems(
    Map<String, Color> colorMap,
  ) {
    return [
      TypeOptionMenuItemValue(
        value: ParagraphBlockKeys.type,
        backgroundColor: colorMap[ParagraphBlockKeys.type]!,
        text: '文本',
        icon: FlowySvgs.m_add_block_paragraph_s,
        onTap: (_, __) => _insertBlock(paragraphNode()),
      ),
    ];
  }

  List<TypeOptionMenuItemValue<String>> _buildTodoListMenuItems(
    Map<String, Color> colorMap,
  ) {
    return [
      TypeOptionMenuItemValue(
        value: TodoListBlockKeys.type,
        backgroundColor: colorMap[TodoListBlockKeys.type]!,
        text: '复选框',
        icon: FlowySvgs.m_add_block_checkbox_s,
        onTap: (_, __) => _insertBlock(todoListNode(checked: false)),
      ),
    ];
  }

  List<TypeOptionMenuItemValue<String>> _buildTableMenuItems(
    Map<String, Color> colorMap,
  ) {
    return [
      TypeOptionMenuItemValue(
        value: SimpleTableBlockKeys.type,
        backgroundColor: colorMap[SimpleTableBlockKeys.type]!,
        text: '表格',
        icon: FlowySvgs.slash_menu_icon_simple_table_s,
        onTap: (_, __) => _insertBlock(
          createSimpleTableBlockNode(columnCount: 2, rowCount: 2),
        ),
      ),
    ];
  }

  List<TypeOptionMenuItemValue<String>> _buildQuoteMenuItems(
    Map<String, Color> colorMap,
  ) {
    return [
      TypeOptionMenuItemValue(
        value: QuoteBlockKeys.type,
        backgroundColor: colorMap[QuoteBlockKeys.type]!,
        text: '引用',
        icon: FlowySvgs.m_add_block_quote_s,
        onTap: (_, __) => _insertBlock(quoteNode()),
      ),
    ];
  }

  List<TypeOptionMenuItemValue<String>> _buildListMenuItems(
    Map<String, Color> colorMap,
  ) {
    return [
      // bulleted list, numbered list, toggle list
      TypeOptionMenuItemValue(
        value: BulletedListBlockKeys.type,
        backgroundColor: colorMap[BulletedListBlockKeys.type]!,
        text: '项目符号',
        icon: FlowySvgs.m_add_block_bulleted_list_s,
        onTap: (_, __) => _insertBlock(bulletedListNode()),
      ),
      TypeOptionMenuItemValue(
        value: NumberedListBlockKeys.type,
        backgroundColor: colorMap[NumberedListBlockKeys.type]!,
        text: '编号',
        icon: FlowySvgs.m_add_block_numbered_list_s,
        onTap: (_, __) => _insertBlock(numberedListNode()),
      ),
      TypeOptionMenuItemValue(
        value: ToggleListBlockKeys.type,
        backgroundColor: colorMap[ToggleListBlockKeys.type]!,
        text: '切换',
        icon: FlowySvgs.m_add_block_toggle_s,
        onTap: (_, __) => _insertBlock(toggleListBlockNode()),
      ),
    ];
  }

  List<TypeOptionMenuItemValue<String>> _buildToggleHeadingMenuItems(
    Map<String, Color> colorMap,
  ) {
    return [
      TypeOptionMenuItemValue(
        value: ToggleListBlockKeys.type,
        backgroundColor: colorMap[ToggleListBlockKeys.type]!,
        text: '切换标题 1',
        icon: FlowySvgs.toggle_heading1_s,
        iconPadding: const EdgeInsets.all(3),
        onTap: (_, __) => _insertBlock(toggleHeadingNode()),
      ),
      TypeOptionMenuItemValue(
        value: ToggleListBlockKeys.type,
        backgroundColor: colorMap[ToggleListBlockKeys.type]!,
        text: '切换标题 2',
        icon: FlowySvgs.toggle_heading2_s,
        iconPadding: const EdgeInsets.all(3),
        onTap: (_, __) => _insertBlock(toggleHeadingNode(level: 2)),
      ),
      TypeOptionMenuItemValue(
        value: ToggleListBlockKeys.type,
        backgroundColor: colorMap[ToggleListBlockKeys.type]!,
        text: '切换标题 3',
        icon: FlowySvgs.toggle_heading3_s,
        iconPadding: const EdgeInsets.all(3),
        onTap: (_, __) => _insertBlock(toggleHeadingNode(level: 3)),
      ),
    ];
  }

  List<TypeOptionMenuItemValue<String>> _buildImageMenuItems(
    Map<String, Color> colorMap,
  ) {
    return [
      TypeOptionMenuItemValue(
        value: ImageBlockKeys.type,
        backgroundColor: colorMap[ImageBlockKeys.type]!,
        text: '图像',
        icon: FlowySvgs.m_add_block_image_s,
        onTap: (_, __) async {
          AppGlobals.rootNavKey.currentContext?.pop(true);
          Future.delayed(const Duration(milliseconds: 400), () async {
            final imagePlaceholderKey = GlobalKey<ImagePlaceholderState>();
            await editorState.insertEmptyImageBlock(imagePlaceholderKey);
          });
        },
      ),
    ];
  }

  List<TypeOptionMenuItemValue<String>> _buildPhotoGalleryMenuItems(
    Map<String, Color> colorMap,
  ) {
    return [
      TypeOptionMenuItemValue(
        value: MultiImageBlockKeys.type,
        backgroundColor: colorMap[ImageBlockKeys.type]!,
        text: '照片库',
        icon: FlowySvgs.m_add_block_photo_gallery_s,
        onTap: (_, __) async {
          AppGlobals.rootNavKey.currentContext?.pop(true);
          Future.delayed(const Duration(milliseconds: 400), () async {
            final imagePlaceholderKey = GlobalKey<MultiImagePlaceholderState>();
            await editorState.insertEmptyMultiImageBlock(imagePlaceholderKey);
          });
        },
      ),
    ];
  }

  List<TypeOptionMenuItemValue<String>> _buildFileMenuItems(
    Map<String, Color> colorMap,
  ) {
    return [
      TypeOptionMenuItemValue(
        value: FileBlockKeys.type,
        backgroundColor: colorMap[ImageBlockKeys.type]!,
        text: '文件',
        icon: FlowySvgs.media_s,
        onTap: (_, __) async {
          AppGlobals.rootNavKey.currentContext?.pop(true);
          Future.delayed(const Duration(milliseconds: 400), () async {
            final fileGlobalKey = GlobalKey<FileBlockComponentState>();
            await editorState.insertEmptyFileBlock(fileGlobalKey);
          });
        },
      ),
    ];
  }

  List<TypeOptionMenuItemValue<String>> _buildMentionMenuItems(
    BuildContext context,
    Map<String, Color> colorMap,
  ) {
    return [
      TypeOptionMenuItemValue(
        value: ParagraphBlockKeys.type,
        backgroundColor: colorMap[MentionBlockKeys.type]!,
        text: '日期',
        icon: FlowySvgs.m_add_block_date_s,
        onTap: (_, __) => _insertBlock(dateMentionNode()),
      ),
      TypeOptionMenuItemValue(
        value: ParagraphBlockKeys.type,
        backgroundColor: colorMap[MentionBlockKeys.type]!,
        text: '页面',
        icon: FlowySvgs.icon_document_s,
        onTap: (_, __) async {
          AppGlobals.rootNavKey.currentContext?.pop(true);

          final currentViewId = getIt<MenuSharedState>().latestOpenView?.id;
          final view = await showPageSelectorSheet(
            context,
            currentViewId: currentViewId,
          );

          if (view != null) {
            Future.delayed(const Duration(milliseconds: 100), () {
              editorState.insertBlockAfterCurrentSelection(
                selection,
                pageMentionNode(view.id),
              );
            });
          }
        },
      ),
    ];
  }

  List<TypeOptionMenuItemValue<String>> _buildDividerMenuItems(
    Map<String, Color> colorMap,
  ) {
    return [
      TypeOptionMenuItemValue(
        value: DividerBlockKeys.type,
        backgroundColor: colorMap[DividerBlockKeys.type]!,
        text: '分隔线',
        icon: FlowySvgs.m_add_block_divider_s,
        onTap: (_, __) {
          AppGlobals.rootNavKey.currentContext?.pop(true);
          Future.delayed(const Duration(milliseconds: 100), () {
            editorState.insertDivider(selection);
          });
        },
      ),
    ];
  }

  // callout, code, math equation
  List<TypeOptionMenuItemValue<String>> _buildCalloutMenuItems(
    Map<String, Color> colorMap,
  ) {
    return [
      TypeOptionMenuItemValue(
        value: CalloutBlockKeys.type,
        backgroundColor: colorMap[CalloutBlockKeys.type]!,
        text: '标注',
        icon: FlowySvgs.m_add_block_callout_s,
        onTap: (_, __) => _insertBlock(calloutNode()),
      ),
    ];
  }

  List<TypeOptionMenuItemValue<String>> _buildCodeMenuItems(
    Map<String, Color> colorMap,
  ) {
    return [
      TypeOptionMenuItemValue(
        value: CodeBlockKeys.type,
        backgroundColor: colorMap[CodeBlockKeys.type]!,
        text: '代码',
        icon: FlowySvgs.m_add_block_code_s,
        onTap: (_, __) => _insertBlock(codeBlockNode()),
      ),
    ];
  }

  List<TypeOptionMenuItemValue<String>> _buildMathEquationMenuItems(
    Map<String, Color> colorMap,
  ) {
    return [
      TypeOptionMenuItemValue(
        value: MathEquationBlockKeys.type,
        backgroundColor: colorMap[MathEquationBlockKeys.type]!,
        text: '公式',
        icon: FlowySvgs.m_add_block_formula_s,
        onTap: (_, __) {
          AppGlobals.rootNavKey.currentContext?.pop(true);
          Future.delayed(const Duration(milliseconds: 100), () {
            editorState.insertMathEquation(selection);
          });
        },
      ),
    ];
  }

  Map<String, Color> _colorMap(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    if (isDarkMode) {
      return {
        HeadingBlockKeys.type: const Color(0xFF5465A1),
        ParagraphBlockKeys.type: const Color(0xFF5465A1),
        TodoListBlockKeys.type: const Color(0xFF4BB299),
        SimpleTableBlockKeys.type: const Color(0xFF4BB299),
        QuoteBlockKeys.type: const Color(0xFFBAAC74),
        BulletedListBlockKeys.type: const Color(0xFFA35F94),
        NumberedListBlockKeys.type: const Color(0xFFA35F94),
        ToggleListBlockKeys.type: const Color(0xFFA35F94),
        ImageBlockKeys.type: const Color(0xFFBAAC74),
        MentionBlockKeys.type: const Color(0xFF40AAB8),
        DividerBlockKeys.type: const Color(0xFF4BB299),
        CalloutBlockKeys.type: const Color(0xFF66599B),
        CodeBlockKeys.type: const Color(0xFF66599B),
        MathEquationBlockKeys.type: const Color(0xFF66599B),
      };
    }
    return {
      HeadingBlockKeys.type: const Color(0xFFBECCFF),
      ParagraphBlockKeys.type: const Color(0xFFBECCFF),
      TodoListBlockKeys.type: const Color(0xFF98F4CD),
      SimpleTableBlockKeys.type: const Color(0xFF98F4CD),
      QuoteBlockKeys.type: const Color(0xFFFDEDA7),
      BulletedListBlockKeys.type: const Color(0xFFFFB9EF),
      NumberedListBlockKeys.type: const Color(0xFFFFB9EF),
      ToggleListBlockKeys.type: const Color(0xFFFFB9EF),
      ImageBlockKeys.type: const Color(0xFFFDEDA7),
      MentionBlockKeys.type: const Color(0xFF91EAF5),
      DividerBlockKeys.type: const Color(0xFF98F4CD),
      CalloutBlockKeys.type: const Color(0xFFCABDFF),
      CodeBlockKeys.type: const Color(0xFFCABDFF),
      MathEquationBlockKeys.type: const Color(0xFFCABDFF),
    };
  }

  Future<void> _insertBlock(Node node) async {
    AppGlobals.rootNavKey.currentContext?.pop(true);
    Future.delayed(
      const Duration(milliseconds: 100),
      () async {
        // if current selected block is a empty paragraph block, replace it with the new block.
        if (selection.isCollapsed) {
          final currentNode = editorState.getNodeAtPath(selection.end.path);
          final text = currentNode?.delta?.toPlainText();
          if (currentNode != null &&
              currentNode.type == ParagraphBlockKeys.type &&
              text != null &&
              text.isEmpty) {
            final transaction = editorState.transaction;
            transaction.insertNode(
              selection.end.path.next,
              node,
            );
            transaction.deleteNode(currentNode);
            if (node.type == SimpleTableBlockKeys.type) {
              transaction.afterSelection = Selection.collapsed(
                Position(
                  // table -> row -> cell -> paragraph
                  path: selection.end.path + [0, 0, 0],
                ),
              );
            } else {
              transaction.afterSelection = Selection.collapsed(
                Position(path: selection.end.path),
              );
            }
            transaction.selectionExtraInfo = {};
            await editorState.apply(transaction);
            return;
          }
        }

        await editorState.insertBlockAfterCurrentSelection(selection, node);
      },
    );
  }
}
