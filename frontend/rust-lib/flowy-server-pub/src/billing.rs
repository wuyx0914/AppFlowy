//! Local replacements for the billing DTO types that used to be re-exported
//! from the AppFlowy Cloud `client-api` crate.
//! The local-only build has no billing; these types exist only so the
//! event/handler surface keeps compiling. Field layouts mirror upstream
//! `shared-entity/src/dto/billing_dto.rs`.

use serde::{Deserialize, Serialize};

use crate::workspace_dto::WorkspaceType;

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
#[repr(i16)]
pub enum SubscriptionPlan {
  Free = 0,
  Pro = 1,
  Team = 2,
  AiMax = 3,
  AiLocal = 4,
}

impl Default for SubscriptionPlan {
  fn default() -> Self {
    SubscriptionPlan::Free
  }
}

impl From<i32> for SubscriptionPlan {
  fn from(value: i32) -> Self {
    match value {
      1 => SubscriptionPlan::Pro,
      2 => SubscriptionPlan::Team,
      3 => SubscriptionPlan::AiMax,
      4 => SubscriptionPlan::AiLocal,
      _ => SubscriptionPlan::Free,
    }
  }
}

impl AsRef<str> for SubscriptionPlan {
  fn as_ref(&self) -> &str {
    match self {
      SubscriptionPlan::Free => "free",
      SubscriptionPlan::Pro => "pro",
      SubscriptionPlan::Team => "team",
      SubscriptionPlan::AiMax => "ai_max",
      SubscriptionPlan::AiLocal => "ai_local",
    }
  }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub enum RecurringInterval {
  #[default]
  None,
  Month,
  Year,
}

#[derive(Debug, Clone)]
pub struct SubscriptionPlanDetail {
  pub currency: Currency,
  pub price_cents: i64,
  pub country: String,
  pub recurring_interval: RecurringInterval,
  pub plan: SubscriptionPlan,
  pub price_name: String,
}

impl SubscriptionPlanDetail {
  pub fn price_per_year(&self) -> i64 {
    match self.recurring_interval {
      RecurringInterval::Month => self.price_cents * 12,
      _ => self.price_cents,
    }
  }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub enum SubscriptionStatus {
  #[default]
  Active,
  Canceled,
  Incomplete,
  IncompleteExpired,
  PastDue,
  Paused,
  Trialing,
  Unpaid,
}

#[derive(Debug, Clone, Default)]
pub struct WorkspaceSubscriptionStatus {
  pub workspace_id: String,
  pub workspace_plan: SubscriptionPlan,
  pub recurring_interval: RecurringInterval,
  pub subscription_status: SubscriptionStatus,
  pub subscription_quantity: u64,
  pub cancel_at: Option<i64>,
  pub current_period_end: i64,
}

#[derive(Debug, Clone, Default)]
pub struct WorkspaceUsageAndLimit {
  pub name: Option<String>,
  pub member_count: i64,
  pub member_count_limit: i64,
  pub storage_bytes: i64,
  pub storage_bytes_limit: i64,
  pub storage_bytes_unlimited: bool,
  pub single_upload_limit: i64,
  pub single_upload_unlimited: bool,
  pub storage_file_count: i64,
  pub storage_file_count_limit: i64,
  pub storage_per_file_limit: i64,
  pub ai_responses_count: i64,
  pub ai_responses_count_limit: i64,
  pub ai_image_responses_count: i64,
  pub ai_image_responses_count_limit: i64,
  pub ai_responses_unlimited: bool,
  pub local_ai: bool,
}

impl From<SubscriptionPlan> for WorkspaceType {
  fn from(_plan: SubscriptionPlan) -> Self {
    WorkspaceType::Local
  }
}

#[derive(Debug, Clone, Copy, Default, PartialEq, Eq, Serialize, Deserialize)]
pub enum Currency {
  #[default]
  USD,
}

#[derive(Debug, Clone, Default)]
pub struct SubscriptionCancelRequest {
  pub workspace_id: String,
  pub plan: SubscriptionPlan,
  pub sync: bool,
  pub reason: Option<String>,
}
