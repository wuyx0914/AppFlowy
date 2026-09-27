use std::convert::TryInto;

use crate::entities::parser::*;
use crate::entities::AuthTypePB;
use crate::errors::ErrorCode;
use flowy_server_pub::user_dto::GotrueTokenResponse;
use flowy_derive::{ProtoBuf, ProtoBuf_Enum};
use flowy_user_pub::entities::*;

#[derive(ProtoBuf, Default)]
pub struct SignInPayloadPB {
  #[pb(index = 1)]
  pub email: String,

  #[pb(index = 2)]
  pub password: String,

  #[pb(index = 3)]
  pub name: String,

  #[pb(index = 4)]
  pub auth_type: AuthTypePB,

  #[pb(index = 5)]
  pub device_id: String,
}

impl TryInto<SignInParams> for SignInPayloadPB {
  type Error = ErrorCode;

  fn try_into(self) -> Result<SignInParams, Self::Error> {
    let email = UserEmail::parse(self.email)?;

    Ok(SignInParams {
      email: email.0,
      password: self.password,
      name: self.name,
      auth_type: self.auth_type.into(),
    })
  }
}

#[derive(ProtoBuf, Default)]
pub struct SignUpPayloadPB {
  #[pb(index = 1)]
  pub email: String,

  #[pb(index = 2)]
  pub name: String,

  #[pb(index = 3)]
  pub password: String,

  #[pb(index = 4)]
  pub auth_type: AuthTypePB,

  #[pb(index = 5)]
  pub device_id: String,
}

impl TryInto<SignUpParams> for SignUpPayloadPB {
  type Error = ErrorCode;

  fn try_into(self) -> Result<SignUpParams, Self::Error> {
    let email = UserEmail::parse(self.email)?;
    let password = self.password;
    let name = UserName::parse(self.name)?;

    Ok(SignUpParams {
      email: email.0,
      name: name.0,
      password,
      auth_type: self.auth_type.into(),
      device_id: self.device_id,
    })
  }
}



#[derive(ProtoBuf, Default, Debug, Clone)]
pub struct GotrueTokenResponsePB {
  #[pb(index = 1)]
  pub access_token: String,

  #[pb(index = 2)]
  pub token_type: String,

  #[pb(index = 3)]
  pub expires_in: i64,

  #[pb(index = 4)]
  pub expires_at: i64,

  #[pb(index = 5)]
  pub refresh_token: String,

  #[pb(index = 6, one_of)]
  pub provider_access_token: Option<String>,

  #[pb(index = 7, one_of)]
  pub provider_refresh_token: Option<String>,
}

impl From<GotrueTokenResponse> for GotrueTokenResponsePB {
  fn from(response: GotrueTokenResponse) -> Self {
    Self {
      access_token: response.access_token,
      token_type: response.token_type,
      expires_in: response.expires_in,
      expires_at: response.expires_at,
      refresh_token: response.refresh_token,
      provider_access_token: response.provider_access_token,
      provider_refresh_token: response.provider_refresh_token,
    }
  }
}








#[derive(Default, ProtoBuf)]
pub struct UserStatePB {
  #[pb(index = 1)]
  pub auth_type: AuthTypePB,
}

#[derive(ProtoBuf, Debug, Default, Clone)]
pub struct AuthStateChangedPB {
  #[pb(index = 1)]
  pub state: AuthStatePB,

  #[pb(index = 2)]
  pub message: String,
}

#[derive(ProtoBuf_Enum, Debug, Clone)]
pub enum AuthStatePB {
  // adding AuthState prefix to avoid conflict with other enums
  AuthStateUnknown = 0,
  AuthStateSignIn = 1,
  AuthStateSignOut = 2,
  InvalidAuth = 3,
}

impl Default for AuthStatePB {
  fn default() -> Self {
    Self::AuthStateUnknown
  }
}
