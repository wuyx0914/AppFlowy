import 'package:appflowy/generated/flowy_svgs.g.dart';
import 'package:appflowy/mobile/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';

enum BlockActionBottomSheetType {
  delete,
  duplicate,
  insertAbove,
  insertBelow,
}

// Only works on mobile.
class BlockActionBottomSheet extends StatelessWidget {
  const BlockActionBottomSheet({
    super.key,
    required this.onAction,
    this.extendActionWidgets = const [],
  });

  final void Function(BlockActionBottomSheetType layout) onAction;
  final List<Widget> extendActionWidgets;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // insert above, insert below
        FlowyOptionTile.text(
          text: '在上方插入',
          leftIcon: const FlowySvg(
            FlowySvgs.arrow_up_s,
            size: Size.square(20),
          ),
          showTopBorder: false,
          onTap: () => onAction(BlockActionBottomSheetType.insertAbove),
        ),
        FlowyOptionTile.text(
          showTopBorder: false,
          text: '在下方插入',
          leftIcon: const FlowySvg(
            FlowySvgs.arrow_down_s,
            size: Size.square(20),
          ),
          onTap: () => onAction(BlockActionBottomSheetType.insertBelow),
        ),
        // duplicate, delete
        FlowyOptionTile.text(
          showTopBorder: false,
          text: '复制',
          leftIcon: const Padding(
            padding: EdgeInsets.all(2),
            child: FlowySvg(
              FlowySvgs.copy_s,
              size: Size.square(16),
            ),
          ),
          onTap: () => onAction(BlockActionBottomSheetType.duplicate),
        ),

        ...extendActionWidgets,

        FlowyOptionTile.text(
          showTopBorder: false,
          text: '删除',
          leftIcon: FlowySvg(
            FlowySvgs.trash_s,
            size: const Size.square(18),
            color: Theme.of(context).colorScheme.error,
          ),
          textColor: Theme.of(context).colorScheme.error,
          onTap: () => onAction(BlockActionBottomSheetType.delete),
        ),
      ],
    );
  }
}
