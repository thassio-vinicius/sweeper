import 'package:equatable/equatable.dart';

/// Persisted user preferences for board and locale.
class UserSettings extends Equatable {
  const UserSettings({
    this.gridSize = defaultGridSize,
    this.languageCode = defaultLanguageCode,
  });

  static const defaultGridSize = 10;
  static const defaultLanguageCode = 'en';
  static const availableGridSizes = [8, 10, 12];
  static const availableLanguageCodes = ['en', 'es', 'pt'];

  final int gridSize;
  final String languageCode;

  static bool isValidGridSize(int size) => availableGridSizes.contains(size);

  static bool isValidLanguageCode(String code) =>
      availableLanguageCodes.contains(code);

  static UserSettings fromStored({
    int? gridSize,
    String? languageCode,
  }) {
    return UserSettings(
      gridSize: gridSize != null && isValidGridSize(gridSize)
          ? gridSize
          : defaultGridSize,
      languageCode: normalizeLanguageCode(languageCode),
    );
  }

  static String normalizeLanguageCode(String? code) {
    if (code == null || code.isEmpty) return defaultLanguageCode;
    return isValidLanguageCode(code) ? code : defaultLanguageCode;
  }

  UserSettings copyWith({
    int? gridSize,
    String? languageCode,
  }) {
    return UserSettings(
      gridSize: gridSize ?? this.gridSize,
      languageCode: languageCode ?? this.languageCode,
    );
  }

  @override
  List<Object?> get props => [gridSize, languageCode];
}
