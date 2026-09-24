import 'package:appflowy/generated/flowy_svgs.g.dart';
import 'package:flutter/material.dart';

enum SpaceMoreActionType {
  delete,
  rename,
  changeIcon,
  collapseAllPages,
  divider,
  addNewSpace,
  manage,
  duplicate,
}

extension ViewMoreActionTypeExtension on SpaceMoreActionType {
  String get name {
    switch (this) {
      case SpaceMoreActionType.delete:
        return '删除';
      case SpaceMoreActionType.rename:
        return '重命名空间';
      case SpaceMoreActionType.changeIcon:
        return '变更图标';
      case SpaceMoreActionType.collapseAllPages:
        return '折叠所有子页面';
      case SpaceMoreActionType.addNewSpace:
        return '创建空间';
      case SpaceMoreActionType.manage:
        return '管理空间';
      case SpaceMoreActionType.duplicate:
        return '副本空间';
      case SpaceMoreActionType.divider:
        return '';
    }
  }

  FlowySvgData get leftIconSvg {
    switch (this) {
      case SpaceMoreActionType.delete:
        return FlowySvgs.trash_s;
      case SpaceMoreActionType.rename:
        return FlowySvgs.view_item_rename_s;
      case SpaceMoreActionType.changeIcon:
        return FlowySvgs.change_icon_s;
      case SpaceMoreActionType.collapseAllPages:
        return FlowySvgs.collapse_all_page_s;
      case SpaceMoreActionType.addNewSpace:
        return FlowySvgs.space_add_s;
      case SpaceMoreActionType.manage:
        return FlowySvgs.space_manage_s;
      case SpaceMoreActionType.duplicate:
        return FlowySvgs.duplicate_s;
      case SpaceMoreActionType.divider:
        throw UnsupportedError('Divider does not have an icon');
    }
  }

  Widget get rightIcon {
    switch (this) {
      case SpaceMoreActionType.changeIcon:
      case SpaceMoreActionType.rename:
      case SpaceMoreActionType.collapseAllPages:
      case SpaceMoreActionType.divider:
      case SpaceMoreActionType.delete:
      case SpaceMoreActionType.addNewSpace:
      case SpaceMoreActionType.manage:
      case SpaceMoreActionType.duplicate:
        return const SizedBox.shrink();
    }
  }
}
