import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sweeper_settings/data/datasources/settings_local_datasource.dart';
import 'package:sweeper_settings/data/repositories/settings_repository_impl.dart';
import 'package:sweeper_settings/domain/entities/user_settings.dart';

class MockSettingsLocalDataSource extends Mock
    implements SettingsLocalDataSource {}

void registerFallbackValues() {
  registerFallbackValue(8);
}

void main() {
  late MockSettingsLocalDataSource local;
  late SettingsRepositoryImpl repository;

  setUpAll(registerFallbackValues);

  setUp(() {
    local = MockSettingsLocalDataSource();
    repository = SettingsRepositoryImpl(local);
  });

  test('load applies defaults for missing stored values', () async {
    when(local.readGridSize).thenAnswer((_) async => null);
    when(local.readLanguageCode).thenAnswer((_) async => null);

    final settings = await repository.load();

    expect(settings, const UserSettings());
  });

  test('load normalizes invalid stored values', () async {
    when(local.readGridSize).thenAnswer((_) async => 99);
    when(local.readLanguageCode).thenAnswer((_) async => 'fr');

    final settings = await repository.load();

    expect(
      settings,
      const UserSettings(
        gridSize: UserSettings.defaultGridSize,
        languageCode: UserSettings.defaultLanguageCode,
      ),
    );
  });

  test('saveGridSize ignores unsupported sizes', () async {
    await repository.saveGridSize(7);

    verifyNever(() => local.writeGridSize(any()));
  });

  test('saveGridSize persists supported sizes', () async {
    when(() => local.writeGridSize(12)).thenAnswer((_) async {});

    await repository.saveGridSize(12);

    verify(() => local.writeGridSize(12)).called(1);
  });

  test('saveLanguageCode normalizes before persisting', () async {
    when(() => local.writeLanguageCode('en')).thenAnswer((_) async {});

    await repository.saveLanguageCode('invalid');

    verify(() => local.writeLanguageCode('en')).called(1);
  });
}
