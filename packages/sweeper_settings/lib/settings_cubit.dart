import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsState extends Equatable {
  const SettingsState({this.gridSize = 10});

  final int gridSize;

  static const availableSizes = [8, 10, 12];

  SettingsState copyWith({int? gridSize}) {
    return SettingsState(gridSize: gridSize ?? this.gridSize);
  }

  @override
  List<Object?> get props => [gridSize];
}

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(const SettingsState());

  void setGridSize(int size) {
    if (SettingsState.availableSizes.contains(size)) {
      emit(state.copyWith(gridSize: size));
    }
  }
}
