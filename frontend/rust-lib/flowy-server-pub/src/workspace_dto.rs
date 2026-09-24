//! Minimal local replacements for the workspace DTO types that used to be
//! re-exported from the AppFlowy Cloud `client-api` crate.

/// Workspace type in the local-only build. Only local workspaces exist.
#[derive(Debug, Clone, Copy, Default, PartialEq, Eq)]
pub enum WorkspaceType {
  #[default]
  Local,
}

use serde::{Deserialize, Serialize};
use uuid::Uuid;

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq, Hash)]
pub enum IconType {
  Emoji,
  Url,
  Icon,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct ViewIcon {
  pub ty: IconType,
  pub value: String,
}

impl Default for IconType {
  fn default() -> Self {
    IconType::Emoji
  }
}

impl From<u8> for IconType {
  fn from(value: u8) -> Self {
    match value {
      1 => IconType::Url,
      2 => IconType::Icon,
      _ => IconType::Emoji,
    }
  }
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct PublishInfoMeta {
  pub namespace: Option<String>,
  pub publish_name: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PublishInfoView {
  pub view: FolderViewMinimal,
  pub info: PublishInfo,
}


#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AFWorkspaceSettings {
  #[serde(default)]
  pub disable_search_indexing: bool,
  #[serde(default)]
  pub ai_model: String,
}

impl Default for AFWorkspaceSettings {
  fn default() -> Self {
    Self {
      disable_search_indexing: false,
      ai_model: "Auto".to_string(),
    }
  }
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct AFWorkspaceSettingsChange {
  #[serde(skip_serializing_if = "Option::is_none")]
  pub disable_search_indexing: Option<bool>,
  #[serde(skip_serializing_if = "Option::is_none")]
  pub ai_model: Option<String>,
}

impl AFWorkspaceSettingsChange {
  pub fn new() -> Self {
    Self::default()
  }
  pub fn disable_search_indexing(mut self, disable_search_indexing: bool) -> Self {
    self.disable_search_indexing = Some(disable_search_indexing);
    self
  }
  pub fn ai_model(mut self, ai_model: String) -> Self {
    self.ai_model = Some(ai_model);
    self
  }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FolderViewMinimal {
  pub view_id: String,
  pub name: String,
  pub icon: Option<ViewIcon>,
  pub layout: ViewLayout,
}

#[derive(Eq, PartialEq, Debug, Hash, Clone, Serialize, Deserialize)]
#[repr(u8)]
pub enum ViewLayout {
  Document = 0,
  Grid = 1,
  Board = 2,
  Calendar = 3,
  Chat = 4,
}

impl Default for ViewLayout {
  fn default() -> Self {
    ViewLayout::Document
  }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PublishInfo {
  pub namespace: String,
  pub publish_name: String,
  pub view_id: Uuid,
  #[serde(default)]
  pub publisher_email: String,
  #[serde(default)]
  pub publish_timestamp: chrono::DateTime<chrono::Utc>,
  #[serde(default)]
  pub unpublished_timestamp: Option<chrono::DateTime<chrono::Utc>>,
  #[serde(default = "default_comments_enabled")]
  pub comments_enabled: bool,
  #[serde(default = "default_duplicate_enabled")]
  pub duplicate_enabled: bool,
}

fn default_comments_enabled() -> bool {
  true
}

fn default_duplicate_enabled() -> bool {
  true
}
