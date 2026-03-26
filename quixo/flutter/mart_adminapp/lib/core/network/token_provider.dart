
import 'shared_pref.dart';

abstract class TokenProvider {
  Future<String?> getToken();
  Future<void> setToken(String token);
  Future<void> clearToken();
}

class SharedPreferencesTokenProvider implements TokenProvider {
  static SharedPreferencesProvider s = SharedPreferencesProvider();

  @override
  Future<String?> getToken() async => s.getKey(prefs.token.name);
  

  @override
  Future<void> setToken(String token) async => s.setKey(prefs.token.name, token);

  @override
  Future<void> clearToken() async => s.clearkey(prefs.token.name);
}