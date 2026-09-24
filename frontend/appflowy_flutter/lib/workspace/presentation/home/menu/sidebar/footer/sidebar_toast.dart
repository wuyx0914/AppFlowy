import 'dart:io';

import 'package:appflowy/features/workspace/logic/workspace_bloc.dart';
import 'package:appflowy/generated/flowy_svgs.g.dart';
import 'package:appflowy/shared/af_role_pb_extension.dart';
import 'package:appflowy/workspace/application/settings/plan/workspace_subscription_ext.dart';
import 'package:appflowy/workspace/application/settings/settings_dialog_bloc.dart';
import 'package:appflowy/workspace/application/sidebar/billing/sidebar_plan_bloc.dart';
import 'package:appflowy/workspace/presentation/home/menu/sidebar/shared/sidebar_setting.dart';
import 'package:appflowy/workspace/presentation/widgets/dialogs.dart';
import 'package:appflowy_backend/log.dart';
import 'package:appflowy_backend/protobuf/flowy-user/workspace.pb.dart';
import 'package:flowy_infra/theme_extension.dart';
import 'package:flowy_infra_ui/flowy_infra_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SidebarToast extends StatelessWidget {
  const SidebarToast({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SidebarPlanBloc, SidebarPlanState>(
      listener: (_, state) {
        // Show a dialog when the user hits the storage limit, After user click ok, it will navigate to the plan page.
        // Even though the dislog is dissmissed, if the user triggers the storage limit again, the dialog will show again.
        state.tierIndicator.maybeWhen(
          storageLimitHit: () => WidgetsBinding.instance.addPostFrameCallback(
            (_) => _showStorageLimitDialog(context),
          ),
          singleFileLimitHit: () =>
              WidgetsBinding.instance.addPostFrameCallback(
            (_) => _showSingleFileLimitDialog(context),
          ),
          orElse: () {},
        );
      },
      builder: (_, state) {
        return state.tierIndicator.when(
          loading: () => const SizedBox.shrink(),
          storageLimitHit: () => PlanIndicator(
            planName: SubscriptionPlanPB.Free.label,
            text: '升级至专业版',
            onTap: () => _handleOnTap(context, SubscriptionPlanPB.Pro),
            reason: '你已用尽免费存储。升级以解锁无限制存储',
          ),
          aiMaxiLimitHit: () => PlanIndicator(
            planName: SubscriptionPlanPB.AiMax.label,
            text: '解锁无限制 AI',
            onTap: () => _handleOnTap(context, SubscriptionPlanPB.AiMax),
            reason: '你已用尽免费 AI 回应。升级到专业版或者购买 AI 插件来解锁无限制回应',
          ),
          singleFileLimitHit: () => const SizedBox.shrink(),
        );
      },
    );
  }

  void _showStorageLimitDialog(BuildContext context) => showConfirmDialog(
        context: context,
        title: '购买存储空间',
        description: '你已用尽免费存储。升级以解锁无限制存储',
        confirmLabel:
            '升级',
        onConfirm: (_) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _handleOnTap(context, SubscriptionPlanPB.Pro),
          );
        },
      );

  void _showSingleFileLimitDialog(BuildContext context) => showConfirmDialog(
        context: context,
        title: '升级至专业版',
        description:
            '您已超过免费方案允许的最大文件上传容量。请升级到专业版以上传更大的文件',
        confirmLabel:
            '升级',
        onConfirm: (_) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _handleOnTap(context, SubscriptionPlanPB.Pro),
          );
        },
      );

  void _handleOnTap(BuildContext context, SubscriptionPlanPB plan) {
    final userProfile = context.read<SidebarPlanBloc>().state.userProfile;
    if (userProfile == null) {
      return Log.error(
        'UserProfile is null, this should NOT happen! Please file a bug report',
      );
    }

    final userWorkspaceBloc = context.read<UserWorkspaceBloc>();
    final role = userWorkspaceBloc.state.currentWorkspace?.role;
    if (role == null) {
      return Log.error(
        "Member is null. It should not happen. If you see this error, it's a bug",
      );
    }

    // Only if the user is the workspace owner will we navigate to the plan page.
    if (role.isOwner) {
      showSettingsDialog(
        context,
        userWorkspaceBloc: userWorkspaceBloc,
        initPage: SettingsPage.plan,
      );
    } else {
      final String message;
      if (plan == SubscriptionPlanPB.AiMax) {
        message = Platform.isIOS
            ? '你的工作区即将用尽免费 AI 回应限额。'
            : '你的工作区即将用尽免费 AI 回应。请联系工作区所有者升级计划或购买 AI 插件';
      } else {
        message = Platform.isIOS
            ? '你的工作区即将用尽免费存储。'
            : '你的工作区即将用尽免费存储。请联系工作区所有者升级到专业版计划';
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        useRootNavigator: false,
        builder: (dialogContext) => _AskOwnerToChangePlan(
          message: message,
          onOkPressed: () {},
        ),
      );
    }
  }
}

class PlanIndicator extends StatefulWidget {
  const PlanIndicator({
    super.key,
    required this.planName,
    required this.text,
    required this.onTap,
    required this.reason,
  });

  final String planName;
  final String reason;
  final String text;
  final Function() onTap;

  @override
  State<PlanIndicator> createState() => _PlanIndicatorState();
}

class _PlanIndicatorState extends State<PlanIndicator> {
  final popoverController = PopoverController();

  @override
  void dispose() {
    popoverController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const textGradient = LinearGradient(
      begin: Alignment.bottomLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF8032FF), Color(0xFFEF35FF)],
      stops: [0.1545, 0.8225],
    );

    final backgroundGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFF8032FF).withValues(alpha: .1),
        const Color(0xFFEF35FF).withValues(alpha: .1),
      ],
    );

    return AppFlowyPopover(
      controller: popoverController,
      direction: PopoverDirection.rightWithBottomAligned,
      offset: const Offset(10, -12),
      popupBuilder: (context) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FlowyText(
                widget.text,
                color: AFThemeExtension.of(context).strongText,
              ),
              const VSpace(12),
              Opacity(
                opacity: 0.7,
                child: FlowyText.regular(
                  widget.reason,
                  maxLines: null,
                  lineHeight: 1.3,
                  textAlign: TextAlign.center,
                ),
              ),
              const VSpace(12),
              Row(
                children: [
                  Expanded(
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          popoverController.close();
                          widget.onTap();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Center(
                            child: FlowyText(
                              '升级',
                              color: Colors.white,
                              fontSize: 12,
                              strutStyle: const StrutStyle(
                                forceStrutHeight: true,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            gradient: backgroundGradient,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const FlowySvg(
                FlowySvgs.upgrade_storage_s,
                blendMode: null,
              ),
              const HSpace(6),
              ShaderMask(
                shaderCallback: (bounds) => textGradient.createShader(bounds),
                blendMode: BlendMode.srcIn,
                child: FlowyText(
                  widget.text,
                  color: AFThemeExtension.of(context).strongText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AskOwnerToChangePlan extends StatelessWidget {
  const _AskOwnerToChangePlan({
    required this.message,
    required this.onOkPressed,
  });
  final String message;
  final VoidCallback onOkPressed;

  @override
  Widget build(BuildContext context) {
    return NavigatorOkCancelDialog(
      message: message,
      okTitle: 'OK',
      onOkPressed: onOkPressed,
      titleUpperCase: false,
    );
  }
}
