import 'package:flutter/material.dart';

import 'package:flowy_infra_ui/style_widget/text.dart';
import 'package:flowy_infra_ui/widget/spacing.dart';

class MobileCalendarEventsEmpty extends StatelessWidget {
  const MobileCalendarEventsEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FlowyText(
              '目前尚目前没有任何活动',
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
            const VSpace(8),
            FlowyText.regular(
              '点击加号按钮以在此日添加事件。',
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
