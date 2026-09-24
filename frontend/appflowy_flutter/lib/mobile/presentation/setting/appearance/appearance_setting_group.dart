import 'package:appflowy/mobile/presentation/setting/appearance/rtl_setting.dart';
import 'package:appflowy/mobile/presentation/setting/appearance/text_scale_setting.dart';
import 'package:appflowy/mobile/presentation/setting/appearance/theme_setting.dart';
import 'package:flutter/material.dart';

import '../setting.dart';

class AppearanceSettingGroup extends StatelessWidget {
  const AppearanceSettingGroup({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MobileSettingGroup(
      groupTitle: '外观',
      settingItemList: const [
        ThemeSetting(),
        FontSetting(),
        DisplaySizeSetting(),
        RTLSetting(),
      ],
    );
  }
}
