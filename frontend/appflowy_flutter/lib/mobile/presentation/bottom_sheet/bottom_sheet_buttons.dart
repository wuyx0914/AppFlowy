import 'package:appflowy/generated/flowy_svgs.g.dart';
import 'package:flowy_infra_ui/flowy_infra_ui.dart';
import 'package:flutter/material.dart';

class BottomSheetCloseButton extends StatelessWidget {
  const BottomSheetCloseButton({
    super.key,
    this.onTap,
  });

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => Navigator.pop(context),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: SizedBox(
          width: 18,
          height: 18,
          child: FlowySvg(
            FlowySvgs.m_bottom_sheet_close_m,
          ),
        ),
      ),
    );
  }
}

class BottomSheetDoneButton extends StatelessWidget {
  const BottomSheetDoneButton({
    super.key,
    this.onDone,
  });

  final VoidCallback? onDone;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDone ?? () => Navigator.pop(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12.0),
        child: FlowyText(
          '完成',
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w500,
          textAlign: TextAlign.right,
        ),
      ),
    );
  }
}

class BottomSheetRemoveButton extends StatelessWidget {
  const BottomSheetRemoveButton({
    super.key,
    required this.onRemove,
  });

  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onRemove,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12.0),
        child: FlowyText(
          '移除',
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w500,
          textAlign: TextAlign.right,
        ),
      ),
    );
  }
}

class BottomSheetBackButton extends StatelessWidget {
  const BottomSheetBackButton({
    super.key,
    this.onTap,
  });

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => Navigator.pop(context),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: SizedBox(
          width: 18,
          height: 18,
          child: FlowySvg(
            FlowySvgs.m_bottom_sheet_back_s,
          ),
        ),
      ),
    );
  }
}
