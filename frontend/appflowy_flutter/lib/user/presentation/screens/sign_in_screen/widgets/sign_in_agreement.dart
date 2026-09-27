import 'package:appflowy_ui/appflowy_ui.dart';
import 'package:flutter/material.dart';

class SignInAgreement extends StatelessWidget {
  const SignInAgreement({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppFlowyTheme.of(context);
    final textStyle = theme.textStyle.caption.standard(
      color: theme.textColorScheme.secondary,
    );
    return Text(
      '本构建为纯本地版本，无需账号登录。',
      textAlign: TextAlign.center,
      style: textStyle,
    );
  }
}
