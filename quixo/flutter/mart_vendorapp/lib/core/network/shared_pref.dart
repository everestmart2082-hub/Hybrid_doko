
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesProvider {

  Future<String?> getKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> setKey(String key,String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, token);
  }

  Future<void> clearkey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}

enum prefs { token, theme, language, vendorId }