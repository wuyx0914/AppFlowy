import 'package:appflowy/generated/flowy_svgs.g.dart';
import 'package:appflowy/workspace/application/settings/settings_dialog_bloc.dart';
import 'package:appflowy/workspace/presentation/settings/widgets/settings_menu_element.dart';
import 'package:appflowy_backend/protobuf/flowy-user/protobuf.dart';
import 'package:appflowy_ui/appflowy_ui.dart';
import 'package:flowy_infra_ui/flowy_infra_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SettingsMenu extends StatelessWidget {
  const SettingsMenu({
    super.key,
    required this.changeSelectedPage,
    required this.currentPage,
    required this.userProfile,
    required this.isBillingEnabled,
    required this.currentUserRole,
  });

  final Function changeSelectedPage;
  final SettingsPage currentPage;
  final UserProfilePB userProfile;
  final bool isBillingEnabled;
  final AFRolePB? currentUserRole;

  @override
  Widget build(BuildContext context) {
    final theme = AppFlowyTheme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.surfaceContainerColorScheme.layer01,
        borderRadius: BorderRadiusDirectional.horizontal(
          start: Radius.circular(theme.spacing.m),
        ),
      ),
      height: double.infinity,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          vertical: 24,
          horizontal: theme.spacing.l,
        ),
        physics: const ClampingScrollPhysics(),
        child: Column(
          spacing: theme.spacing.xs,
          children: [
            SettingsMenuElement(
              page: SettingsPage.account,
              selectedPage: currentPage,
              label: '我的账户',
              icon: const FlowySvg(FlowySvgs.settings_page_user_m),
              changeSelectedPage: changeSelectedPage,
            ),
            SettingsMenuElement(
              page: SettingsPage.workspace,
              selectedPage: currentPage,
              label: '工作区',
              icon: const FlowySvg(FlowySvgs.settings_page_workspace_m),
              changeSelectedPage: changeSelectedPage,
            ),
            // Local-only build: members / sites / plan / billing settings are
            // cloud-only features and are removed.
            SettingsMenuElement(
              page: SettingsPage.manageData,
              selectedPage: currentPage,
              label: '管理数据',
              icon: const FlowySvg(FlowySvgs.settings_page_database_m),
              changeSelectedPage: changeSelectedPage,
            ),
            SettingsMenuElement(
              page: SettingsPage.notifications,
              selectedPage: currentPage,
              label: '通知',
              icon: const FlowySvg(FlowySvgs.settings_page_bell_m),
              changeSelectedPage: changeSelectedPage,
            ),
            SettingsMenuElement(
              page: SettingsPage.shortcuts,
              selectedPage: currentPage,
              label: '快捷键',
              icon: const FlowySvg(FlowySvgs.settings_page_keyboard_m),
              changeSelectedPage: changeSelectedPage,
            ),
            SettingsMenuElement(
              page: SettingsPage.ai,
              selectedPage: currentPage,
              label: 'AI 设置',
              icon: const FlowySvg(
                FlowySvgs.settings_page_ai_m,
              ),
              changeSelectedPage: changeSelectedPage,
            ),
            if (kDebugMode)
              SettingsMenuElement(
                // no need to translate this page
                page: SettingsPage.featureFlags,
                selectedPage: currentPage,
                label: 'Feature Flags',
                icon: const Icon(
                  Icons.flag,
                  size: 20,
                ),
                changeSelectedPage: changeSelectedPage,
              ),
          ],
        ),
      ),
    );
  }
}

class SimpleSettingsMenu extends StatelessWidget {
  const SimpleSettingsMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8) +
                const EdgeInsets.only(left: 8, right: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
            ),
            child: SingleChildScrollView(
              // Right padding is added to make the scrollbar centered
              // in the space between the menu and the content
              padding: const EdgeInsets.only(right: 4) +
                  const EdgeInsets.symmetric(vertical: 16),
              physics: const ClampingScrollPhysics(),
              child: SeparatedColumn(
                separatorBuilder: () => const VSpace(16),
                children: [
                  if (kDebugMode)
                    SettingsMenuElement(
                      // no need to translate this page
                      page: SettingsPage.featureFlags,
                      selectedPage: SettingsPage.featureFlags,
                      label: 'Feature Flags',
                      icon: const Icon(Icons.flag),
                      changeSelectedPage: () {},
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
