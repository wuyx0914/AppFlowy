import 'package:flutter/material.dart';

import 'package:appflowy/mobile/presentation/base/app_bar/app_bar_actions.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flowy_infra_ui/style_widget/text.dart';

class MobileImagePickerScreen extends StatelessWidget {
  const MobileImagePickerScreen({super.key});

  static const routeName = '/image_picker';

  @override
  Widget build(BuildContext context) => const ImagePickerPage();
}

class ImagePickerPage extends StatelessWidget {
  const ImagePickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: FlowyText.semibold(
          '页面图标',
          fontSize: 14.0,
        ),
        leading: const AppBarBackButton(),
      ),
      body: SafeArea(
        child: UploadImageMenu(
          onSubmitted: (_) {},
          onUpload: (_) {},
        ),
      ),
    );
  }
}
