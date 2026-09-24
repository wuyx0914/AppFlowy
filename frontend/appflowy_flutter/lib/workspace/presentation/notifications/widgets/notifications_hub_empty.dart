import 'package:flowy_infra_ui/style_widget/text.dart';
import 'package:flowy_infra_ui/widget/spacing.dart';
import 'package:flutter/material.dart';

class NotificationsHubEmpty extends StatelessWidget {
  const NotificationsHubEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FlowyText(
              '都处理了！',
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
            const VSpace(8),
            FlowyText.regular(
              '没有待处理的通知或操作。享受平静。',
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
