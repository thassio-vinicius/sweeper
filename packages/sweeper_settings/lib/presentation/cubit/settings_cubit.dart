import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sweeper_settings/domain/entities/user_settings.dart';
import 'package:sweeper_settings/domain/repositories/settings_repository.dart';
import 'package:sweeper_settings/presentation/cubit/settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._repository) : super(const SettingsState());

  final SettingsRepository _repository;

  Future<void> load() async {
    final settings = await _repository.load();
    emit(
      SettingsState(
        isLoaded: true,
        gridSize: settings.gridSize,
        languageCode: settings.languageCode,
      ),
    );
  }

  Future<void> setGridSize(int size) async {
    if (!UserSettings.isValidGridSize(size)) return;
    await _repository.saveGridSize(size);
    emit(state.copyWith(gridSize: size));
  }

  Future<void> setLanguageCode(String languageCode) async {
    final normalized = UserSettings.normalizeLanguageCode(languageCode);
    if (normalized == state.languageCode) return;
    await _repository.saveLanguageCode(normalized);
    emit(state.copyWith(languageCode: normalized));
  }
}
