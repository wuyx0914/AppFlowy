import 'package:appflowy/mobile/presentation/bottom_sheet/bottom_sheet.dart';
import 'package:appflowy/mobile/presentation/setting/widgets/mobile_setting_trailing.dart';
import 'package:appflowy/mobile/presentation/widgets/widgets.dart';
import 'package:appflowy/plugins/document/application/document_appearance_cubit.dart';
import 'package:appflowy/workspace/application/settings/appearance/appearance_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../setting.dart';

class RTLSetting extends StatelessWidget {
  const RTLSetting({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final textDirection =
        context.watch<AppearanceSettingsCubit>().state.textDirection;
    return MobileSettingItem(
      name: '默认文本方向',
      trailing: MobileSettingTrailing(
        text: _textDirectionLabelText(textDirection),
      ),
      onTap: () {
        showMobileBottomSheet(
          context,
          showHeader: true,
          showDragHandle: true,
          showDivider: false,
          title: '默认文本方向',
          builder: (context) {
            return Column(
              children: [
                FlowyOptionTile.checkbox(
                  text: '从左到右',
                  isSelected: textDirection == AppFlowyTextDirection.ltr,
                  onTap: () => applyTextDirectionAndPop(
                    context,
                    AppFlowyTextDirection.ltr,
                  ),
                ),
                FlowyOptionTile.checkbox(
                  showTopBorder: false,
                  text: '从右到左',
                  isSelected: textDirection == AppFlowyTextDirection.rtl,
                  onTap: () => applyTextDirectionAndPop(
                    context,
                    AppFlowyTextDirection.rtl,
                  ),
                ),
                FlowyOptionTile.checkbox(
                  showTopBorder: false,
                  text: '汽车',
                  isSelected: textDirection == AppFlowyTextDirection.auto,
                  onTap: () => applyTextDirectionAndPop(
                    context,
                    AppFlowyTextDirection.auto,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _textDirectionLabelText(AppFlowyTextDirection textDirection) {
    switch (textDirection) {
      case AppFlowyTextDirection.auto:
        return '汽车';
      case AppFlowyTextDirection.rtl:
        return '从右到左';
      case AppFlowyTextDirection.ltr:
        return '从左到右';
    }
  }

  void applyTextDirectionAndPop(
    BuildContext context,
    AppFlowyTextDirection textDirection,
  ) {
    context.read<AppearanceSettingsCubit>().setTextDirection(textDirection);
    context
        .read<DocumentAppearanceCubit>()
        .syncDefaultTextDirection(textDirection.name);
    Navigator.pop(context);
  }
}
