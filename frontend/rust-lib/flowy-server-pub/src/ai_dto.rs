//! Minimal local replacements for the AI DTO types that used to be
//! re-exported from the AppFlowy Cloud `client-api` crate.
//! Field layouts mirror the upstream `client-api-entity` definitions so the
//! local chat implementation and the sqlite persistence layer keep compiling.

use serde::{Deserialize, Serialize};
use serde_json::Value;
use std::collections::HashMap;
use chrono::Utc;
use uuid::Uuid;

// ---------------------------------------------------------------------------
// Errors
// ---------------------------------------------------------------------------

#[derive(Debug, Clone, Default, thiserror::Error, Serialize, Deserialize)]
#[error("{code}: {message}")]
pub struct AppResponseError {
  pub code: ErrorCode,
  pub message: String,
}

impl AppResponseError {
  pub fn is_record_not_found(&self) -> bool {
    self.code == ErrorCode::RecordNotFound
  }
}

#[derive(Debug, Clone, Copy, Default, PartialEq, Eq, Serialize, Deserialize)]
pub enum ErrorCode {
  #[default]
  Ok,
  Unhandled,
  RecordNotFound,
  InvalidRequest,
  InvalidPassword,
  InternalError,
}

// ---------------------------------------------------------------------------
// Streaming values
// ---------------------------------------------------------------------------

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum QuestionStreamValue {
  Answer {
    value: String,
  },
  AnswerStreamDone {
    #[serde(default)]
    value: Option<String>,
  },
  SuggestedQuestion {
    context_suggested_questions: Vec<ContextSuggestedQuestion>,
  },
  FollowUp {
    should_generate_related_question: bool,
  },
  Metadata {
    value: Value,
  },
  RateLimit {
    metadata: Value,
  },
}

impl Default for QuestionStreamValue {
  fn default() -> Self {
    QuestionStreamValue::Answer {
      value: String::new(),
    }
  }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum CompletionStreamValue {
  Answer {
    value: String,
  },
  Comment {
    value: String,
  },
  Complete {
    text: String,
  },
  Metadata {
    metadata: Value,
  },
}

// ---------------------------------------------------------------------------
// Chat DTOs
// ---------------------------------------------------------------------------

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct ChatAuthor {
  pub author_id: i64,
  #[serde(default)]
  pub author_type: ChatAuthorType,
  #[serde(default, skip_serializing_if = "Option::is_none")]
  pub meta: Option<serde_json::Value>,
}

impl ChatAuthor {
  pub fn new(author_id: i64, author_type: ChatAuthorType) -> Self {
    Self {
      author_id,
      author_type,
      meta: None,
    }
  }

  pub fn ai() -> Self {
    Self {
      author_id: 0,
      author_type: ChatAuthorType::AI,
      meta: None,
    }
  }
}

#[derive(Debug, Clone, Copy, Default, PartialEq, Eq, Serialize, Deserialize)]
#[repr(u8)]
pub enum ChatAuthorType {
  Unknown = 0,
  Human = 1,
  #[default]
  System = 2,
  AI = 3,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ChatMessage {
  pub author: ChatAuthor,
  pub message_id: i64,
  pub content: String,
  pub created_at: chrono::DateTime<chrono::Utc>,
  #[serde(rename = "meta_data")]
  pub metadata: serde_json::Value,
  pub reply_message_id: Option<i64>,
}

impl ChatMessage {
  pub fn new_human(message_id: i64, content: String, reply_message_id: Option<i64>) -> Self {
    Self {
      author: ChatAuthor::new(message_id, ChatAuthorType::Human),
      message_id,
      content,
      created_at: chrono::Utc::now(),
      metadata: serde_json::json!({}),
      reply_message_id,
    }
  }

  pub fn new_ai(message_id: i64, content: String, reply_message_id: Option<i64>) -> Self {
    Self {
      author: ChatAuthor::ai(),
      message_id,
      content,
      created_at: chrono::Utc::now(),
      metadata: serde_json::json!({}),
      reply_message_id,
    }
  }

  pub fn new_system(message_id: i64, content: String) -> Self {
    Self {
      author: ChatAuthor::new(message_id, ChatAuthorType::System),
      message_id,
      content,
      created_at: chrono::Utc::now(),
      metadata: serde_json::json!({}),
      reply_message_id: None,
    }
  }
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct RepeatedChatMessage {
  pub messages: Vec<ChatMessage>,
  pub total: i64,
  pub has_more: bool,
}

#[derive(Debug, Clone, Copy, Default, PartialEq, Eq, Serialize, Deserialize)]
pub enum ChatMessageType {
  #[default]
  User = 0,
  System = 1,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum MessageCursor {
  Offset(u64),
  NextBack,
  AfterMessageId(i64),
  BeforeMessageId(i64),
  NextMessage,
}

impl Default for MessageCursor {
  fn default() -> Self {
    MessageCursor::Offset(0)
  }
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct UpdateChatParams {
  pub name: Option<String>,
  pub rag_ids: Option<Vec<String>>,
  pub metadata: Option<serde_json::Value>,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct ChatRAGData {
  pub chat_id: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ChatSettings {
  pub name: String,
  #[serde(default)]
  pub rag_ids: Vec<String>,
  pub metadata: serde_json::Value,
}

impl Default for ChatSettings {
  fn default() -> Self {
    Self {
      name: String::new(),
      rag_ids: vec![],
      metadata: serde_json::json!({}),
    }
  }
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub enum ContextLoader {
  #[default]
  Unknown,
  OpenAI,
  DeepSeek,
}

// ---------------------------------------------------------------------------
// Completion / model DTOs
// ---------------------------------------------------------------------------

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct CompleteTextParams {
  pub text: String,
  pub completion_type: Option<CompletionType>,
  pub metadata: Option<CompletionMetadata>,
  #[serde(default)]
  pub format: ResponseFormat,
}

#[derive(Debug, Clone, Copy, Default, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub enum CompletionType {
  #[default]
  ImproveWriting,
  SpellingAndGrammar,
  MakeShorter,
  MakeLonger,
  Shorter,
  Longer,
  ContinueWriting,
  Explain,
  AskAI,
  CustomPrompt,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CustomPrompt {
  pub system: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LLMModel {
  pub llm_id: i64,
  pub provider: String,
  pub embedding_model: ModelInfo,
  pub chat_model: ModelInfo,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ModelInfo {
  pub name: String,
  pub file_name: String,
  pub file_size: i64,
  pub requirements: String,
  pub download_url: String,
  pub desc: String,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct ModelList {
  pub models: Vec<AvailableModel>,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct AvailableModel {
  pub model_provider: String,
  pub name: String,
  pub metadata: Option<serde_json::Value>,
  #[serde(default)]
  pub description: Option<String>,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct LocalAIConfig {
  pub chat_model: Option<String>,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct AppFlowyOfflineAI {
  pub enabled: bool,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct CompletionMessage {
  pub role: MessageRole,
  pub content: String,
}

#[derive(Debug, Clone, Copy, Default, PartialEq, Eq, Serialize, Deserialize)]
pub enum MessageRole {
  #[default]
  System,
  User,
  Assistant,
  Tool,
}

impl std::fmt::Display for MessageRole {
  fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
    match self {
      MessageRole::System => write!(f, "system"),
      MessageRole::User => write!(f, "user"),
      MessageRole::Assistant => write!(f, "assistant"),
      MessageRole::Tool => write!(f, "tool"),
    }
  }
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct CompletionMetadata {
  pub object_id: Uuid,
  pub workspace_id: Option<Uuid>,
  #[serde(default)]
  pub rag_ids: Option<Vec<String>>,
  #[serde(default)]
  pub completion_history: Option<Vec<CompletionMessage>>,
  #[serde(default)]
  pub custom_prompt: Option<CustomPrompt>,
  #[serde(default)]
  pub prompt_id: Option<String>,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct StringOrMessage {
  pub content: String,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct ResponseFormat {
  pub output_layout: OutputLayout,
  pub output_content: OutputContent,
  pub output_content_metadata: Option<OutputContentMetadata>,
}

impl ResponseFormat {
  pub fn new() -> Self {
    Self::default()
  }
}

#[derive(Debug, Clone, Copy, Default, PartialEq, Eq, Serialize, Deserialize)]
#[repr(u8)]
pub enum OutputLayout {
  Paragraph = 0,
  BulletList = 1,
  NumberedList = 2,
  SimpleTable = 3,
  #[default]
  Flex = 4,
}

#[derive(Debug, Clone, Copy, Default, PartialEq, Eq, Serialize, Deserialize)]
#[repr(u8)]
pub enum OutputContent {
  #[default]
  TEXT = 0,
  IMAGE = 1,
  RichTextImage = 2,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct OutputContentMetadata {
  #[serde(default, skip_serializing_if = "Option::is_none")]
  pub custom_image_prompt: Option<String>,
  #[serde(default = "default_image_model")]
  pub image_model: String,
  #[serde(default = "default_image_size", skip_serializing_if = "Option::is_none")]
  pub image_size: Option<String>,
}

fn default_image_model() -> String {
  "dall-e-3".to_string()
}

fn default_image_size() -> Option<String> {
  Some("256x256".to_string())
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct RelatedQuestion {
  pub content: String,
  #[serde(skip_serializing_if = "Option::is_none")]
  pub metadata: Option<serde_json::Value>,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct RepeatedRelatedQuestion {
  pub message_id: i64,
  pub items: Vec<RelatedQuestion>,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct CreateChatContext {
  pub chat_id: Uuid,
  pub loader: ContextLoader,
  pub context_loader_url: Option<String>,
  pub max_token: Option<u32>,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct RepeatedChatMessagePage {
  pub messages: Vec<ChatMessage>,
  pub total: i64,
  pub has_more: bool,
}

// ---------------------------------------------------------------------------
// Translate DTOs (database AI)
// ---------------------------------------------------------------------------

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct TranslateItem {
  pub title: String,
  pub content: String,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct TranslateRowResponse {
  pub items: Vec<std::collections::HashMap<String, String>>,
}

// ---------------------------------------------------------------------------
// Search DTOs
// ---------------------------------------------------------------------------

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct SearchDocumentResponseItem {
  pub object_id: Uuid,
  pub workspace_id: Uuid,
  pub score: f64,
  pub content_type: Option<SearchContentType>,
  #[serde(default)]
  pub content: String,
  pub preview: Option<String>,
  pub created_by: String,
  pub created_at: chrono::DateTime<Utc>,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct SearchSummaryResult {
  #[serde(default)]
  pub summaries: Vec<Summary>,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct SearchResult {
  pub object_id: Uuid,
  pub content: String,
}

// ---------------------------------------------------------------------------
// User DTOs
// ---------------------------------------------------------------------------

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct GotrueTokenResponse {
  pub access_token: String,
  pub token_type: String,
  pub expires_in: i64,
  pub expires_at: i64,
  pub refresh_token: String,
  #[serde(default)]
  pub provider_access_token: Option<String>,
  #[serde(default)]
  pub provider_refresh_token: Option<String>,
}

impl Default for GotrueTokenResponse {
  fn default() -> Self {
    Self {
      access_token: String::new(),
      token_type: "Bearer".to_string(),
      expires_in: 0,
      expires_at: 0,
      refresh_token: String::new(),
      provider_access_token: None,
      provider_refresh_token: None,
    }
  }
}

impl std::fmt::Display for ErrorCode {
  fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
    write!(f, "{:?}", self)
  }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TranslateRowData {
  pub cells: Vec<TranslateItem>,
  pub language: String,
  pub include_header: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ContextSuggestedQuestion {
  pub content: String,
  #[serde(default)]
  pub object_id: String,
}

// ---------------------------------------------------------------------------
// Search DTOs (local search & summary)
// ---------------------------------------------------------------------------

#[derive(Debug, Clone, Copy, Default, PartialEq, Eq, Serialize, Deserialize)]
#[repr(i32)]
pub enum SearchContentType {
  #[default]
  PlainText = 0,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct Summary {
  pub content: String,
  #[serde(default)]
  pub highlights: String,
  pub sources: Vec<Uuid>,
}
