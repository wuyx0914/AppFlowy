// lib/env/env.dart
// ignore_for_file: prefer_const_declarations

import 'package:envied/envied.dart';

part 'cloud_env_test.g.dart';

@Envied(path: '.env.cloud.test')
abstract class TestEnv {
  /// AppFlowy Cloud Configuration
  @EnviedField(
    obfuscate: false,
    varName: 'APPFLOWY_CLOUD_URL',
    defaultValue: 'http://localhost',
  )
  static final String afCloudUrl = _TestEnv.afCloudUrl;

  @EnviedField(
    obfuscate: false,
    varName: 'SUPABASE_URL',
    defaultValue: '',
  )
  static final String supabaseUrl = _TestEnv.supabaseUrl;
  @EnviedField(
    obfuscate: false,
    varName: 'SUPABASE_ANON_KEY',
    defaultValue: '',
  )
  static final String supabaseAnonKey = _TestEnv.supabaseAnonKey;
}
