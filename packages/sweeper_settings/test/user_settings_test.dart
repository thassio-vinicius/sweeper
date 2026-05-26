import 'package:flutter_test/flutter_test.dart';
import 'package:sweeper_settings/domain/entities/user_settings.dart';

void main() {
  test('fromStored applies defaults for invalid values', () {
    expect(
      UserSettings.fromStored(gridSize: 99, languageCode: 'fr'),
      const UserSettings(),
    );
  });

  test('fromStored keeps valid stored values', () {
    expect(
      UserSettings.fromStored(gridSize: 12, languageCode: 'pt'),
      const UserSettings(gridSize: 12, languageCode: 'pt'),
    );
  });

  test('normalizeLanguageCode handles null and empty', () {
    expect(UserSettings.normalizeLanguageCode(null), 'en');
    expect(UserSettings.normalizeLanguageCode(''), 'en');
    expect(UserSettings.normalizeLanguageCode('es'), 'es');
    expect(UserSettings.normalizeLanguageCode('de'), 'en');
  });

  test('copyWith overrides fields', () {
    const original = UserSettings(gridSize: 8, languageCode: 'en');
    expect(
      original.copyWith(gridSize: 12, languageCode: 'pt'),
      const UserSettings(gridSize: 12, languageCode: 'pt'),
    );
    expect(original.copyWith(gridSize: 12), const UserSettings(gridSize: 12, languageCode: 'en'));
  });

  test('copyWith can override language only', () {
    const original = UserSettings(gridSize: 8, languageCode: 'en');
    expect(
      original.copyWith(languageCode: 'pt'),
      const UserSettings(gridSize: 8, languageCode: 'pt'),
    );
  });

  test('equality compares grid size and language', () {
    const a = UserSettings(gridSize: 10, languageCode: 'en');
    const b = UserSettings(gridSize: 10, languageCode: 'en');
    const c = UserSettings(gridSize: 8, languageCode: 'en');

    expect(a, b);
    expect(a, isNot(c));
  });

  test('validation helpers', () {
    expect(UserSettings.isValidGridSize(10), isTrue);
    expect(UserSettings.isValidGridSize(9), isFalse);
    expect(UserSettings.isValidLanguageCode('pt'), isTrue);
    expect(UserSettings.isValidLanguageCode('de'), isFalse);
  });
}
