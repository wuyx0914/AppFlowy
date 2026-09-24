import 'package:appflowy/shared/flowy_error_page.dart';
import 'package:appflowy/shared/loading.dart';
import 'package:appflowy/util/int64_extension.dart';
import 'package:appflowy/workspace/application/settings/appearance/appearance_cubit.dart';
import 'package:appflowy/workspace/application/settings/billing/settings_billing_bloc.dart';
import 'package:appflowy/workspace/application/settings/date_time/date_format_ext.dart';
import 'package:appflowy/workspace/application/settings/plan/settings_plan_bloc.dart';
import 'package:appflowy/workspace/application/settings/plan/workspace_subscription_ext.dart';
import 'package:appflowy/workspace/presentation/home/menu/sidebar/space/shared_widget.dart';
import 'package:appflowy/workspace/presentation/settings/pages/settings_plan_comparison_dialog.dart';
import 'package:appflowy/workspace/presentation/settings/shared/settings_alert_dialog.dart';
import 'package:appflowy/workspace/presentation/settings/shared/settings_body.dart';
import 'package:appflowy/workspace/presentation/settings/shared/settings_category.dart';
import 'package:appflowy/workspace/presentation/settings/shared/settings_dashed_divider.dart';
import 'package:appflowy/workspace/presentation/settings/shared/single_setting_action.dart';
import 'package:appflowy/workspace/presentation/widgets/dialogs.dart';
import 'package:appflowy_backend/protobuf/flowy-user/protobuf.dart';
import 'package:collection/collection.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flowy_infra_ui/style_widget/text.dart';
import 'package:flowy_infra_ui/widget/spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const _buttonsMinWidth = 100.0;

class SettingsBillingView extends StatefulWidget {
  const SettingsBillingView({
    super.key,
    required this.workspaceId,
    required this.user,
  });

  final String workspaceId;
  final UserProfilePB user;

  @override
  State<SettingsBillingView> createState() => _SettingsBillingViewState();
}

class _SettingsBillingViewState extends State<SettingsBillingView> {
  Loading? loadingIndicator;
  RecurringIntervalPB? selectedInterval;
  final ValueNotifier<bool> enablePlanChangeNotifier = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SettingsBillingBloc>(
      create: (_) => SettingsBillingBloc(
        workspaceId: widget.workspaceId,
        userId: widget.user.id,
      )..add(const SettingsBillingEvent.started()),
      child: BlocConsumer<SettingsBillingBloc, SettingsBillingState>(
        listenWhen: (previous, current) =>
            previous.mapOrNull(ready: (s) => s.isLoading) !=
            current.mapOrNull(ready: (s) => s.isLoading),
        listener: (context, state) {
          if (state.mapOrNull(ready: (s) => s.isLoading) == true) {
            loadingIndicator = Loading(context)..start();
          } else {
            loadingIndicator?.stop();
            loadingIndicator = null;
          }
        },
        builder: (context, state) {
          return state.map(
            initial: (_) => const SizedBox.shrink(),
            loading: (_) => const Center(
              child: SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator.adaptive(strokeWidth: 3),
              ),
            ),
            error: (state) {
              if (state.error != null) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: AppFlowyErrorPage(
                      error: state.error!,
                    ),
                  ),
                );
              }

              return ErrorWidget.withDetails(message: 'Something went wrong!');
            },
            ready: (state) {
              final billingPortalEnabled =
                  state.subscriptionInfo.isBillingPortalEnabled;

              return SettingsBody(
                title: '帐单',
                children: [
                  SettingsCategory(
                    title: '方案',
                    children: [
                      SingleSettingAction(
                        onPressed: () => _openPricingDialog(
                          context,
                          widget.workspaceId,
                          widget.user.id,
                          state.subscriptionInfo,
                        ),
                        fontWeight: FontWeight.w500,
                        label: state.subscriptionInfo.label,
                        buttonLabel: '变更计划',
                        minWidth: _buttonsMinWidth,
                      ),
                      if (billingPortalEnabled)
                        SingleSettingAction(
                          onPressed: () {
                            SettingsAlertDialog(
                              title: '变更周期',
                              enableConfirmNotifier: enablePlanChangeNotifier,
                              children: [
                                ChangePeriod(
                                  plan: state.subscriptionInfo.planSubscription
                                      .subscriptionPlan,
                                  selectedInterval: state.subscriptionInfo
                                      .planSubscription.interval,
                                  onSelected: (interval) {
                                    enablePlanChangeNotifier.value = interval !=
                                        state.subscriptionInfo.planSubscription
                                            .interval;
                                    selectedInterval = interval;
                                  },
                                ),
                              ],
                              confirm: () {
                                if (selectedInterval !=
                                    state.subscriptionInfo.planSubscription
                                        .interval) {
                                  context.read<SettingsBillingBloc>().add(
                                        SettingsBillingEvent.updatePeriod(
                                          plan: state
                                              .subscriptionInfo
                                              .planSubscription
                                              .subscriptionPlan,
                                          interval: selectedInterval!,
                                        ),
                                      );
                                }
                                Navigator.of(context).pop();
                              },
                            ).show(context);
                          },
                          label: '计费周期',
                          description: state
                              .subscriptionInfo.planSubscription.interval.label,
                          fontWeight: FontWeight.w500,
                          buttonLabel: '编辑期间',
                          minWidth: _buttonsMinWidth,
                        ),
                    ],
                  ),
                  if (billingPortalEnabled)
                    SettingsCategory(
                      title: '付款信息',
                      children: [
                        SingleSettingAction(
                          onPressed: () => context
                              .read<SettingsBillingBloc>()
                              .add(
                                const SettingsBillingEvent.openCustomerPortal(),
                              ),
                          label: '付款方式',
                          fontWeight: FontWeight.w500,
                          buttonLabel: '编辑方式',
                          minWidth: _buttonsMinWidth,
                        ),
                      ],
                    ),
                  SettingsCategory(
                    title: '附加组件',
                    children: [
                      _AITile(
                        plan: SubscriptionPlanPB.AiMax,
                        label: 'AI Max',
                        description: '解锁无限 AI 和高端模型',
                        activeDescription: '下期帐单到期日为 {}',
                        canceledDescription: 'AI 最大将于 {} 激活',
                        subscriptionInfo:
                            state.subscriptionInfo.addOns.firstWhereOrNull(
                          (a) => a.type == WorkspaceAddOnPBType.AddOnAiMax,
                        ),
                      ),
                      const SettingsDashedDivider(),
                    ],
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _openPricingDialog(
    BuildContext context,
    String workspaceId,
    Int64 userId,
    WorkspaceSubscriptionInfoPB subscriptionInfo,
  ) =>
      showDialog<bool?>(
        context: context,
        builder: (_) => BlocProvider<SettingsPlanBloc>(
          create: (_) =>
              SettingsPlanBloc(workspaceId: workspaceId, userId: widget.user.id)
                ..add(const SettingsPlanEvent.started()),
          child: SettingsPlanComparisonDialog(
            workspaceId: workspaceId,
            subscriptionInfo: subscriptionInfo,
          ),
        ),
      ).then((didChangePlan) {
        if (didChangePlan == true && context.mounted) {
          context
              .read<SettingsBillingBloc>()
              .add(const SettingsBillingEvent.started());
        }
      });
}

class _AITile extends StatefulWidget {
  const _AITile({
    required this.label,
    required this.description,
    required this.canceledDescription,
    required this.activeDescription,
    required this.plan,
    this.subscriptionInfo,
  });

  final String label;
  final String description;
  final String canceledDescription;
  final String activeDescription;
  final SubscriptionPlanPB plan;
  final WorkspaceAddOnPB? subscriptionInfo;

  @override
  State<_AITile> createState() => _AITileState();
}

class _AITileState extends State<_AITile> {
  RecurringIntervalPB? selectedInterval;

  final enableConfirmNotifier = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    final isCanceled = widget.subscriptionInfo?.addOnSubscription.status ==
        WorkspaceSubscriptionStatusPB.Canceled;

    final dateFormat = context.read<AppearanceSettingsCubit>().state.dateFormat;

    return Column(
      children: [
        SingleSettingAction(
          label: widget.label,
          description: widget.subscriptionInfo != null && isCanceled
              ? widget.canceledDescription.replaceAll(
                  '{}',
                  dateFormat.formatDate(
                    widget.subscriptionInfo!.addOnSubscription.endDate
                        .toDateTime(),
                    false,
                  ),
                )
              : widget.subscriptionInfo != null
                  ? widget.activeDescription.replaceAll(
                      '{}',
                      dateFormat.formatDate(
                        widget.subscriptionInfo!.addOnSubscription.endDate
                            .toDateTime(),
                        false,
                      ),
                    )
                  : widget.description,
          buttonLabel: widget.subscriptionInfo != null
              ? isCanceled
                  ? '续订'
                  : '移除'
              : '添加',
          fontWeight: FontWeight.w500,
          minWidth: _buttonsMinWidth,
          onPressed: () async {
            if (widget.subscriptionInfo != null) {
              await showConfirmDialog(
                context: context,
                style: ConfirmPopupStyle.cancelAndOk,
                title: '移除 ${widget.plan.label}',
                description: '您确定要移除 ${widget.plan.label} 吗？ 您将立即失去 ${widget.plan.label} 的功能和权益。',
                confirmLabel: '确认',
                onConfirm: (_) => context
                    .read<SettingsBillingBloc>()
                    .add(SettingsBillingEvent.cancelSubscription(widget.plan)),
              );
            } else {
              // Add the addon
              context
                  .read<SettingsBillingBloc>()
                  .add(SettingsBillingEvent.addSubscription(widget.plan));
            }
          },
        ),
        if (widget.subscriptionInfo != null) ...[
          const VSpace(10),
          SingleSettingAction(
            label:
                '${widget.subscriptionInfo!.addOnSubscription.subscriptionPlan.label} 周期',
            description:
                widget.subscriptionInfo!.addOnSubscription.interval.label,
            buttonLabel:
                '编辑期间',
            minWidth: _buttonsMinWidth,
            onPressed: () {
              enableConfirmNotifier.value = false;
              SettingsAlertDialog(
                title: '变更周期',
                enableConfirmNotifier: enableConfirmNotifier,
                children: [
                  ChangePeriod(
                    plan: widget
                        .subscriptionInfo!.addOnSubscription.subscriptionPlan,
                    selectedInterval:
                        widget.subscriptionInfo!.addOnSubscription.interval,
                    onSelected: (interval) {
                      enableConfirmNotifier.value = interval !=
                          widget.subscriptionInfo!.addOnSubscription.interval;
                      selectedInterval = interval;
                    },
                  ),
                ],
                confirm: () {
                  if (selectedInterval !=
                      widget.subscriptionInfo!.addOnSubscription.interval) {
                    context.read<SettingsBillingBloc>().add(
                          SettingsBillingEvent.updatePeriod(
                            plan: widget.subscriptionInfo!.addOnSubscription
                                .subscriptionPlan,
                            interval: selectedInterval!,
                          ),
                        );
                  }
                  Navigator.of(context).pop();
                },
              ).show(context);
            },
          ),
        ],
      ],
    );
  }
}

class ChangePeriod extends StatefulWidget {
  const ChangePeriod({
    super.key,
    required this.plan,
    required this.selectedInterval,
    required this.onSelected,
  });

  final SubscriptionPlanPB plan;
  final RecurringIntervalPB selectedInterval;
  final Function(RecurringIntervalPB interval) onSelected;

  @override
  State<ChangePeriod> createState() => _ChangePeriodState();
}

class _ChangePeriodState extends State<ChangePeriod> {
  RecurringIntervalPB? _selectedInterval;

  @override
  void initState() {
    super.initState();
    _selectedInterval = widget.selectedInterval;
  }

  @override
  void didChangeDependencies() {
    _selectedInterval = widget.selectedInterval;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PeriodSelector(
          price: widget.plan.priceMonthBilling,
          interval: RecurringIntervalPB.Month,
          isSelected: _selectedInterval == RecurringIntervalPB.Month,
          isCurrent: widget.selectedInterval == RecurringIntervalPB.Month,
          onSelected: () {
            widget.onSelected(RecurringIntervalPB.Month);
            setState(
              () => _selectedInterval = RecurringIntervalPB.Month,
            );
          },
        ),
        const VSpace(16),
        _PeriodSelector(
          price: widget.plan.priceAnnualBilling,
          interval: RecurringIntervalPB.Year,
          isSelected: _selectedInterval == RecurringIntervalPB.Year,
          isCurrent: widget.selectedInterval == RecurringIntervalPB.Year,
          onSelected: () {
            widget.onSelected(RecurringIntervalPB.Year);
            setState(
              () => _selectedInterval = RecurringIntervalPB.Year,
            );
          },
        ),
      ],
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({
    required this.price,
    required this.interval,
    required this.onSelected,
    required this.isSelected,
    required this.isCurrent,
  });

  final String price;
  final RecurringIntervalPB interval;
  final VoidCallback onSelected;
  final bool isSelected;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isCurrent && !isSelected ? 0.7 : 1,
      child: GestureDetector(
        onTap: isCurrent ? null : onSelected,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).dividerColor,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        FlowyText(
                          interval.label,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        if (isCurrent) ...[
                          const HSpace(8),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1,
                              ),
                              child: FlowyText(
                                '目前',
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const VSpace(8),
                    FlowyText(
                      price,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    const VSpace(4),
                    FlowyText(
                      interval.priceInfo,
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                    ),
                  ],
                ),
                const Spacer(),
                if (!isCurrent && !isSelected || isSelected) ...[
                  DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        width: 1.5,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).dividerColor,
                      ),
                    ),
                    child: SizedBox(
                      height: 22,
                      width: 22,
                      child: Center(
                        child: SizedBox(
                          width: 10,
                          height: 10,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.transparent,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
