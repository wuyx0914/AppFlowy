import 'package:appflowy/core/helpers/url_launcher.dart';
import 'package:appflowy/shared/error_page/error_page.dart';
import 'package:appflowy/workspace/presentation/settings/widgets/theme_upload/theme_upload_view.dart';
import 'package:appflowy/workspace/presentation/widgets/dialogs.dart';
import 'package:flowy_infra/theme_extension.dart';
import 'package:flowy_infra_ui/flowy_infra_ui.dart';
import 'package:flowy_infra_ui/widget/buttons/secondary_button.dart';
import 'package:flutter/material.dart';

class ThemeUploadLearnMoreButton extends StatelessWidget {
  const ThemeUploadLearnMoreButton({super.key});

  static const learnMoreURL =
      'https://docs.appflowy.io/docs/appflowy/product/themes';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ThemeUploadWidget.buttonSize.height,
      child: IntrinsicWidth(
        child: SecondaryButton(
          outlineColor: AFThemeExtension.of(context).onBackground,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: FlowyText.medium(
              fontSize: ThemeUploadWidget.buttonFontSize,
              '学习更多',
            ),
          ),
          onPressed: () async {
            final uri = Uri.parse(learnMoreURL);
            await afLaunchUri(
              uri,
              context: context,
              onFailure: (_) async {
                if (context.mounted) {
                  await Dialogs.show(
                    context,
                    child: FlowyDialog(
                      child: FlowyErrorPage.message(
                        '无法打开网址：{}'
                            .replaceAll(
                              '{}',
                              uri.toString(),
                            ),
                        howToFix: '对于给您带来的不便, 我们深表歉意! 请在我们的 GitHub 页面上提交 issue 并描述您遇到的错误。',
                      ),
                    ),
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }
}
