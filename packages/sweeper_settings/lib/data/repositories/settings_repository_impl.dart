import 'package:sweeper_settings/data/datasources/settings_local_datasource.dart';
import 'package:sweeper_settings/domain/entities/user_settings.dart';
import 'package:sweeper_settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._local);

  final SettingsLocalDataSource _local;

  @override
  Future<UserSettings> load() async {
    final gridSize = await _local.readGridSize();
    final languageCode = await _local.readLanguageCode();
    return UserSettings.fromStored(
      gridSize: gridSize,
      languageCode: languageCode,
    );
  }

  @override
  Future<void> saveGridSize(int size) async {
    if (!UserSettings.isValidGridSize(size)) return;
    await _local.writeGridSize(size);
  }

  @override
  Future<void> saveLanguageCode(String languageCode) async {
    final normalized = UserSettings.normalizeLanguageCode(languageCode);
    await _local.writeLanguageCode(normalized);
  }
}
