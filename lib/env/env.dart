import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env', requireEnvFile: false)
abstract class Env {
  @EnviedField(varName: 'API_KEY', obfuscate: true, defaultValue: '')
  static final String apiKey = _Env.apiKey;
}
