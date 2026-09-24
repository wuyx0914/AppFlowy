import 'package:appflowy/features/workspace/logic/workspace_bloc.dart';
import 'package:appflowy/generated/flowy_svgs.g.dart';
import 'package:appflowy/workspace/presentation/widgets/dialog_v2.dart';
import 'package:appflowy/workspace/presentation/widgets/dialogs.dart';
import 'package:appflowy/workspace/presentation/widgets/pop_up_action.dart';
import 'package:appflowy_backend/protobuf/flowy-user/protobuf.dart';
import 'package:flowy_infra_ui/flowy_infra_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum WorkspaceMoreAction {
  rename,
  delete,
  leave,
  divider,
}

class WorkspaceMoreActionList extends StatefulWidget {
  const WorkspaceMoreActionList({
    super.key,
    required this.workspace,
    required this.popoverMutex,
  });

  final UserWorkspacePB workspace;
  final PopoverMutex popoverMutex;

  @override
  State<WorkspaceMoreActionList> createState() =>
      _WorkspaceMoreActionListState();
}

class _WorkspaceMoreActionListState extends State<WorkspaceMoreActionList> {
  bool isPopoverOpen = false;

  @override
  Widget build(BuildContext context) {
    // Local-only build: the local user is always the workspace owner.
    final actions = [WorkspaceMoreAction.rename, WorkspaceMoreAction.divider, WorkspaceMoreAction.delete];
    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }
    return PopoverActionList<_WorkspaceMoreActionWrapper>(
      direction: PopoverDirection.bottomWithLeftAligned,
      actions: actions
          .map(
            (action) => _WorkspaceMoreActionWrapper(
              action,
              widget.workspace,
              () => PopoverContainer.of(context).closeAll(),
            ),
          )
          .toList(),
      mutex: widget.popoverMutex,
      constraints: const BoxConstraints(minWidth: 220),
      animationDuration: Durations.short3,
      slideDistance: 2,
      beginScaleFactor: 1.0,
      beginOpacity: 0.8,
      onClosed: () => isPopoverOpen = false,
      asBarrier: true,
      buildChild: (controller) {
        return SizedBox.square(
          dimension: 24.0,
          child: FlowyButton(
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            text: const FlowySvg(
              FlowySvgs.workspace_three_dots_s,
            ),
            onTap: () {
              if (!isPopoverOpen) {
                controller.show();
                isPopoverOpen = true;
              }
            },
          ),
        );
      },
      onSelected: (action, controller) {},
    );
  }
}

class _WorkspaceMoreActionWrapper extends CustomActionCell {
  _WorkspaceMoreActionWrapper(
    this.inner,
    this.workspace,
    this.closeWorkspaceMenu,
  );

  final WorkspaceMoreAction inner;
  final UserWorkspacePB workspace;
  final VoidCallback closeWorkspaceMenu;

  @override
  Widget buildWithContext(
    BuildContext context,
    PopoverController controller,
    PopoverMutex? mutex,
  ) {
    if (inner == WorkspaceMoreAction.divider) {
      return const Divider();
    }

    return _buildActionButton(context, controller);
  }

  Widget _buildActionButton(
    BuildContext context,
    PopoverController controller,
  ) {
    return FlowyIconTextButton(
      leftIconBuilder: (onHover) => buildLeftIcon(context, onHover),
      iconPadding: 10.0,
      textBuilder: (onHover) => FlowyText.regular(
        name,
        fontSize: 14.0,
        figmaLineHeight: 18.0,
        color: [WorkspaceMoreAction.delete, WorkspaceMoreAction.leave]
                    .contains(inner) &&
                onHover
            ? Theme.of(context).colorScheme.error
            : null,
      ),
      margin: const EdgeInsets.all(6),
      onTap: () async {
        PopoverContainer.of(context).closeAll();
        closeWorkspaceMenu();

        final workspaceBloc = context.read<UserWorkspaceBloc>();
        switch (inner) {
          case WorkspaceMoreAction.divider:
            break;
          case WorkspaceMoreAction.delete:
            await showConfirmDeletionDialog(
              context: context,
              name: workspace.name,
              description: '您确定要删除这个工作区嘛？这个操作不可恢复。',
              onConfirm: () {
                workspaceBloc.add(
                  UserWorkspaceEvent.deleteWorkspace(
                    workspaceId: workspace.workspaceId,
                  ),
                );
              },
            );
          case WorkspaceMoreAction.rename:
            await showAFTextFieldDialog(
              context: context,
              title: '重命名工作区',
              initialValue: workspace.name,
              hintText: '',
              onConfirm: (name) async {
                workspaceBloc.add(
                  UserWorkspaceEvent.renameWorkspace(
                    workspaceId: workspace.workspaceId,
                    name: name,
                  ),
                );
              },
            );
          case WorkspaceMoreAction.leave:
            await showConfirmDialog(
              context: context,
              title: '退出工作区',
              description:
                  '您确定要离开当前工作区吗？',
              confirmLabel: '是',
              onConfirm: (_) {
                workspaceBloc.add(
                  UserWorkspaceEvent.leaveWorkspace(
                    workspaceId: workspace.workspaceId,
                  ),
                );
              },
            );
        }
      },
    );
  }

  String get name {
    switch (inner) {
      case WorkspaceMoreAction.delete:
        return '删除';
      case WorkspaceMoreAction.rename:
        return '重命名';
      case WorkspaceMoreAction.leave:
        return '退出工作区';
      case WorkspaceMoreAction.divider:
        return '';
    }
  }

  Widget buildLeftIcon(BuildContext context, bool onHover) {
    switch (inner) {
      case WorkspaceMoreAction.delete:
        return FlowySvg(
          FlowySvgs.trash_s,
          color: onHover ? Theme.of(context).colorScheme.error : null,
        );
      case WorkspaceMoreAction.rename:
        return const FlowySvg(FlowySvgs.view_item_rename_s);
      case WorkspaceMoreAction.leave:
        return FlowySvg(
          FlowySvgs.logout_s,
          color: onHover ? Theme.of(context).colorScheme.error : null,
        );
      case WorkspaceMoreAction.divider:
        return const SizedBox.shrink();
    }
  }
}
