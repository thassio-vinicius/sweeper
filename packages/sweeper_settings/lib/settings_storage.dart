abstract class SettingsStorage {
  Future<int?> readGridSize();

  Future<void> writeGridSize(int size);

  Future<String?> readLanguageCode();

  Future<void> writeLanguageCode(String languageCode);
}
