import 'package:flowy_infra/theme.dart';
import 'package:flowy_infra_ui/flowy_infra_ui.dart';
import 'package:flutter/material.dart';

import 'theme_upload_view.dart';

class ThemeConfirmDeleteDialog extends StatelessWidget {
  const ThemeConfirmDeleteDialog({
    super.key,
    required this.theme,
  });

  final AppTheme theme;

  void onConfirm(BuildContext context) => Navigator.of(context).pop(true);
  void onCancel(BuildContext context) => Navigator.of(context).pop(false);

  @override
  Widget build(BuildContext context) {
    return FlowyDialog(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(
        width: 300,
        height: 100,
      ),
      title: FlowyText.regular(
        '您确定您要继续吗?',
        textAlign: TextAlign.center,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            width: ThemeUploadWidget.buttonSize.width,
            child: FlowyButton(
              text: FlowyText.semibold(
                'OK',
                fontSize: ThemeUploadWidget.buttonFontSize,
              ),
              onTap: () => onConfirm(context),
            ),
          ),
          SizedBox(
            width: ThemeUploadWidget.buttonSize.width,
            child: FlowyButton(
              text: FlowyText.semibold(
                '取消',
                fontSize: ThemeUploadWidget.buttonFontSize,
              ),
              onTap: () => onCancel(context),
            ),
          ),
        ],
      ),
    );
  }
}
