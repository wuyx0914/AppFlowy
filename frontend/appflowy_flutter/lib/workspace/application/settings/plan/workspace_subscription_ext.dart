import 'package:appflowy_backend/protobuf/flowy-user/protobuf.dart';
import 'package:appflowy_backend/protobuf/flowy-user/workspace.pb.dart';
import 'package:appflowy_backend/protobuf/flowy-user/workspace.pbserver.dart';

extension SubscriptionInfoHelpers on WorkspaceSubscriptionInfoPB {
  String get label => switch (plan) {
        WorkspacePlanPB.FreePlan =>
          '免费',
        WorkspacePlanPB.ProPlan =>
          '专业版',
        WorkspacePlanPB.TeamPlan =>
          '团队',
        _ => 'N/A',
      };

  String get info => switch (plan) {
        WorkspacePlanPB.FreePlan =>
          '非常适合最多 2 名个人使用，以整理所有内容',
        WorkspacePlanPB.ProPlan =>
          '非常适合小型和中型团队，最多 10 名成员。',
        WorkspacePlanPB.TeamPlan =>
          '非常适合所有高效且井然有序的团队。',
        _ => 'N/A',
      };

  bool get isBillingPortalEnabled {
    if (plan != WorkspacePlanPB.FreePlan || addOns.isNotEmpty) {
      return true;
    }

    return false;
  }
}

extension AllSubscriptionLabels on SubscriptionPlanPB {
  String get label => switch (this) {
        SubscriptionPlanPB.Free =>
          '免费',
        SubscriptionPlanPB.Pro =>
          '专业版',
        SubscriptionPlanPB.Team =>
          '团队',
        SubscriptionPlanPB.AiMax =>
          'AI Max',
        SubscriptionPlanPB.AiLocal =>
          'Mac 上的 AI 本机处理',
        _ => 'N/A',
      };
}

extension WorkspaceSubscriptionStatusExt on WorkspaceSubscriptionInfoPB {
  bool get isCanceled =>
      planSubscription.status == WorkspaceSubscriptionStatusPB.Canceled;
}

extension WorkspaceAddonsExt on WorkspaceSubscriptionInfoPB {
  bool get hasAIMax =>
      addOns.any((addon) => addon.type == WorkspaceAddOnPBType.AddOnAiMax);

  bool get hasAIOnDevice =>
      addOns.any((addon) => addon.type == WorkspaceAddOnPBType.AddOnAiLocal);
}

/// These have to match [SubscriptionSuccessListenable.subscribedPlan] labels
extension ToRecognizable on SubscriptionPlanPB {
  String? toRecognizable() => switch (this) {
        SubscriptionPlanPB.Free => 'free',
        SubscriptionPlanPB.Pro => 'pro',
        SubscriptionPlanPB.Team => 'team',
        SubscriptionPlanPB.AiMax => 'ai_max',
        SubscriptionPlanPB.AiLocal => 'ai_local',
        _ => null,
      };
}

extension PlanHelper on SubscriptionPlanPB {
  /// Returns true if the plan is an add-on and not
  /// a workspace plan.
  ///
  bool get isAddOn => switch (this) {
        SubscriptionPlanPB.AiMax => true,
        SubscriptionPlanPB.AiLocal => true,
        _ => false,
      };

  String get priceMonthBilling => switch (this) {
        SubscriptionPlanPB.Free => 'US\$0',
        SubscriptionPlanPB.Pro => 'US\$12.5',
        SubscriptionPlanPB.Team => 'US\$15',
        SubscriptionPlanPB.AiMax => 'US\$10',
        SubscriptionPlanPB.AiLocal => 'US\$10',
        _ => 'US\$0',
      };

  String get priceAnnualBilling => switch (this) {
        SubscriptionPlanPB.Free => 'US\$0',
        SubscriptionPlanPB.Pro => 'US\$10',
        SubscriptionPlanPB.Team => 'US\$12.5',
        SubscriptionPlanPB.AiMax => 'US\$8',
        SubscriptionPlanPB.AiLocal => 'US\$8',
        _ => 'US\$0',
      };
}

extension IntervalLabel on RecurringIntervalPB {
  String get label => switch (this) {
        RecurringIntervalPB.Month =>
          '每月',
        RecurringIntervalPB.Year =>
          '每年',
        _ => '每月',
      };

  String get priceInfo => switch (this) {
        RecurringIntervalPB.Month =>
          '每座位每月计费',
        RecurringIntervalPB.Year =>
          '每座位按年计费',
        _ => '每座位每月计费',
      };
}
