import 'package:appflowy/generated/locale_keys.g.dart';
import 'package:appflowy/startup/tasks/device_info_task.dart';
import 'package:appflowy_ui/appflowy_ui.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flowy_infra_ui/flowy_infra_ui.dart';
import 'package:flutter/material.dart';

// Local-only build: no update check, always show the current version only.
class SettingsAppVersion extends StatelessWidget {
  const SettingsAppVersion({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return _buildIsUpToDate(context);
  }

  Widget _buildIsUpToDate(BuildContext context) {
    final theme = AppFlowyTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.settings_accountPage_isUpToDate.tr(),
          style: theme.textStyle.body.enhanced(
            color: theme.textColorScheme.primary,
          ),
        ),
        VSpace(theme.spacing.s),
        Text(
          LocaleKeys.settings_accountPage_officialVersion.tr(
            namedArgs: {
              'version': ApplicationInfo.applicationVersion,
            },
          ),
          style: theme.textStyle.caption.standard(
            color: theme.textColorScheme.secondary,
          ),
        ),
      ],
    );
  }
}
