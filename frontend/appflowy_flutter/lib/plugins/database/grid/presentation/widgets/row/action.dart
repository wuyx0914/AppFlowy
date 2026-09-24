import 'package:appflowy/generated/flowy_svgs.g.dart';
import 'package:appflowy/plugins/database/application/row/row_service.dart';
import 'package:appflowy/plugins/database/domain/sort_service.dart';
import 'package:appflowy/plugins/database/grid/application/grid_bloc.dart';
import 'package:appflowy/plugins/database/grid/presentation/layout/sizes.dart';
import 'package:appflowy/workspace/presentation/widgets/dialogs.dart';
import 'package:appflowy_backend/protobuf/flowy-database2/protobuf.dart';
import 'package:flowy_infra_ui/flowy_infra_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RowActionMenu extends StatelessWidget {
  const RowActionMenu({
    super.key,
    required this.viewId,
    required this.rowId,
    this.actions = RowAction.values,
    this.groupId,
  });

  const RowActionMenu.board({
    super.key,
    required this.viewId,
    required this.rowId,
    required this.groupId,
  }) : actions = const [RowAction.duplicate, RowAction.delete];

  final String viewId;
  final RowId rowId;
  final List<RowAction> actions;
  final String? groupId;

  @override
  Widget build(BuildContext context) {
    final cells =
        actions.map((action) => _actionCell(context, action)).toList();

    return SeparatedColumn(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      separatorBuilder: () => VSpace(GridSize.typeOptionSeparatorHeight),
      children: cells,
    );
  }

  Widget _actionCell(BuildContext context, RowAction action) {
    Widget icon = FlowySvg(action.icon);
    if (action == RowAction.insertAbove) {
      icon = RotatedBox(quarterTurns: 1, child: icon);
    }
    return SizedBox(
      height: GridSize.popoverItemHeight,
      child: FlowyButton(
        text: FlowyText(
          action.text,
          overflow: TextOverflow.ellipsis,
          lineHeight: 1.0,
        ),
        onTap: () {
          action.performAction(context, viewId, rowId);
          PopoverContainer.of(context).close();
        },
        leftIcon: icon,
      ),
    );
  }
}

enum RowAction {
  insertAbove,
  insertBelow,
  duplicate,
  delete;

  FlowySvgData get icon {
    return switch (this) {
      insertAbove => FlowySvgs.arrow_s,
      insertBelow => FlowySvgs.add_s,
      duplicate => FlowySvgs.duplicate_s,
      delete => FlowySvgs.delete_s,
    };
  }

  String get text {
    return switch (this) {
      insertAbove => '在上方插入记录',
      insertBelow => '点击添加到下方',
      duplicate => '复制',
      delete => '删除',
    };
  }

  void performAction(BuildContext context, String viewId, String rowId) {
    switch (this) {
      case insertAbove:
      case insertBelow:
        final position = this == insertAbove
            ? OrderObjectPositionTypePB.Before
            : OrderObjectPositionTypePB.After;
        final intention = this == insertAbove
            ? '在上方创建一个列'
            : '在下方插入一个列';
        if (context.read<GridBloc>().state.sorts.isNotEmpty) {
          showCancelAndDeleteDialog(
            context: context,
            title: '在排序时无法 {intention}',
            description: '您想删除排序吗？',
            confirmLabel: '移除',
            closeOnAction: true,
            onDelete: () {
              SortBackendService(viewId: viewId).deleteAllSorts();
              RowBackendService.createRow(
                viewId: viewId,
                position: position,
                targetRowId: rowId,
              );
            },
          );
        } else {
          RowBackendService.createRow(
            viewId: viewId,
            position: position,
            targetRowId: rowId,
          );
        }
        break;
      case duplicate:
        RowBackendService.duplicateRow(viewId, rowId);
        break;
      case delete:
        showConfirmDeletionDialog(
          context: context,
          name: '列',
          description: '您确定要删除此行吗？此操作无法撤消',
          onConfirm: () => RowBackendService.deleteRows(viewId, [rowId]),
        );
        break;
    }
  }
}
