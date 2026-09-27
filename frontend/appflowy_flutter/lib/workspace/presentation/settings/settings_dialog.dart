import 'package:appflowy/features/workspace/logic/workspace_bloc.dart';
import 'package:appflowy/shared/appflowy_cache_manager.dart';
import 'package:appflowy/startup/startup.dart';
import 'package:appflowy/util/share_log_files.dart';
import 'package:appflowy/workspace/application/settings/appearance/appearance_cubit.dart';
import 'package:appflowy/workspace/application/settings/settings_dialog_bloc.dart';
import 'package:appflowy/workspace/presentation/settings/pages/settings_account_view.dart';
import 'package:appflowy/workspace/presentation/settings/pages/settings_manage_data_view.dart';
import 'package:appflowy/workspace/presentation/settings/pages/settings_shortcuts_view.dart';
import 'package:appflowy/workspace/presentation/settings/pages/settings_workspace_view.dart';
import 'package:appflowy/workspace/presentation/settings/shared/settings_category.dart';
import 'package:appflowy/workspace/presentation/settings/widgets/feature_flags/feature_flag_page.dart';
import 'package:appflowy/workspace/presentation/settings/widgets/settings_menu.dart';
import 'package:appflowy/workspace/presentation/settings/widgets/settings_notifications_view.dart';
import 'package:appflowy/workspace/presentation/widgets/dialogs.dart';
import 'package:appflowy_backend/protobuf/flowy-user/protobuf.dart';
import 'package:appflowy_ui/appflowy_ui.dart';
import 'package:flowy_infra_ui/flowy_infra_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'pages/setting_ai_view/local_settings_ai_view.dart';

@visibleForTesting
const kSelfHostedTextInputFieldKey =
    ValueKey('self_hosted_url_input_text_field');
@visibleForTesting
const kSelfHostedWebTextInputFieldKey =
    ValueKey('self_hosted_web_url_input_text_field');

class SettingsDialog extends StatelessWidget {
  SettingsDialog(
    this.user, {
    required this.dismissDialog,
    required this.didLogout,
    required this.restartApp,
    this.initPage,
  }) : super(key: ValueKey(user.id));

  final UserProfilePB user;
  final SettingsPage? initPage;
  final VoidCallback dismissDialog;
  final VoidCallback didLogout;
  final VoidCallback restartApp;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.6;
    final theme = AppFlowyTheme.of(context);
    final currentWorkspaceMemberRole =
        context.read<UserWorkspaceBloc>().state.currentWorkspace?.role;
    return BlocProvider<SettingsDialogBloc>(
      create: (context) => SettingsDialogBloc(
        user,
        currentWorkspaceMemberRole,
        initPage: initPage,
      )..add(const SettingsDialogEvent.initial()),
      child: BlocBuilder<SettingsDialogBloc, SettingsDialogState>(
        builder: (context, state) => FlowyDialog(
          width: width,
          constraints: const BoxConstraints(minWidth: 564),
          child: ScaffoldMessenger(
            child: Scaffold(
              backgroundColor: theme.backgroundColorScheme.primary,
              body: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 204,
                    child: SettingsMenu(
                      userProfile: user,
                      changeSelectedPage: (index) => context
                          .read<SettingsDialogBloc>()
                          .add(SettingsDialogEvent.setSelectedPage(index)),
                      currentPage:
                          context.read<SettingsDialogBloc>().state.page,
                      currentUserRole: currentWorkspaceMemberRole,
                      isBillingEnabled: state.isBillingEnabled,
                    ),
                  ),
                  AFDivider(
                    axis: Axis.vertical,
                    color: theme.borderColorScheme.primary,
                  ),
                  BlocBuilder<UserWorkspaceBloc, UserWorkspaceState>(
                    builder: (context, state) {
                      return Expanded(
                        child: getSettingsView(
                          state.currentWorkspace!,
                          context.read<SettingsDialogBloc>().state.page,
                          state.userProfile,
                          state.currentWorkspace?.role,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getSettingsView(
    UserWorkspacePB workspace,
    SettingsPage page,
    UserProfilePB user,
    AFRolePB? currentWorkspaceMemberRole,
  ) {
    switch (page) {
      case SettingsPage.account:
        return SettingsAccountView(
          userProfile: user,
          didLogout: didLogout,
          didLogin: dismissDialog,
        );
      case SettingsPage.workspace:
        return SettingsWorkspaceView(
          userProfile: user,
          currentWorkspaceMemberRole: currentWorkspaceMemberRole,
        );
      case SettingsPage.manageData:
        return SettingsManageDataView(
          userProfile: user,
          workspace: workspace,
        );
      case SettingsPage.notifications:
        return const SettingsNotificationsView();
      case SettingsPage.shortcuts:
        return const SettingsShortcutsView();
      case SettingsPage.ai:
        // Local-only build: always use the local AI settings view.
        return LocalSettingsAIView(
          key: ValueKey(workspace.workspaceId),
          userProfile: user,
          workspaceId: workspace.workspaceId,
        );
      case SettingsPage.featureFlags:
        return const FeatureFlagsPage();
      default:
        // Local-only build: plan/billing/sites pages are unreachable.
        return const SizedBox.shrink();
    }
  }
}

class SimpleSettingsDialog extends StatefulWidget {
  const SimpleSettingsDialog({super.key});

  @override
  State<SimpleSettingsDialog> createState() => _SimpleSettingsDialogState();
}

class _SimpleSettingsDialogState extends State<SimpleSettingsDialog> {
  SettingsPage page = SettingsPage.account;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppearanceSettingsCubit>().state;

    return FlowyDialog(
      width: MediaQuery.of(context).size.width * 0.7,
      constraints: const BoxConstraints(maxWidth: 784, minWidth: 564),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // header
              FlowyText(
                '设置',
                fontSize: 36.0,
                fontWeight: FontWeight.w600,
              ),
              const VSpace(18.0),


              // support
              _SupportSettings(key: ValueKey('support${settings.hashCode}')),
            ],
          ),
        ),
      ),
    );
  }
}

class _SupportSettings extends StatelessWidget {
  const _SupportSettings({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsCategory(
      title: '支持',
      children: [
        // export logs
        Row(
          children: [
            FlowyText(
              '导出日志文件',
            ),
            const Spacer(),
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 78),
              child: OutlinedRoundedButton(
                text: '导出',
                onTap: () {
                  shareLogFiles(context);
                },
              ),
            ),
          ],
        ),
        // clear cache
        Row(
          children: [
            FlowyText(
              '清空缓存',
            ),
            const Spacer(),
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 78),
              child: OutlinedRoundedButton(
                text: '清空',
                onTap: () async {
                  await getIt<FlowyCacheManager>().clearAllCache();
                  if (context.mounted) {
                    showToastNotification(
                      message: '缓存已清除！',
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SelfHostUrlField extends StatelessWidget {
  const _SelfHostUrlField({
    required this.textController,
    required this.title,
    required this.hintText,
    required this.onSave,
    this.textFieldKey,
    this.hintBuilder,
  });

  final TextEditingController textController;
  final String title;
  final String hintText;
  final ValueChanged<String> onSave;
  final Key? textFieldKey;
  final WidgetBuilder? hintBuilder;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHintWidget(context),
        const VSpace(6.0),
        SizedBox(
          height: 36,
          child: FlowyTextField(
            key: textFieldKey,
            controller: textController,
            autoFocus: false,
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            hintText: hintText,
            onEditingComplete: () => onSave(textController.text),
          ),
        ),
      ],
    );
  }

  Widget _buildHintWidget(BuildContext context) {
    return Row(
      children: [
        FlowyText(
          title,
          overflow: TextOverflow.ellipsis,
        ),
        hintBuilder?.call(context) ?? const SizedBox.shrink(),
      ],
    );
  }
}
