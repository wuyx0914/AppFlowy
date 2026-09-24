// lib/env/env.dart
import 'package:appflowy/env/cloud_env.dart';
import 'package:appflowy/plugins/shared/share/constants.dart';
import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  // Local-only build: users can never dynamically configure cloud settings.
  static bool get enableCustomCloud => false;

  @EnviedField(
    obfuscate: false,
    varName: 'AUTHENTICATOR_TYPE',
    defaultValue: 0,
  )
  static const int authenticatorType = _Env.authenticatorType;

  /// AppFlowy Cloud Configuration
  @EnviedField(
    obfuscate: false,
    varName: 'APPFLOWY_CLOUD_URL',
    defaultValue: '',
  )
  static const String afCloudUrl = _Env.afCloudUrl;

  @EnviedField(
    obfuscate: false,
    varName: 'INTERNAL_BUILD',
    defaultValue: '',
  )
  static const String internalBuild = _Env.internalBuild;

  @EnviedField(
    obfuscate: false,
    varName: 'SENTRY_DSN',
    defaultValue: '',
  )
  static const String sentryDsn = _Env.sentryDsn;

  @EnviedField(
    obfuscate: false,
    varName: 'BASE_WEB_DOMAIN',
    defaultValue: ShareConstants.defaultBaseWebDomain,
  )
  static const String baseWebDomain = _Env.baseWebDomain;
}
