import 'package:appflowy/features/page_access_level/logic/page_access_level_bloc.dart';
import 'package:appflowy/generated/flowy_svgs.g.dart';
import 'package:appflowy/mobile/application/base/mobile_view_page_bloc.dart';
import 'package:appflowy/mobile/presentation/bottom_sheet/bottom_sheet.dart';
import 'package:appflowy/mobile/presentation/widgets/flowy_mobile_quick_action_button.dart';
import 'package:appflowy/plugins/shared/share/share_bloc.dart';
import 'package:appflowy/workspace/application/view/view_ext.dart';
import 'package:appflowy_backend/protobuf/flowy-folder/view.pb.dart';
import 'package:appflowy_backend/protobuf/flowy-user/protobuf.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum MobileViewBottomSheetBodyAction {
  undo,
  redo,
  rename,
  duplicate,
  delete,
  addToFavorites,
  removeFromFavorites,
  helpCenter,
  publish,
  unpublish,
  copyPublishLink,
  visitSite,
  copyShareLink,
  updatePathName,
  lockPage;

  static const disableInLockedView = [
    undo,
    redo,
    rename,
    delete,
  ];
}

class MobileViewBottomSheetBodyActionArguments {
  static const isLockedKey = 'is_locked';
}

typedef MobileViewBottomSheetBodyActionCallback = void Function(
  MobileViewBottomSheetBodyAction action,
  // for the [MobileViewBottomSheetBodyAction.lockPage] action,
  // it will pass the [isLocked] value to the callback.
  {
  Map<String, dynamic>? arguments,
});

class ViewPageBottomSheet extends StatefulWidget {
  const ViewPageBottomSheet({
    super.key,
    required this.view,
    required this.onAction,
    required this.onRename,
  });

  final ViewPB view;
  final MobileViewBottomSheetBodyActionCallback onAction;
  final void Function(String name) onRename;

  @override
  State<ViewPageBottomSheet> createState() => _ViewPageBottomSheetState();
}

class _ViewPageBottomSheetState extends State<ViewPageBottomSheet> {
  MobileBottomSheetType type = MobileBottomSheetType.view;

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case MobileBottomSheetType.view:
        return MobileViewBottomSheetBody(
          view: widget.view,
          onAction: (action, {arguments}) {
            switch (action) {
              case MobileViewBottomSheetBodyAction.rename:
                setState(() {
                  type = MobileBottomSheetType.rename;
                });
                break;
              default:
                widget.onAction(action, arguments: arguments);
            }
          },
        );

      case MobileBottomSheetType.rename:
        return MobileBottomSheetRenameWidget(
          name: widget.view.name,
          onRename: (name) {
            widget.onRename(name);
          },
        );
    }
  }
}

class MobileViewBottomSheetBody extends StatelessWidget {
  const MobileViewBottomSheetBody({
    super.key,
    required this.view,
    required this.onAction,
  });

  final ViewPB view;
  final MobileViewBottomSheetBodyActionCallback onAction;

  @override
  Widget build(BuildContext context) {
    final isFavorite = view.isFavorite;
    final isEditable =
        context.watch<PageAccessLevelBloc?>()?.state.isEditable ?? false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MobileQuickActionButton(
          text: '重命名',
          icon: FlowySvgs.view_item_rename_s,
          iconSize: const Size.square(18),
          enable: isEditable,
          onTap: () => onAction(
            MobileViewBottomSheetBodyAction.rename,
          ),
        ),
        _divider(),
        MobileQuickActionButton(
          text: isFavorite
              ? '从收藏夹中'
              : '添加到收藏夹',
          icon: isFavorite ? FlowySvgs.unfavorite_s : FlowySvgs.favorite_s,
          iconSize: const Size.square(18),
          onTap: () => onAction(
            isFavorite
                ? MobileViewBottomSheetBodyAction.removeFromFavorites
                : MobileViewBottomSheetBodyAction.addToFavorites,
          ),
        ),
        _divider(),
        if (view.layout.isDatabaseView || view.layout.isDocumentView) ...[
          MobileQuickActionButton(
            text: '锁定页面',
            icon: FlowySvgs.lock_page_s,
            iconSize: const Size.square(18),
            rightIconBuilder: (context) => _LockPageRightIconBuilder(
              onAction: onAction,
            ),
            onTap: () {
              final isLocked =
                  context.read<PageAccessLevelBloc?>()?.state.isLocked ?? false;
              onAction(
                MobileViewBottomSheetBodyAction.lockPage,
                arguments: {
                  MobileViewBottomSheetBodyActionArguments.isLockedKey:
                      isLocked,
                },
              );
            },
          ),
          _divider(),
        ],
        MobileQuickActionButton(
          text: '复制',
          icon: FlowySvgs.duplicate_s,
          iconSize: const Size.square(18),
          onTap: () => onAction(
            MobileViewBottomSheetBodyAction.duplicate,
          ),
        ),
        // copy link
        _divider(),
        MobileQuickActionButton(
          text: '复制链接',
          icon: FlowySvgs.m_copy_link_s,
          iconSize: const Size.square(18),
          onTap: () => onAction(
            MobileViewBottomSheetBodyAction.copyShareLink,
          ),
        ),
        _divider(),
        ..._buildPublishActions(context),

        MobileQuickActionButton(
          text: '删除',
          textColor: Theme.of(context).colorScheme.error,
          icon: FlowySvgs.trash_s,
          iconColor: Theme.of(context).colorScheme.error,
          iconSize: const Size.square(18),
          enable: isEditable,
          onTap: () => onAction(
            MobileViewBottomSheetBodyAction.delete,
          ),
        ),
        _divider(),
      ],
    );
  }

  List<Widget> _buildPublishActions(BuildContext context) {
    final userProfile = context.read<MobileViewPageBloc>().state.userProfilePB;
    // the publish feature is only available for AppFlowy Cloud
    if (userProfile == null ||
        userProfile.workspaceType != WorkspaceTypePB.ServerW) {
      return [];
    }

    final isPublished = context.watch<ShareBloc>().state.isPublished;
    if (isPublished) {
      return [
        MobileQuickActionButton(
          text: '更新路径名称',
          icon: FlowySvgs.view_item_rename_s,
          iconSize: const Size.square(18),
          onTap: () => onAction(
            MobileViewBottomSheetBodyAction.updatePathName,
          ),
        ),
        _divider(),
        MobileQuickActionButton(
          text: '访问网站',
          icon: FlowySvgs.m_visit_site_s,
          iconSize: const Size.square(18),
          onTap: () => onAction(
            MobileViewBottomSheetBodyAction.visitSite,
          ),
        ),
        _divider(),
        MobileQuickActionButton(
          text: '取消发布',
          icon: FlowySvgs.m_unpublish_s,
          iconSize: const Size.square(18),
          onTap: () => onAction(
            MobileViewBottomSheetBodyAction.unpublish,
          ),
        ),
        _divider(),
      ];
    } else {
      return [
        MobileQuickActionButton(
          text: '发布',
          icon: FlowySvgs.m_publish_s,
          onTap: () => onAction(
            MobileViewBottomSheetBodyAction.publish,
          ),
        ),
        _divider(),
      ];
    }
  }

  Widget _divider() => const MobileQuickActionDivider();
}

class _LockPageRightIconBuilder extends StatelessWidget {
  const _LockPageRightIconBuilder({
    required this.onAction,
  });

  final MobileViewBottomSheetBodyActionCallback onAction;

  @override
  Widget build(BuildContext context) {
    final isEditable =
        context.watch<PageAccessLevelBloc?>()?.state.isEditable ?? false;
    return SizedBox(
      width: 46,
      height: 30,
      child: FittedBox(
        fit: BoxFit.fill,
        child: CupertinoSwitch(
          value: isEditable,
          activeTrackColor: Theme.of(context).colorScheme.primary,
          onChanged: (value) {
            onAction(
              MobileViewBottomSheetBodyAction.lockPage,
              arguments: {
                MobileViewBottomSheetBodyActionArguments.isLockedKey: value,
              },
            );
          },
        ),
      ),
    );
  }
}
