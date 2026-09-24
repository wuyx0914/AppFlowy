import 'package:appflowy_ui/appflowy_ui.dart';
import 'package:flutter/material.dart';

class ContinueWithPassword extends StatelessWidget {
  const ContinueWithPassword({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AFOutlinedTextButton.normal(
      text: '继续使用密码',
      size: AFButtonSize.l,
      alignment: Alignment.center,
      onTap: onTap,
    );
  }
}
