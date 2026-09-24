//! Minimal local replacements for the guest-sharing types that used to be
//! re-exported from the AppFlowy Cloud `client-api` crate.

use uuid::Uuid;

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum AFAccessLevel {
  ReadOnly,
  ReadAndComment,
  ReadAndWrite,
  FullAccess,
}

impl Default for AFAccessLevel {
  fn default() -> Self {
    AFAccessLevel::ReadOnly
  }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum AFRole {
  Owner,
  Member,
  Guest,
}

impl Default for AFRole {
  fn default() -> Self {
    AFRole::Guest
  }
}

impl From<i32> for AFRole {
  fn from(value: i32) -> Self {
    match value {
      0 => AFRole::Owner,
      1 => AFRole::Member,
      _ => AFRole::Guest,
    }
  }
}

#[derive(Debug, Clone)]
pub struct SharedUser {
  pub email: String,
  pub name: String,
  pub role: AFRole,
  pub access_level: AFAccessLevel,
  pub avatar_url: Option<String>,
}

#[derive(Debug, Clone, Default)]
pub struct SharedViewDetails {
  pub view_id: Uuid,
  pub shared_with: Vec<SharedUser>,
}

#[derive(Debug, Clone, Default)]
pub struct ShareViewWithGuestRequest {
  pub view_id: Uuid,
  pub emails: Vec<String>,
  pub access_level: AFAccessLevel,
}

#[derive(Debug, Clone, Default)]
pub struct RevokeSharedViewAccessRequest {
  pub emails: Vec<String>,
}

#[derive(Debug, Clone)]
pub struct SharedView {
  pub view_id: Uuid,
  pub access_level: AFAccessLevel,
}

#[derive(Debug, Clone, Default)]
pub struct ListSharedViewResponse {
  pub shared_views: Vec<SharedView>,
}
