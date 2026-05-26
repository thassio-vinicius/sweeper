import 'package:sweeper_settings/domain/entities/user_settings.dart';

abstract class SettingsRepository {
  Future<UserSettings> load();

  Future<void> saveGridSize(int size);

  Future<void> saveLanguageCode(String languageCode);
}
