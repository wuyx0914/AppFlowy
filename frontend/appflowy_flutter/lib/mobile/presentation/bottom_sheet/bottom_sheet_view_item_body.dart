import 'package:appflowy/features/page_access_level/logic/page_access_level_bloc.dart';
import 'package:appflowy/generated/flowy_svgs.g.dart';
import 'package:appflowy/mobile/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum MobileViewItemBottomSheetBodyAction {
  rename,
  duplicate,
  share,
  delete,
  addToFavorites,
  removeFromFavorites,
  divider,
  removeFromRecent,
}

class MobileViewItemBottomSheetBody extends StatelessWidget {
  const MobileViewItemBottomSheetBody({
    super.key,
    this.isFavorite = false,
    required this.onAction,
    required this.actions,
  });

  final bool isFavorite;
  final void Function(MobileViewItemBottomSheetBodyAction action) onAction;
  final List<MobileViewItemBottomSheetBodyAction> actions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children:
          actions.map((action) => _buildActionButton(context, action)).toList(),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    MobileViewItemBottomSheetBodyAction action,
  ) {
    final isLocked =
        context.read<PageAccessLevelBloc?>()?.state.isLocked ?? false;
    switch (action) {
      case MobileViewItemBottomSheetBodyAction.rename:
        return FlowyOptionTile.text(
          text: '重命名',
          height: 52.0,
          leftIcon: const FlowySvg(
            FlowySvgs.view_item_rename_s,
            size: Size.square(18),
          ),
          enable: !isLocked,
          showTopBorder: false,
          showBottomBorder: false,
          onTap: () => onAction(
            MobileViewItemBottomSheetBodyAction.rename,
          ),
        );
      case MobileViewItemBottomSheetBodyAction.duplicate:
        return FlowyOptionTile.text(
          text: '复制',
          height: 52.0,
          leftIcon: const FlowySvg(
            FlowySvgs.duplicate_s,
            size: Size.square(18),
          ),
          showTopBorder: false,
          showBottomBorder: false,
          onTap: () => onAction(
            MobileViewItemBottomSheetBodyAction.duplicate,
          ),
        );

      case MobileViewItemBottomSheetBodyAction.share:
        return FlowyOptionTile.text(
          text: '分享',
          height: 52.0,
          leftIcon: const FlowySvg(
            FlowySvgs.share_s,
            size: Size.square(18),
          ),
          showTopBorder: false,
          showBottomBorder: false,
          onTap: () => onAction(
            MobileViewItemBottomSheetBodyAction.share,
          ),
        );
      case MobileViewItemBottomSheetBodyAction.delete:
        return FlowyOptionTile.text(
          text: '删除',
          height: 52.0,
          textColor: Theme.of(context).colorScheme.error,
          leftIcon: FlowySvg(
            FlowySvgs.trash_s,
            size: const Size.square(18),
            color: Theme.of(context).colorScheme.error,
          ),
          enable: !isLocked,
          showTopBorder: false,
          showBottomBorder: false,
          onTap: () => onAction(
            MobileViewItemBottomSheetBodyAction.delete,
          ),
        );
      case MobileViewItemBottomSheetBodyAction.addToFavorites:
        return FlowyOptionTile.text(
          height: 52.0,
          text: '添加到收藏夹',
          leftIcon: const FlowySvg(
            FlowySvgs.favorite_s,
            size: Size.square(18),
          ),
          showTopBorder: false,
          showBottomBorder: false,
          onTap: () => onAction(
            MobileViewItemBottomSheetBodyAction.addToFavorites,
          ),
        );
      case MobileViewItemBottomSheetBodyAction.removeFromFavorites:
        return FlowyOptionTile.text(
          height: 52.0,
          text: '从收藏夹中',
          leftIcon: const FlowySvg(
            FlowySvgs.favorite_section_remove_from_favorite_s,
            size: Size.square(18),
          ),
          showTopBorder: false,
          showBottomBorder: false,
          onTap: () => onAction(
            MobileViewItemBottomSheetBodyAction.removeFromFavorites,
          ),
        );
      case MobileViewItemBottomSheetBodyAction.removeFromRecent:
        return FlowyOptionTile.text(
          height: 52.0,
          text: '从最近页移除',
          leftIcon: const FlowySvg(
            FlowySvgs.remove_from_recent_s,
            size: Size.square(18),
          ),
          showTopBorder: false,
          showBottomBorder: false,
          onTap: () => onAction(
            MobileViewItemBottomSheetBodyAction.removeFromRecent,
          ),
        );

      case MobileViewItemBottomSheetBodyAction.divider:
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0),
          child: Divider(height: 0.5),
        );
    }
  }
}
