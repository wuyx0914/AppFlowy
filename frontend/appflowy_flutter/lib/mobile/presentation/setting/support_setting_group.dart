import 'dart:io';

import 'package:appflowy/core/helpers/url_launcher.dart';
import 'package:appflowy/mobile/presentation/bottom_sheet/show_mobile_bottom_sheet.dart';
import 'package:appflowy/mobile/presentation/setting/widgets/mobile_setting_trailing.dart';
import 'package:appflowy/mobile/presentation/widgets/widgets.dart';
import 'package:appflowy/shared/appflowy_cache_manager.dart';
import 'package:appflowy/startup/startup.dart';
import 'package:appflowy/util/share_log_files.dart';
import 'package:appflowy/workspace/presentation/settings/pages/fix_data_widget.dart';
import 'package:appflowy/workspace/presentation/widgets/dialogs.dart';
import 'package:flowy_infra_ui/flowy_infra_ui.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'widgets/widgets.dart';

class SupportSettingGroup extends StatelessWidget {
  const SupportSettingGroup({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) => MobileSettingGroup(
        groupTitle: '支持',
        settingItemList: [
          MobileSettingItem(
            name: '在 Discord 中加入我们',
            trailing: MobileSettingTrailing(
              text: '',
            ),
            onTap: () => afLaunchUrlString('https://discord.gg/JucBXeU2FE'),
          ),
          MobileSettingItem(
            name: '上报问题',
            trailing: MobileSettingTrailing(
              text: '',
            ),
            onTap: () {
              showMobileBottomSheet(
                context,
                showDragHandle: true,
                showHeader: true,
                title: '上报问题',
                backgroundColor: Theme.of(context).colorScheme.surface,
                builder: (context) {
                  return _ReportIssuesWidget(
                    version: snapshot.data?.version ?? '',
                  );
                },
              );
            },
          ),
          MobileSettingItem(
            name: '清空缓存',
            trailing: MobileSettingTrailing(
              text: '',
            ),
            onTap: () async {
              await showFlowyMobileConfirmDialog(
                context,
                title: FlowyText(
                  '您确定要清除缓存吗？',
                  maxLines: 2,
                ),
                content: FlowyText(
                  '如果您遇到图片无法加载或字体无法正确显示的问题，请尝试清除缓存。此操作不会删除您的用户数据。',
                  fontSize: 12,
                  maxLines: 4,
                ),
                actionButtonTitle: '是',
                onActionButtonPressed: () async {
                  await getIt<FlowyCacheManager>().clearAllCache();
                  // check the workspace and space health
                  await WorkspaceDataManager.checkViewHealth(
                    dryRun: false,
                  );
                  if (context.mounted) {
                    showToastNotification(
                      message: '缓存清除成功！',
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ReportIssuesWidget extends StatelessWidget {
  const _ReportIssuesWidget({
    required this.version,
  });

  final String version;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FlowyOptionTile.text(
          showTopBorder: false,
          text: '在 Github 上报告问题',
          onTap: () {
            final String os = Platform.operatingSystem;
            afLaunchUrlString(
              'https://github.com/AppFlowy-IO/AppFlowy/issues/new?assignees=&labels=&projects=&template=bug_report.yaml&title=[Bug]%20Mobile:%20&version=$version&os=$os',
            );
          },
        ),
        FlowyOptionTile.text(
          showTopBorder: false,
          text: '导出日志文件',
          onTap: () => shareLogFiles(context),
        ),
      ],
    );
  }
}
