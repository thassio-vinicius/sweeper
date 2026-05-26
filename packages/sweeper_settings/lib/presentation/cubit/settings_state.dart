import 'package:equatable/equatable.dart';

class SettingsState extends Equatable {
  const SettingsState({
    this.isLoaded = false,
    this.gridSize = 10,
    this.languageCode = 'en',
  });

  final bool isLoaded;
  final int gridSize;
  final String languageCode;

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
