pub mod billing;
pub mod guest_dto;
pub mod storage_dto;
pub mod workspace_dto;
pub mod ai_dto;
pub mod user_dto {
  pub use crate::ai_dto::GotrueTokenResponse;
}
pub mod search_dto {
  pub use crate::ai_dto::{SearchContentType, SearchDocumentResponseItem, SearchResult, SearchSummaryResult, Summary};
}

/// The authenticator type of the current build.
/// The local-only build always uses [AuthenticatorType::Local].
#[derive(serde_repr::Deserialize_repr, serde_repr::Serialize_repr, Debug, Clone, Copy, PartialEq, Eq)]
#[repr(u8)]
pub enum AuthenticatorType {
  Local = 0,
}

/// Local stub for the removed cloud configuration. Kept only so the
/// dart-ffi configuration surface keeps compiling; never serialized with
/// real values in the local-only build.
pub mod af_cloud_config {
  use serde::{Deserialize, Serialize};

  #[derive(Debug, Clone, Default, Serialize, Deserialize)]
  pub struct AFCloudConfiguration {
    pub base_url: String,
    #[serde(alias = "ws_base_url", default)]
    pub ws_url: String,
    #[serde(default)]
    pub gotrue_url: String,
    #[serde(default)]
    pub enable_sync_trace: bool,
    #[serde(default)]
    pub base_web_domain: String,
  }

  impl AFCloudConfiguration {
    pub fn from_env() -> Option<Self> {
      None
    }

    pub fn write_env(&self) {
      // no-op in the local-only build
    }
  }
}

impl AuthenticatorType {
  pub fn write_env(&self) {
    let s = *self as u8;
    unsafe {
      std::env::set_var(CLOUT_TYPE_STR, s.to_string());
    }
  }

  #[allow(dead_code)]
  fn from_str(s: &str) -> Self {
    let _ = s;
    AuthenticatorType::Local
  }

  #[allow(dead_code)]
  pub fn from_env() -> Self {
    let cloud_type_str = std::env::var(CLOUT_TYPE_STR).unwrap_or_default();
    AuthenticatorType::from_str(&cloud_type_str)
  }
}

pub const CLOUT_TYPE_STR: &str = "APPFLOWY_CLOUD_ENV_CLOUD_TYPE";
