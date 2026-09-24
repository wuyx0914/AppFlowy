import 'package:appflowy/generated/flowy_svgs.g.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/plugins.dart';
import 'package:appflowy_editor/appflowy_editor.dart'
    hide QuoteBlockKeys, quoteNode;

export 'align_option_action.dart';
export 'color_option_action.dart';
export 'depth_option_action.dart';
export 'divider_option_action.dart';
export 'turn_into_option_action.dart';

enum EditorOptionActionType {
  turnInto,
  color,
  align,
  depth;

  Set<String> get supportTypes {
    switch (this) {
      case EditorOptionActionType.turnInto:
        return {
          ParagraphBlockKeys.type,
          HeadingBlockKeys.type,
          QuoteBlockKeys.type,
          CalloutBlockKeys.type,
          BulletedListBlockKeys.type,
          NumberedListBlockKeys.type,
          TodoListBlockKeys.type,
          ToggleListBlockKeys.type,
          SubPageBlockKeys.type,
        };
      case EditorOptionActionType.color:
        return {
          ParagraphBlockKeys.type,
          HeadingBlockKeys.type,
          BulletedListBlockKeys.type,
          NumberedListBlockKeys.type,
          QuoteBlockKeys.type,
          TodoListBlockKeys.type,
          CalloutBlockKeys.type,
          OutlineBlockKeys.type,
          ToggleListBlockKeys.type,
        };
      case EditorOptionActionType.align:
        return {
          ImageBlockKeys.type,
          SimpleTableBlockKeys.type,
        };
      case EditorOptionActionType.depth:
        return {
          OutlineBlockKeys.type,
        };
    }
  }
}

enum OptionAction {
  delete,
  duplicate,
  turnInto,
  moveUp,
  moveDown,
  copyLinkToBlock,

  /// callout background color
  color,
  divider,
  align,

  // Outline block
  depth,

  // Simple table
  setToPageWidth,
  distributeColumnsEvenly;

  FlowySvgData get svg {
    switch (this) {
      case OptionAction.delete:
        return FlowySvgs.trash_s;
      case OptionAction.duplicate:
        return FlowySvgs.copy_s;
      case OptionAction.turnInto:
        return FlowySvgs.turninto_s;
      case OptionAction.moveUp:
        return const FlowySvgData('editor/move_up');
      case OptionAction.moveDown:
        return const FlowySvgData('editor/move_down');
      case OptionAction.color:
        return const FlowySvgData('editor/color');
      case OptionAction.divider:
        return const FlowySvgData('editor/divider');
      case OptionAction.align:
        return FlowySvgs.m_aa_bulleted_list_s;
      case OptionAction.depth:
        return FlowySvgs.tag_s;
      case OptionAction.copyLinkToBlock:
        return FlowySvgs.share_tab_copy_s;
      case OptionAction.setToPageWidth:
        return FlowySvgs.table_set_to_page_width_s;
      case OptionAction.distributeColumnsEvenly:
        return FlowySvgs.table_distribute_columns_evenly_s;
    }
  }

  String get description {
    switch (this) {
      case OptionAction.delete:
        return '删除';
      case OptionAction.duplicate:
        return '复制';
      case OptionAction.turnInto:
        return '变成';
      case OptionAction.moveUp:
        return '上移';
      case OptionAction.moveDown:
        return '下移';
      case OptionAction.color:
        return '颜色';
      case OptionAction.align:
        return '对齐';
      case OptionAction.depth:
        return '深度';
      case OptionAction.copyLinkToBlock:
        return '粘贴块链接';
      case OptionAction.divider:
        throw UnsupportedError('Divider does not have description');
      case OptionAction.setToPageWidth:
        return '设置为页面宽度';
      case OptionAction.distributeColumnsEvenly:
        return '平均分配字段';
    }
  }
}
