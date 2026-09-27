import 'package:appflowy/generated/flowy_svgs.g.dart';
import 'package:appflowy/workspace/presentation/settings/widgets/theme_upload/theme_upload.dart';
import 'package:flowy_infra/theme_extension.dart';
import 'package:flowy_infra_ui/flowy_infra_ui.dart';
import 'package:flutter/material.dart';

class UploadNewThemeWidget extends StatelessWidget {
  const UploadNewThemeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context)
          .colorScheme
          .surface
          .withValues(alpha: ThemeUploadWidget.fadeOpacity),
      padding: ThemeUploadWidget.padding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          FlowySvg(
            FlowySvgs.folder_m,
            size: ThemeUploadWidget.iconSize,
            color: AFThemeExtension.of(context).onBackground,
          ),
          FlowyText.medium(
            '使用下面的按钮上传您自己的 AppFlowy 主题。',
            overflow: TextOverflow.ellipsis,
          ),
          ThemeUploadWidget.elementSpacer,
          ThemeUploadWidget.elementSpacer,
          const Divider(),
          ThemeUploadWidget.elementSpacer,
          const ThemeUploadButton(),
          ThemeUploadWidget.elementSpacer,
        ],
      ),
    );
  }
}
