import 'package:appflowy/generated/flowy_svgs.g.dart';
import 'package:appflowy/mobile/presentation/bottom_sheet/bottom_sheet.dart';
import 'package:appflowy/mobile/presentation/setting/widgets/mobile_setting_trailing.dart';
import 'package:appflowy/mobile/presentation/widgets/widgets.dart';
import 'package:appflowy/util/theme_mode_extension.dart';
import 'package:appflowy/workspace/application/settings/appearance/appearance_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../setting.dart';

class ThemeSetting extends StatelessWidget {
  const ThemeSetting({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<AppearanceSettingsCubit>().state.themeMode;
    return MobileSettingItem(
      name: '主题模式',
      trailing: MobileSettingTrailing(
        text: themeMode.labelText,
      ),
      onTap: () {
        showMobileBottomSheet(
          context,
          showHeader: true,
          showDragHandle: true,
          showDivider: false,
          title: '主题模式',
          builder: (context) {
            final themeMode =
                context.read<AppearanceSettingsCubit>().state.themeMode;
            return Column(
              children: [
                FlowyOptionTile.checkbox(
                  text: '系统自适应',
                  leftIcon: const FlowySvg(
                    FlowySvgs.m_theme_mode_system_s,
                  ),
                  isSelected: themeMode == ThemeMode.system,
                  onTap: () {
                    context
                        .read<AppearanceSettingsCubit>()
                        .setThemeMode(ThemeMode.system);
                    Navigator.pop(context);
                  },
                ),
                FlowyOptionTile.checkbox(
                  showTopBorder: false,
                  text: '日间模式',
                  leftIcon: const FlowySvg(
                    FlowySvgs.m_theme_mode_light_s,
                  ),
                  isSelected: themeMode == ThemeMode.light,
                  onTap: () {
                    context
                        .read<AppearanceSettingsCubit>()
                        .setThemeMode(ThemeMode.light);
                    Navigator.pop(context);
                  },
                ),
                FlowyOptionTile.checkbox(
                  showTopBorder: false,
                  text: '夜间模式',
                  leftIcon: const FlowySvg(
                    FlowySvgs.m_theme_mode_dark_s,
                  ),
                  isSelected: themeMode == ThemeMode.dark,
                  onTap: () {
                    context
                        .read<AppearanceSettingsCubit>()
                        .setThemeMode(ThemeMode.dark);
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
