import 'package:appflowy/core/helpers/url_launcher.dart';
import 'package:appflowy/mobile/presentation/setting/widgets/mobile_setting_trailing.dart';
import 'package:appflowy/startup/tasks/device_info_task.dart';
import 'package:appflowy/workspace/presentation/settings/widgets/feature_flags/mobile_feature_flag_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/widgets.dart';

class AboutSettingGroup extends StatelessWidget {
  const AboutSettingGroup({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MobileSettingGroup(
      groupTitle: '关于',
      settingItemList: [
        MobileSettingItem(
          name: '隐私政策',
          trailing: MobileSettingTrailing(
            text: '',
          ),
          onTap: () => afLaunchUrlString('https://appflowy.com/privacy'),
        ),
        MobileSettingItem(
          name: '条款和条件',
          trailing: MobileSettingTrailing(
            text: '',
          ),
          onTap: () => afLaunchUrlString('https://appflowy.com/terms'),
        ),
        if (kDebugMode)
          MobileSettingItem(
            name: 'Feature Flags',
            trailing: MobileSettingTrailing(
              text: '',
            ),
            onTap: () {
              context.push(FeatureFlagScreen.routeName);
            },
          ),
        MobileSettingItem(
          name: '版本',
          trailing: MobileSettingTrailing(
            text:
                '${ApplicationInfo.applicationVersion} (${ApplicationInfo.buildNumber})',
            showArrow: false,
          ),
        ),
      ],
    );
  }
}
