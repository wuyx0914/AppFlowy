import 'dart:async';

import 'package:appflowy/mobile/presentation/setting/font/font_picker_screen.dart';
import 'package:appflowy/mobile/presentation/setting/widgets/mobile_setting_trailing.dart';
import 'package:appflowy/plugins/document/application/document_appearance_cubit.dart';
import 'package:appflowy/util/font_family_extension.dart';
import 'package:appflowy/workspace/application/settings/appearance/appearance_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../setting.dart';

class FontSetting extends StatelessWidget {
  const FontSetting({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final selectedFont = context.watch<AppearanceSettingsCubit>().state.font;
    final name = selectedFont.fontFamilyDisplayName;
    return MobileSettingItem(
      name: '字体系列',
      trailing: MobileSettingTrailing(
        text: name,
      ),
      onTap: () async {
        final newFont = await context.push<String>(FontPickerScreen.routeName);
        if (newFont != null && newFont != selectedFont) {
          if (context.mounted) {
            context.read<AppearanceSettingsCubit>().setFontFamily(newFont);
            unawaited(
              context.read<DocumentAppearanceCubit>().syncFontFamily(newFont),
            );
          }
        }
      },
    );
  }
}
