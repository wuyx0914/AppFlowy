import 'package:flowy_infra_ui/style_widget/text.dart';
import 'package:flutter/material.dart';

class NotificationHubTitle extends StatelessWidget {
  const NotificationHubTitle({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16) +
          const EdgeInsets.only(top: 12, bottom: 4),
      child: FlowyText.semibold(
        '通知',
        color: Theme.of(context).colorScheme.tertiary,
        fontSize: 16,
      ),
    );
  }
}
