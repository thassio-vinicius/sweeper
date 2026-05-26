/// Low-level persistence for raw settings values.
abstract class SettingsLocalDataSource {
  Future<int?> readGridSize();

  Future<void> writeGridSize(int size);

  Future<String?> readLanguageCode();

  Future<void> writeLanguageCode(String languageCode);
}
