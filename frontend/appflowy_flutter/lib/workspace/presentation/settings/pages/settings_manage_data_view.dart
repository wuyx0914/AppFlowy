import 'dart:async';

import 'package:appflowy/core/helpers/url_launcher.dart';
import 'package:appflowy/features/settings/settings.dart';
import 'package:appflowy/generated/flowy_svgs.g.dart';
import 'package:appflowy/shared/appflowy_cache_manager.dart';
import 'package:appflowy/startup/startup.dart';
import 'package:appflowy/util/share_log_files.dart';
import 'package:appflowy/workspace/application/settings/setting_file_importer_bloc.dart';
import 'package:appflowy/workspace/presentation/home/toast.dart';
import 'package:appflowy/workspace/presentation/settings/pages/fix_data_widget.dart';
import 'package:appflowy/workspace/presentation/settings/shared/settings_body.dart';
import 'package:appflowy/workspace/presentation/settings/shared/settings_category.dart';
import 'package:appflowy/workspace/presentation/settings/shared/single_setting_action.dart';
import 'package:appflowy/workspace/presentation/settings/widgets/files/settings_export_file_widget.dart';
import 'package:appflowy/workspace/presentation/widgets/dialog_v2.dart';
import 'package:appflowy/workspace/presentation/widgets/dialogs.dart';
import 'package:appflowy_backend/protobuf/flowy-user/protobuf.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_ui/appflowy_ui.dart';
import 'package:flowy_infra/file_picker/file_picker_service.dart';
import 'package:flowy_infra/theme_extension.dart';
import 'package:flowy_infra_ui/flowy_infra_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../shared/setting_action.dart';

class SettingsManageDataView extends StatelessWidget {
  const SettingsManageDataView({
    super.key,
    required this.workspace,
    required this.userProfile,
  });

  final UserWorkspacePB workspace;
  final UserProfilePB userProfile;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DataLocationBloc>(
      create: (_) => DataLocationBloc(
        repository: const RustSettingsRepositoryImpl(),
      )..add(DataLocationEvent.initial()),
      child: BlocConsumer<DataLocationBloc, DataLocationState>(
        listenWhen: (previous, current) =>
            previous.didResetToDefault != current.didResetToDefault,
        listener: (context, state) {
          if (state.didResetToDefault) {
            Navigator.of(context).pop();
            runAppFlowy(isAnon: true);
          }
        },
        builder: (context, state) {
          // final _ = state.userDataLocation?.isCustom ?? false;
          final isCloudWorkspace =
              workspace.workspaceType == WorkspaceTypePB.ServerW;
          final path = state.userDataLocation?.path;

          return SettingsBody(
            title: '管理数据',
            description: '管理数据本地存储或将现有数据导入@:appName 。',
            children: [
              SettingsCategory(
                title:
                    '文件存储位置',
                tooltip:
                    '你的文件存储位置',
                actions: [
                  if (isCloudWorkspace)
                    SettingAction(
                      tooltip: '重置为默认位置',
                      icon: const FlowySvg(
                        FlowySvgs.restore_s,
                        size: Size.square(20),
                      ),
                      label: '重置',
                      onPressed: () {
                        showSimpleAFDialog(
                          context: context,
                          title: '你确定吗？',
                          content: '将数据路径重置为默认位置不会删除你的数据。如果你想重新导入当前数据，你应该先复制当前位置的路径。',
                          primaryAction: (
                            '确认',
                            (_) {
                              context
                                  .read<DataLocationBloc>()
                                  .add(DataLocationResetToDefault());
                            }
                          ),
                          secondaryAction: (
                            '取消',
                            (_) {},
                          ),
                        );
                      },
                    ),
                ],
                children: path == null
                    ? [
                        const CircularProgressIndicator(),
                      ]
                    : [
                        _CurrentPath(path: path),
                        if (isCloudWorkspace) _DataPathActions(path: path),
                      ],
              ),
              SettingsCategory(
                title: '导入数据',
                tooltip:
                    '从 @:appName 备份/数据文件夹导入数据',
                children: const [_ImportDataField()],
              ),
              if (kDebugMode) ...[
                SettingsCategory(
                  title: '导出您的数据',
                  children: const [
                    SettingsExportFileWidget(),
                    FixDataWidget(),
                  ],
                ),
              ],
              SettingsCategory(
                title: '导出日志文件',
                children: [
                  SingleSettingAction(
                    labelMaxLines: 4,
                    label:
                        '导出日志文件',
                    buttonLabel: '导出',
                    onPressed: () {
                      shareLogFiles(context);
                    },
                  ),
                ],
              ),
              SettingsCategory(
                title: '清除缓存',
                children: [
                  SingleSettingAction(
                    labelMaxLines: 4,
                    label: '如果你遇到图片无法加载或字体无法正确显示的问题，请尝试清除缓存。此操作不会删除你的用户数据。',
                    buttonLabel:
                        '清除缓存',
                    onPressed: () {
                      showCancelAndConfirmDialog(
                        context: context,
                        title: '清除缓存',
                        description: '清除缓存会导致加载时重新下载图像和字体。此操作不会删除或修改你的数据。',
                        confirmLabel: 'OK',
                        onConfirm: (_) async {
                          // clear all cache
                          await getIt<FlowyCacheManager>().clearAllCache();

                          // check the workspace and space health
                          await WorkspaceDataManager.checkViewHealth(
                            dryRun: false,
                          );

                          if (context.mounted) {
                            showToastNotification(
                              message: '缓存已清除！',
                            );
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

// class _EncryptDataSetting extends StatelessWidget {
//   const _EncryptDataSetting({required this.userProfile});

//   final UserProfilePB userProfile;

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider<EncryptSecretBloc>.value(
//       value: context.read<EncryptSecretBloc>(),
//       child: BlocBuilder<EncryptSecretBloc, EncryptSecretState>(
//         builder: (context, state) {
//           if (state.loadingState?.isLoading() == true) {
//             return const Row(
//               children: [
//                 SizedBox(
//                   width: 20,
//                   height: 20,
//                   child: CircularProgressIndicator(
//                     strokeWidth: 3,
//                   ),
//                 ),
//                 HSpace(16),
//                 FlowyText.medium(
//                   'Encrypting data...',
//                   fontSize: 14,
//                 ),
//               ],
//             );
//           }

//           if (userProfile.encryptionType == EncryptionTypePB.NoEncryption) {
//             return Row(
//               children: [
//                 SizedBox(
//                   height: 42,
//                   child: FlowyTextButton(
//                     '加密数据',
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 24,
//                       vertical: 12,
//                     ),
//                     fontWeight: FontWeight.w600,
//                     radius: BorderRadius.circular(12),
//                     fillColor: Theme.of(context).colorScheme.primary,
//                     hoverColor: const Color(0xFF005483),
//                     fontHoverColor: Colors.white,
//                     onPressed: () => SettingsAlertDialog(
//                           .settings_manageDataPage_encryption_dialog_title
//                           .settings_manageDataPage_encryption_dialog_description
//                           .settings_manageDataPage_encryption_dialog_title
//                       implyLeading: true,
//                       // Generate a secret one time for the user
//                       confirm: () => context
//                           .read<EncryptSecretBloc>()
//                           .add(const EncryptSecretEvent.setEncryptSecret('')),
//                     ).show(context),
//                   ),
//                 ),
//               ],
//             );
//           }
//           // Show encryption secret for copy/save
//           return const SizedBox.shrink();
//         },
//       ),
//     );
//   }
// }

class _ImportDataField extends StatefulWidget {
  const _ImportDataField();

  @override
  State<_ImportDataField> createState() => _ImportDataFieldState();
}

class _ImportDataFieldState extends State<_ImportDataField> {
  final _fToast = FToast();

  @override
  void initState() {
    super.initState();
    _fToast.init(context);
  }

  @override
  void dispose() {
    _fToast.removeQueuedCustomToasts();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SettingFileImportBloc>(
      create: (context) => SettingFileImportBloc(),
      child: BlocConsumer<SettingFileImportBloc, SettingFileImportState>(
        listenWhen: (previous, current) =>
            previous.successOrFail != current.successOrFail,
        listener: (_, state) => state.successOrFail?.fold(
          (_) => _showToast('成功导入@:appName数据文件夹'),
          (_) => _showToast('导入 @:appName 数据文件夹失败'),
        ),
        builder: (context, state) {
          return SingleSettingAction(
            label:
                '从外部 @:appName 数据文件夹复制数据',
            labelMaxLines: 2,
            buttonLabel:
                '浏览文件夹',
            onPressed: () async {
              final path = await getIt<FilePickerService>().getDirectoryPath();
              if (path == null || !context.mounted) {
                return;
              }

              context
                  .read<SettingFileImportBloc>()
                  .add(SettingFileImportEvent.importAppFlowyDataFolder(path));
            },
          );
        },
      ),
    );
  }

  void _showToast(String message) {
    _fToast.showToast(
      child: FlowyMessageToast(message: message),
      gravity: ToastGravity.CENTER,
    );
  }
}

class _CurrentPath extends StatefulWidget {
  const _CurrentPath({required this.path});

  final String path;

  @override
  State<_CurrentPath> createState() => _CurrentPathState();
}

class _CurrentPathState extends State<_CurrentPath> {
  Timer? linkCopiedTimer;
  bool showCopyMessage = false;
  bool isHovering = false;

  @override
  void dispose() {
    linkCopiedTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppFlowyTheme.of(context);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: FlowyTooltip(
                message: '打开当前数据文件夹位置',
                child: GestureDetector(
                  onTap: () => {
                    afLaunchUri(Uri.file(widget.path)),
                  },
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    onEnter: (_) => setState(() => isHovering = true),
                    onExit: (_) => setState(() => isHovering = false),
                    child: Text(
                      widget.path,
                      maxLines: 2,
                      style: theme.textStyle.body
                          .standard(color: theme.textColorScheme.action)
                          .copyWith(
                            decoration:
                                isHovering ? TextDecoration.underline : null,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ),
            HSpace(
              theme.spacing.m,
            ),
            IndexedStack(
              alignment: Alignment.centerRight,
              index: showCopyMessage ? 0 : 1,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AFThemeExtension.of(context).tint7,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: theme.spacing.l,
                    vertical: theme.spacing.m,
                  ),
                  child: Text(
                    '路径已复制！',
                    style: theme.textStyle.body.standard(
                      color: theme.textColorScheme.primary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                FlowyTooltip(
                  message: '复制路径',
                  child: AFGhostButton.normal(
                    builder: (context, _, __) {
                      return FlowySvg(
                        FlowySvgs.copy_s,
                        size: Size.square(20),
                        color: theme.textColorScheme.primary,
                      );
                    },
                    padding: EdgeInsets.all(theme.spacing.m),
                    onTap: () => _copyLink(widget.path),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  void _copyLink(String? path) {
    AppFlowyClipboard.setData(text: path);
    setState(() => showCopyMessage = true);
    linkCopiedTimer?.cancel();
    linkCopiedTimer = Timer(
      const Duration(milliseconds: 300),
      () {
        if (mounted) {
          setState(() => showCopyMessage = false);
        }
      },
    );
  }
}

class _DataPathActions extends StatelessWidget {
  const _DataPathActions({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return AFFilledTextButton.primary(
      text: '更改路径',
      onTap: () async {
        final path = await getIt<FilePickerService>().getDirectoryPath();
        if (!context.mounted || path == null || path == path) {
          return;
        }

        context
            .read<DataLocationBloc>()
            .add(DataLocationEvent.setCustomPath(path));
      },
    );
  }
}
