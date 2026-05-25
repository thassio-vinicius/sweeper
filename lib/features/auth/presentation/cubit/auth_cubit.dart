import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sweeper/core/errors/failures.dart';
import 'package:sweeper/features/auth/domain/repositories/auth_repository.dart';

class AuthState extends Equatable {
  const AuthState({
    this.isAvailable = false,
    this.user,
    this.isLoading = false,
    this.error,
  });

  final bool isAvailable;
  final AuthUser? user;
  final bool isLoading;
  final String? error;

  AuthState copyWith({
    bool? isAvailable,
    AuthUser? user,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      isAvailable: isAvailable ?? this.isAvailable,
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [isAvailable, user, isLoading, error];
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository)
      : super(AuthState(isAvailable: _repository.isAvailable)) {
    if (_repository.isAvailable) {
      _subscription = _repository.authStateChanges.listen((user) {
        emit(state.copyWith(user: user, clearError: true));
      });
    }
  }

  final AuthRepository _repository;
  StreamSubscription<AuthUser?>? _subscription;

  Future<void> signInWithGoogle() async {
    if (!_repository.isAvailable) return;
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final user = await _repository.signInWithGoogle();
      emit(state.copyWith(user: user, isLoading: false));
    } on AuthFailure catch (e) {
      emit(state.copyWith(isLoading: false, error: e.message));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> signOut() async {
    await _repository.signOut();
    emit(state.copyWith(clearUser: true));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
