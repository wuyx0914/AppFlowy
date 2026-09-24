import 'package:appflowy/generated/flowy_svgs.g.dart';
import 'package:flutter/material.dart';

enum ViewMoreActionType {
  delete,
  favorite,
  unFavorite,
  duplicate,
  copyLink, // not supported yet.
  rename,
  moveTo,
  openInNewTab,
  changeIcon,
  collapseAllPages, // including sub pages
  divider,
  lastModified,
  created,
  lockPage,
  leaveSharedPage;

  static const disableInLockedView = [
    delete,
    rename,
    moveTo,
    changeIcon,
  ];
}

extension ViewMoreActionTypeExtension on ViewMoreActionType {
  String get name {
    switch (this) {
      case ViewMoreActionType.delete:
        return '删除';
      case ViewMoreActionType.favorite:
        return '添加到收藏夹';
      case ViewMoreActionType.unFavorite:
        return '从收藏夹中删除';
      case ViewMoreActionType.duplicate:
        return '复制';
      case ViewMoreActionType.copyLink:
        return '复制链接';
      case ViewMoreActionType.rename:
        return '重命名';
      case ViewMoreActionType.moveTo:
        return '移动';
      case ViewMoreActionType.openInNewTab:
        return '在新选项卡中打开';
      case ViewMoreActionType.changeIcon:
        return '更改图标';
      case ViewMoreActionType.collapseAllPages:
        return '收起全部子页面';
      case ViewMoreActionType.lockPage:
        return '锁定页面';
      case ViewMoreActionType.leaveSharedPage:
        return 'Leave';
      case ViewMoreActionType.divider:
      case ViewMoreActionType.lastModified:
      case ViewMoreActionType.created:
        return '';
    }
  }

  FlowySvgData get leftIconSvg {
    switch (this) {
      case ViewMoreActionType.delete:
        return FlowySvgs.trash_s;
      case ViewMoreActionType.favorite:
        return FlowySvgs.favorite_s;
      case ViewMoreActionType.unFavorite:
        return FlowySvgs.unfavorite_s;
      case ViewMoreActionType.duplicate:
        return FlowySvgs.duplicate_s;
      case ViewMoreActionType.rename:
        return FlowySvgs.view_item_rename_s;
      case ViewMoreActionType.moveTo:
        return FlowySvgs.move_to_s;
      case ViewMoreActionType.openInNewTab:
        return FlowySvgs.view_item_open_in_new_tab_s;
      case ViewMoreActionType.changeIcon:
        return FlowySvgs.change_icon_s;
      case ViewMoreActionType.collapseAllPages:
        return FlowySvgs.collapse_all_page_s;
      case ViewMoreActionType.lockPage:
        return FlowySvgs.lock_page_s;
      case ViewMoreActionType.leaveSharedPage:
        return FlowySvgs.leave_workspace_s;
      case ViewMoreActionType.divider:
      case ViewMoreActionType.lastModified:
      case ViewMoreActionType.copyLink:
      case ViewMoreActionType.created:
        throw UnsupportedError('No left icon for $this');
    }
  }

  Widget get rightIcon {
    switch (this) {
      case ViewMoreActionType.changeIcon:
      case ViewMoreActionType.moveTo:
      case ViewMoreActionType.favorite:
      case ViewMoreActionType.unFavorite:
      case ViewMoreActionType.duplicate:
      case ViewMoreActionType.copyLink:
      case ViewMoreActionType.rename:
      case ViewMoreActionType.openInNewTab:
      case ViewMoreActionType.collapseAllPages:
      case ViewMoreActionType.divider:
      case ViewMoreActionType.delete:
      case ViewMoreActionType.lastModified:
      case ViewMoreActionType.created:
      case ViewMoreActionType.lockPage:
      case ViewMoreActionType.leaveSharedPage:
        return const SizedBox.shrink();
    }
  }
}
