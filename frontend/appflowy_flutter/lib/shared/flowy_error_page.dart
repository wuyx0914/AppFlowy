import 'package:appflowy/core/helpers/url_launcher.dart';
import 'package:appflowy/generated/flowy_svgs.g.dart';
import 'package:appflowy/mobile/presentation/base/animated_gesture.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/copy_and_paste/clipboard_service.dart';
import 'package:appflowy/startup/startup.dart';
import 'package:appflowy/workspace/presentation/widgets/dialogs.dart';
import 'package:appflowy_backend/protobuf/flowy-error/errors.pb.dart';
import 'package:flowy_infra_ui/style_widget/text.dart';
import 'package:flowy_infra_ui/widget/spacing.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:universal_platform/universal_platform.dart';

class AppFlowyErrorPage extends StatelessWidget {
  const AppFlowyErrorPage({
    super.key,
    this.error,
  });

  final FlowyError? error;

  @override
  Widget build(BuildContext context) {
    if (UniversalPlatform.isMobile) {
      return _MobileSyncErrorPage(error: error);
    } else {
      return _DesktopSyncErrorPage(error: error);
    }
  }
}

class _MobileSyncErrorPage extends StatelessWidget {
  const _MobileSyncErrorPage({
    this.error,
  });

  final FlowyError? error;

  @override
  Widget build(BuildContext context) {
    return AnimatedGestureDetector(
      scaleFactor: 0.99,
      onTapUp: () {
        getIt<ClipboardService>().setPlainText(error.toString());
        showToastNotification(
          message: '已复制',
          bottomPadding: 0,
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const FlowySvg(
            FlowySvgs.icon_warning_xl,
            blendMode: null,
          ),
          const VSpace(16.0),
          FlowyText.medium(
            '数据尚未从其他设备同步',
            fontSize: 15,
          ),
          const VSpace(8.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: FlowyText.regular(
              '请在上次编辑的设备上重新打开此页面，然后在目前的设备上再次打开它。',
              fontSize: 13,
              color: Theme.of(context).hintColor,
              textAlign: TextAlign.center,
              maxLines: 10,
            ),
          ),
          const VSpace(2.0),
          FlowyText.regular(
            '(${'点击以拷贝错误码'})',
            fontSize: 13,
            color: Theme.of(context).hintColor,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _DesktopSyncErrorPage extends StatelessWidget {
  const _DesktopSyncErrorPage({
    this.error,
  });

  final FlowyError? error;

  @override
  Widget build(BuildContext context) {
    return AnimatedGestureDetector(
      scaleFactor: 0.995,
      onTapUp: () {
        getIt<ClipboardService>().setPlainText(error.toString());
        showToastNotification(
          message: '已复制',
          bottomPadding: 0,
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const FlowySvg(
            FlowySvgs.icon_warning_xl,
            blendMode: null,
          ),
          const VSpace(16.0),
          FlowyText.medium(
            error?.code.toString() ?? '',
            fontSize: 16,
          ),
          const VSpace(8.0),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '对于造成的不便，我们深感抱歉！在我们的...上提交问题。',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                TextSpan(
                  text: 'Github',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.primary,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      afLaunchUrlString(
                        'https://github.com/AppFlowy-IO/AppFlowy/issues/new?template=bug_report.yaml',
                      );
                    },
                ),
                TextSpan(
                  text: ' 页面描述您的错误。',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ],
            ),
          ),
          const VSpace(8.0),
          FlowyText.regular(
            '(${'点击以拷贝错误码'})',
            fontSize: 14,
            color: Theme.of(context).hintColor,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
