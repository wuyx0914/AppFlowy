import 'package:appflowy/generated/flowy_svgs.g.dart';
import 'package:appflowy/shared/loading.dart';
import 'package:appflowy/util/theme_extension.dart';
import 'package:appflowy/workspace/application/settings/plan/settings_plan_bloc.dart';
import 'package:appflowy/workspace/application/settings/plan/workspace_subscription_ext.dart';
import 'package:appflowy/workspace/presentation/home/menu/sidebar/space/shared_widget.dart';
import 'package:appflowy/workspace/presentation/settings/widgets/cancel_plan_survey_dialog.dart';
import 'package:appflowy/workspace/presentation/widgets/dialogs.dart';
import 'package:appflowy_backend/protobuf/flowy-user/protobuf.dart';
import 'package:flowy_infra/theme_extension.dart';
import 'package:flowy_infra_ui/flowy_infra_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsPlanComparisonDialog extends StatefulWidget {
  const SettingsPlanComparisonDialog({
    super.key,
    required this.workspaceId,
    required this.subscriptionInfo,
  });

  final String workspaceId;
  final WorkspaceSubscriptionInfoPB subscriptionInfo;

  @override
  State<SettingsPlanComparisonDialog> createState() =>
      _SettingsPlanComparisonDialogState();
}

class _SettingsPlanComparisonDialogState
    extends State<SettingsPlanComparisonDialog> {
  final horizontalController = ScrollController();
  final verticalController = ScrollController();

  late WorkspaceSubscriptionInfoPB currentInfo = widget.subscriptionInfo;

  Loading? loadingIndicator;

  @override
  void dispose() {
    horizontalController.dispose();
    verticalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLM = Theme.of(context).isLightMode;

    return BlocConsumer<SettingsPlanBloc, SettingsPlanState>(
      listener: (context, state) {
        final readyState = state.mapOrNull(ready: (state) => state);

        if (readyState == null) {
          return;
        }

        if (readyState.downgradeProcessing) {
          loadingIndicator = Loading(context)..start();
        } else {
          loadingIndicator?.stop();
          loadingIndicator = null;
        }

        if (readyState.successfulPlanUpgrade != null) {
          showConfirmDialog(
            context: context,
            title: '您现在在{readyState.successfulPlanUpgrade!.label}方案中!',
            description: '您的付款已成功处理，您的方案已升级至 AppFlowy {readyState.successfulPlanUpgrade!.label}。 您可以在方案页面查看您的方案详细信息。',
            confirmLabel: '关闭',
            onConfirm: (_) {},
          );
        }

        setState(() => currentInfo = readyState.subscriptionInfo);
      },
      builder: (context, state) => FlowyDialog(
        constraints: const BoxConstraints(maxWidth: 784, minWidth: 674),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 24, left: 24, right: 24),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FlowyText.semibold(
                    '比较并选择方案',
                    fontSize: 24,
                    color: AFThemeExtension.of(context).strongText,
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(
                      currentInfo.plan != widget.subscriptionInfo.plan,
                    ),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: FlowySvg(
                        FlowySvgs.m_close_m,
                        size: const Size.square(20),
                        color: AFThemeExtension.of(context).strongText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const VSpace(16),
            Flexible(
              child: SingleChildScrollView(
                controller: horizontalController,
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  controller: verticalController,
                  padding: const EdgeInsets.only(
                    left: 24,
                    right: 24,
                    bottom: 24,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 250,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const VSpace(30),
                                SizedBox(
                                  height: 116,
                                  child: FlowyText.semibold(
                                    '方案\n功能',
                                    fontSize: 24,
                                    maxLines: 2,
                                    color: isLM
                                        ? const Color(0xFF5C3699)
                                        : const Color(0xFFE8E0FF),
                                  ),
                                ),
                                const SizedBox(height: 116),
                                const SizedBox(height: 56),
                                ..._planLabels.map(
                                  (e) => _ComparisonCell(
                                    label: e.label,
                                    tooltip: e.tooltip,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _PlanTable(
                            title: '免费版',
                            description: '适用于最多 2 名成员，以整理所有事务',
                            price: '{SubscriptionPlanPB.Free.priceMonthBilling}',
                            priceInfo: '永远免费',
                            cells: _freeLabels,
                            isCurrent:
                                currentInfo.plan == WorkspacePlanPB.FreePlan,
                            buttonType: WorkspacePlanPB.FreePlan.buttonTypeFor(
                              currentInfo.plan,
                            ),
                            onSelected: () async {
                              if (currentInfo.plan ==
                                      WorkspacePlanPB.FreePlan ||
                                  currentInfo.isCanceled) {
                                return;
                              }

                              final reason =
                                  await showCancelSurveyDialog(context);
                              if (reason == null || !context.mounted) {
                                return;
                              }

                              await showConfirmDialog(
                                context: context,
                                title: '您确定要降级您的方案吗?',
                                description: '降级您的方案将会让您回归至免费方案。成员可能会失去访问这个工作区的权限，您可能需要释放空间以符合免费方案的保存空间限制。',
                                confirmLabel: '降级计划',
                                style: ConfirmPopupStyle.cancelAndOk,
                                onConfirm: (_) =>
                                    context.read<SettingsPlanBloc>().add(
                                          SettingsPlanEvent.cancelSubscription(
                                            reason: reason,
                                          ),
                                        ),
                              );
                            },
                          ),
                          _PlanTable(
                            title: '专业版',
                            description: '适合小型团队，用来管理项目与团队知识',
                            price: '${SubscriptionPlanPB.Pro.priceAnnualBilling}',
                            priceInfo: '每位用户每月按年计费\n\n${SubscriptionPlanPB.Pro.priceMonthBilling} 按月计费',
                            cells: _proLabels,
                            isCurrent:
                                currentInfo.plan == WorkspacePlanPB.ProPlan,
                            buttonType: WorkspacePlanPB.ProPlan.buttonTypeFor(
                              currentInfo.plan,
                            ),
                            onSelected: () =>
                                context.read<SettingsPlanBloc>().add(
                                      const SettingsPlanEvent.addSubscription(
                                        SubscriptionPlanPB.Pro,
                                      ),
                                    ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _PlanButtonType {
  none,
  upgrade,
  downgrade;

  bool get isDowngrade => this == downgrade;
  bool get isUpgrade => this == upgrade;
}

extension _ButtonTypeFrom on WorkspacePlanPB {
  /// Returns the button type for the given plan, taking the
  /// current plan as [other].
  ///
  _PlanButtonType buttonTypeFor(WorkspacePlanPB other) {
    /// Current plan, no action
    if (this == other) {
      return _PlanButtonType.none;
    }

    // Free plan, can downgrade if not on the free plan
    if (this == WorkspacePlanPB.FreePlan && other != WorkspacePlanPB.FreePlan) {
      return _PlanButtonType.downgrade;
    }

    // Else we can assume it's an upgrade
    return _PlanButtonType.upgrade;
  }
}

class _PlanTable extends StatelessWidget {
  const _PlanTable({
    required this.title,
    required this.description,
    required this.price,
    required this.priceInfo,
    required this.cells,
    required this.isCurrent,
    required this.onSelected,
    this.buttonType = _PlanButtonType.none,
  });

  final String title;
  final String description;
  final String price;
  final String priceInfo;

  final List<_CellItem> cells;
  final bool isCurrent;
  final VoidCallback onSelected;
  final _PlanButtonType buttonType;

  @override
  Widget build(BuildContext context) {
    final highlightPlan = !isCurrent && buttonType == _PlanButtonType.upgrade;
    final isLM = Theme.of(context).isLightMode;

    return Container(
      width: 215,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: !highlightPlan
            ? null
            : LinearGradient(
                colors: [
                  isLM ? const Color(0xFF251D37) : const Color(0xFF7459AD),
                  isLM ? const Color(0xFF7547C0) : const Color(0xFFDDC8FF),
                ],
              ),
      ),
      padding: !highlightPlan
          ? const EdgeInsets.only(top: 4)
          : const EdgeInsets.all(4),
      child: Container(
        padding: isCurrent
            ? const EdgeInsets.only(bottom: 22)
            : const EdgeInsets.symmetric(vertical: 22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: Theme.of(context).cardColor,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isCurrent) const _CurrentBadge(),
            const VSpace(4),
            _Heading(
              title: title,
              description: description,
              isPrimary: !highlightPlan,
            ),
            _Heading(
              title: price,
              description: priceInfo,
              isPrimary: !highlightPlan,
            ),
            if (buttonType == _PlanButtonType.none) ...[
              const SizedBox(height: 56),
            ] else ...[
              Opacity(
                opacity: 1,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 12 + (buttonType.isUpgrade ? 12 : 0),
                  ),
                  child: _ActionButton(
                    label: buttonType.isUpgrade
                        ? '升级'
                        : '降级',
                    onPressed: onSelected,
                    isUpgrade: buttonType.isUpgrade,
                    useGradientBorder: buttonType.isUpgrade,
                  ),
                ),
              ),
            ],
            ...cells.map(
              (cell) => _ComparisonCell(
                label: cell.label,
                icon: cell.icon,
                isHighlighted: highlightPlan,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrentBadge extends StatelessWidget {
  const _CurrentBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 12),
      height: 22,
      width: 72,
      decoration: BoxDecoration(
        color: Theme.of(context).isLightMode
            ? const Color(0xFF4F3F5F)
            : const Color(0xFFE8E0FF),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: FlowyText.medium(
          '目前',
          fontSize: 12,
          color: Theme.of(context).isLightMode ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}

class _ComparisonCell extends StatelessWidget {
  const _ComparisonCell({
    this.label,
    this.icon,
    this.tooltip,
    this.isHighlighted = false,
  });

  final String? label;
  final FlowySvgData? icon;
  final String? tooltip;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12) +
          EdgeInsets.only(left: isHighlighted ? 12 : 0),
      height: 36,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            FlowySvg(
              icon!,
              color: AFThemeExtension.of(context).strongText,
            ),
          ] else if (label != null) ...[
            Expanded(
              child: FlowyText.medium(
                label!,
                lineHeight: 1.2,
                color: AFThemeExtension.of(context).strongText,
              ),
            ),
          ],
          if (tooltip != null)
            FlowyTooltip(
              message: tooltip,
              child: FlowySvg(
                FlowySvgs.information_s,
                color: AFThemeExtension.of(context).strongText,
              ),
            ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.onPressed,
    required this.isUpgrade,
    this.useGradientBorder = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isUpgrade;
  final bool useGradientBorder;

  @override
  Widget build(BuildContext context) {
    final isLM = Theme.of(context).isLightMode;

    return SizedBox(
      height: 56,
      child: Row(
        children: [
          GestureDetector(
            onTap: onPressed,
            child: MouseRegion(
              cursor: onPressed != null
                  ? SystemMouseCursors.click
                  : MouseCursor.defer,
              child: _drawBorder(
                context,
                isLM: isLM,
                isUpgrade: isUpgrade,
                child: Container(
                  height: 36,
                  width: 148,
                  decoration: BoxDecoration(
                    color: useGradientBorder
                        ? Theme.of(context).cardColor
                        : Colors.transparent,
                    border: Border.all(color: Colors.transparent),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(child: _drawText(label, isLM, isUpgrade)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawText(String text, bool isLM, bool isUpgrade) {
    final child = FlowyText(
      text,
      fontSize: 14,
      lineHeight: 1.2,
      fontWeight: useGradientBorder ? FontWeight.w600 : FontWeight.w500,
      color: isUpgrade ? const Color(0xFFC49BEC) : null,
    );

    if (!useGradientBorder || !isLM) {
      return child;
    }

    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => const LinearGradient(
        transform: GradientRotation(-1.55),
        stops: [0.4, 1],
        colors: [Color(0xFF251D37), Color(0xFF7547C0)],
      ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
      child: child,
    );
  }

  Widget _drawBorder(
    BuildContext context, {
    required bool isLM,
    required bool isUpgrade,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        gradient: isUpgrade
            ? LinearGradient(
                transform: const GradientRotation(-1.2),
                stops: const [0.4, 1],
                colors: [
                  isLM ? const Color(0xFF251D37) : const Color(0xFF7459AD),
                  isLM ? const Color(0xFF7547C0) : const Color(0xFFDDC8FF),
                ],
              )
            : null,
        border: isUpgrade ? null : Border.all(color: const Color(0xFF333333)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading({
    required this.title,
    this.description,
    this.isPrimary = true,
  });

  final String title;
  final String? description;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 185,
      height: 116,
      child: Padding(
        padding: EdgeInsets.only(left: 12 + (!isPrimary ? 12 : 0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: FlowyText.semibold(
                    title,
                    fontSize: 24,
                    overflow: TextOverflow.ellipsis,
                    color: isPrimary
                        ? AFThemeExtension.of(context).strongText
                        : Theme.of(context).isLightMode
                            ? const Color(0xFF5C3699)
                            : const Color(0xFFC49BEC),
                  ),
                ),
              ],
            ),
            if (description != null && description!.isNotEmpty) ...[
              const VSpace(4),
              Flexible(
                child: FlowyText.regular(
                  description!,
                  fontSize: 12,
                  maxLines: 5,
                  lineHeight: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PlanItem {
  const _PlanItem({required this.label, this.tooltip});

  final String label;
  final String? tooltip;
}

final _planLabels = [
  _PlanItem(
    label: '工作区',
  ),
  _PlanItem(
    label: '成员',
  ),
  _PlanItem(
    label: '保存空间',
  ),
  _PlanItem(
    label: '即时协作',
  ),
  _PlanItem(
    label: '客户编辑器',
    tooltip: '与非会员共同编辑特定页面',
  ),
  _PlanItem(
    label:
        '智能搜索',
  ),
  _PlanItem(
    label: 'AI 回应',
    tooltip: '终身代表回应次数永远不会重设',
  ),
  _PlanItem(
    label: 'AI 图像',
    tooltip: '终身代表回应次数永远不会重设',
  ),
  _PlanItem(
    label: '文件上传',
  ),
  _PlanItem(
    label:
        '自订命名空间',
    tooltip: '自订发布网站网址',
  ),
];

class _CellItem {
  const _CellItem({this.label, this.icon});

  final String? label;
  final FlowySvgData? icon;
}

final List<_CellItem> _freeLabels = [
  _CellItem(
    label: '每个工作区收取费用',
  ),
  _CellItem(
    label: '最多 2 个',
  ),
  _CellItem(
    label: '5 GB',
  ),
  _CellItem(
    label: '是的',
    icon: FlowySvgs.check_m,
  ),
  _CellItem(
    label: '是的',
  ),
  _CellItem(
    label:
        '智能搜索',
    icon: FlowySvgs.check_m,
  ),
  _CellItem(
    label: '终身 10 次',
  ),
  _CellItem(
    label: '终身 2 次',
  ),
  _CellItem(
    label: '最多 7 MB',
  ),
  const _CellItem(
    label: '',
  ),
];

final List<_CellItem> _proLabels = [
  _CellItem(
    label: '每个工作区收取费用',
  ),
  _CellItem(
    label: '最多十个',
  ),
  _CellItem(
    label: '无限',
  ),
  _CellItem(
    label: '是',
    icon: FlowySvgs.check_m,
  ),
  _CellItem(
    label: '是',
  ),
  _CellItem(
    label:
        '智能搜索',
    icon: FlowySvgs.check_m,
  ),
  _CellItem(
    label: '无限',
  ),
  _CellItem(
    label: '每月 50 张图片',
  ),
  _CellItem(
    label: '无限',
  ),
  const _CellItem(
    label: '',
    icon: FlowySvgs.check_m,
  ),
];
