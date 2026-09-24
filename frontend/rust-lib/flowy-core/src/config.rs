use std::fmt;
use std::path::{Path, PathBuf};

use base64::Engine;
use semver::Version;
use tracing::{error, info};
use url::Url;

use crate::log_filter::create_log_filter;
use lib_infra::util::OperatingSystem;

#[derive(Clone)]
pub struct AppFlowyCoreConfig {
  /// Different `AppFlowyCoreConfig` instance should have different name
  pub(crate) app_version: Version,
  pub name: String,
  pub(crate) device_id: String,
  pub platform: String,
  /// Used to store the user data
  pub storage_path: String,
  /// Origin application path is the path of the application binary. By default, the
  /// storage_path is the same as the origin_application_path. However, when the user
  /// choose a custom path for the user data, the storage_path will be different from
  /// the origin_application_path.
  pub application_path: String,
  pub(crate) log_filter: String,
}
impl AppFlowyCoreConfig {
  pub fn new(
    app_version: Version,
    custom_application_path: String,
    application_path: String,
    device_id: String,
    platform: String,
    name: String,
  ) -> Self {
    let log_crates = vec!["sync_trace_log".to_string()];
    let storage_path = custom_application_path;

    let log_filter = create_log_filter(
      "info".to_owned(),
      log_crates,
      OperatingSystem::from(&platform),
    );

    AppFlowyCoreConfig {
      app_version,
      name,
      storage_path,
      application_path,
      device_id,
      platform,
      log_filter,
    }
  }

  pub fn log_filter(mut self, level: &str, with_crates: Vec<String>) -> Self {
    self.log_filter = create_log_filter(
      level.to_owned(),
      with_crates,
      OperatingSystem::from(&self.platform),
    );
    self
  }
  pub fn ensure_path(&self) {
    let create_if_needed = |path_str: &str, label: &str| {
      let dir = std::path::Path::new(path_str);
      if !dir.exists() {
        match std::fs::create_dir_all(dir) {
          Ok(_) => info!("Created {} path: {}", label, path_str),
          Err(err) => error!(
            "Failed to create {} path: {}. Error: {}",
            label, path_str, err
          ),
        }
      }
    };

    create_if_needed(&self.storage_path, "storage");
    create_if_needed(&self.application_path, "application");
  }
}
impl fmt::Debug for AppFlowyCoreConfig {
  fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
    let mut debug = f.debug_struct("AppFlowy Configuration");
    debug.field("app_version", &self.app_version);
    debug.field("storage_path", &self.storage_path);
    debug.field("application_path", &self.application_path);
    debug.finish()
  }
}

