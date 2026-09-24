//! Minimal local replacements for the file-storage DTO types that used to be
//! re-exported from the AppFlowy Cloud `client-api-entity` crate.

use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Debug, Clone, Default)]
pub struct CreateUploadResponse {
  pub file_id: String,
  pub upload_id: String,
}

#[derive(Serialize, Deserialize, Debug, Clone, Default)]
pub struct UploadPartResponse {
  pub e_tag: String,
  pub part_num: i32,
}

#[derive(Serialize, Deserialize, Debug, Clone, Default)]
pub struct CompletedPartRequest {
  pub e_tag: String,
  pub part_number: i32,
}
