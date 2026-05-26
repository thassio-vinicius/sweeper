import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sweeper_settings/settings_storage.dart';

class SettingsState extends Equatable {
  const SettingsState({
    this.isLoaded = false,
    this.gridSize = 10,
    this.languageCode = 'en',
  });

  final bool isLoaded;
  final int gridSize;
  final String languageCode;

  static const availableSizes = [8, 10, 12];
  static const availableLanguageCodes = ['en', 'es', 'pt'];
  static const defaultLanguageCode = 'en';

  SettingsState copyWith({
    bool? isLoaded,
    int? gridSize,
    String? languageCode,
  }) {
    return SettingsState(
      isLoaded: isLoaded ?? this.isLoaded,
      gridSize: gridSize ?? this.gridSize,
      languageCode: languageCode ?? this.languageCode,
    );
  }

  @override
  List<Object?> get props => [isLoaded, gridSize, languageCode];
}

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._storage) : super(const SettingsState());

  final SettingsStorage _storage;

  Future<void> load() async {
    final storedGrid = await _storage.readGridSize();
    final gridSize =
        storedGrid != null && SettingsState.availableSizes.contains(storedGrid)
            ? storedGrid
            : 10;

    final storedLanguage = await _storage.readLanguageCode();
    final languageCode = _normalizeLanguageCode(storedLanguage);

    emit(
      SettingsState(
        isLoaded: true,
        gridSize: gridSize,
        languageCode: languageCode,
      ),
    );
  }

  Future<void> setGridSize(int size) async {
    if (!SettingsState.availableSizes.contains(size)) return;
    await _storage.writeGridSize(size);
    emit(state.copyWith(gridSize: size));
  }

  Future<void> setLanguageCode(String languageCode) async {
    final normalized = _normalizeLanguageCode(languageCode);
    if (normalized == state.languageCode) return;
    await _storage.writeLanguageCode(normalized);
    emit(state.copyWith(languageCode: normalized));
  }

  String _normalizeLanguageCode(String? code) {
    if (code == null || code.isEmpty) {
      return SettingsState.defaultLanguageCode;
    }
    return SettingsState.availableLanguageCodes.contains(code)
        ? code
        : SettingsState.defaultLanguageCode;
  }
}
