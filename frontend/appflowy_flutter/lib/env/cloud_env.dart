import 'package:appflowy/env/backend_env.dart';

/// Local-only build: the app is configured to always run without a cloud
/// server. This file keeps the minimal symbols still referenced by the app
/// (e.g. [AuthenticatorType], [isAuthEnabled], [AppFlowyCloudSharedEnv]) so
/// the rest of the code compiles, but every cloud path is inert.

/// The authenticator type of the current build.
enum AuthenticatorType {
  local;

  bool get isLocal => true;

  bool get isAppFlowyCloudEnabled => false;

  int get value => 0;

  static AuthenticatorType fromValue(int value) => AuthenticatorType.local;
}

/// Always `false` in the local-only build: there is no authentication.
bool get isAuthEnabled => false;

bool get isLocalAuthEnabled => true;

/// Always `false` in the local-only build: there is no AppFlowy Cloud.
bool get isAppFlowyCloudEnabled => false;

AuthenticatorType currentCloudType() => AuthenticatorType.local;

/// A stub of the shared environment: only used to report the authenticator
/// type and (unused) default cloud configuration.
class AppFlowyCloudSharedEnv {
  AppFlowyCloudSharedEnv({
    required AuthenticatorType authenticatorType,
    required this.appflowyCloudConfig,
  }) : _authenticatorType = authenticatorType;

  final AuthenticatorType _authenticatorType;
  final AppFlowyCloudConfiguration appflowyCloudConfig;

  AuthenticatorType get authenticatorType => _authenticatorType;

  static Future<AppFlowyCloudSharedEnv> fromEnv() async {
    return AppFlowyCloudSharedEnv(
      authenticatorType: AuthenticatorType.local,
      appflowyCloudConfig: AppFlowyCloudConfiguration.defaultConfig(),
    );
  }

  @override
  String toString() => 'authenticator: $_authenticatorType (local-only)\n';
}

/// Retained for compatibility; the returned URL is never used at runtime.
Future<String> getAppFlowyCloudUrl() async => '';

const String kAppflowyCloudUrl = '';
