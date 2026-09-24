import 'package:appflowy/workspace/presentation/widgets/date_picker/utils/layout.dart';
import 'package:flutter/material.dart';

import 'package:appflowy_popover/appflowy_popover.dart';
import 'package:flowy_infra_ui/style_widget/button.dart';
import 'package:flowy_infra_ui/style_widget/text.dart';

class ClearDateButton extends StatelessWidget {
  const ClearDateButton({
    super.key,
    required this.onClearDate,
  });

  final VoidCallback onClearDate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: SizedBox(
        height: DatePickerSize.itemHeight,
        child: FlowyButton(
          text: FlowyText('清除日期'),
          onTap: () {
            onClearDate();
            PopoverContainer.of(context).close();
          },
        ),
      ),
    );
  }
}
