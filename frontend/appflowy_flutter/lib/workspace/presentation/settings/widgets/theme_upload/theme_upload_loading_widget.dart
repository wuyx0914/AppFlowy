import 'package:appflowy/workspace/presentation/settings/widgets/theme_upload/theme_upload_view.dart';
import 'package:flowy_infra_ui/flowy_infra_ui.dart';
import 'package:flutter/material.dart';

class ThemeUploadLoadingWidget extends StatelessWidget {
  const ThemeUploadLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: ThemeUploadWidget.padding,
      color: Theme.of(context)
          .colorScheme
          .surface
          .withValues(alpha: ThemeUploadWidget.fadeOpacity),
      constraints: const BoxConstraints.expand(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
          ThemeUploadWidget.elementSpacer,
          FlowyText.regular(
            '我们正在验证并上传您的主题，请稍候...',
          ),
        ],
      ),
    );
  }
}
