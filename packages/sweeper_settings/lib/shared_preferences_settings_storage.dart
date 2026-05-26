import 'package:shared_preferences/shared_preferences.dart';
import 'package:sweeper_settings/settings_storage.dart';

class SharedPreferencesSettingsStorage implements SettingsStorage {
  static const _gridSizeKey = 'settings.grid_size';
  static const _languageCodeKey = 'settings.language_code';

  @override
  Future<int?> readGridSize() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_gridSizeKey);
  }

  @override
  Future<void> writeGridSize(int size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_gridSizeKey, size);
  }

  @override
  Future<String?> readLanguageCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageCodeKey);
  }

  @override
  Future<void> writeLanguageCode(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageCodeKey, languageCode);
  }
}
