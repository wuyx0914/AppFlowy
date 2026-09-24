import 'package:appflowy_ui/appflowy_ui.dart';
import 'package:flutter/material.dart';

class GuestTag extends StatelessWidget {
  const GuestTag({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppFlowyTheme.of(context);
    return Container(
      padding: EdgeInsets.only(
        left: theme.spacing.m,
        right: theme.spacing.m,
        bottom: 2,
      ),
      decoration: BoxDecoration(
        color: theme.fillColorScheme.warningLight,
        borderRadius: BorderRadius.circular(theme.spacing.s),
      ),
      child: Text(
        '客人',
        style: theme.textStyle.caption
            .standard(
              color: theme.textColorScheme.warning,
            )
            .copyWith(
              height: 16.0 / 12.0,
            ),
      ),
    );
  }
}
