import 'package:appflowy/mobile/presentation/base/app_bar/app_bar.dart';
import 'package:appflowy/plugins/base/color/color_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MobileColorPickerScreen extends StatelessWidget {
  const MobileColorPickerScreen({super.key, this.title});

  final String? title;

  static const routeName = '/color_picker';
  static const pageTitle = 'title';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FlowyAppBar(
        titleText: title ?? '页面图标',
      ),
      body: SafeArea(
        child: FlowyMobileColorPicker(
          onSelectedColor: (option) => context.pop(option),
        ),
      ),
    );
  }
}
