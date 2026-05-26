import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sweeper_auth/session/auth_session.dart';
import 'package:sweeper_auth/domain/failures/auth_failure.dart';
import 'package:sweeper_auth/domain/repositories/auth_repository.dart';

class AuthState extends Equatable {
  const AuthState({
    this.guestModeAvailable = false,
    this.user,
    this.isGuest = false,
    this.isLoading = false,
    this.isSigningOut = false,
    this.error,
  });

  final bool guestModeAvailable;
  final AuthUser? user;
  final bool isGuest;
  final bool isLoading;
  final bool isSigningOut;
  final String? error;

  bool get isAuthenticated => user != null;
  bool get canPlayGame => isAuthenticated || isGuest;

  AuthState copyWith({
    bool? guestModeAvailable,
    AuthUser? user,
    bool? isGuest,
    bool? isLoading,
    bool? isSigningOut,
    String? error,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      guestModeAvailable: guestModeAvailable ?? this.guestModeAvailable,
      user: clearUser ? null : (user ?? this.user),
      isGuest: isGuest ?? this.isGuest,
      isLoading: isLoading ?? this.isLoading,
      isSigningOut: isSigningOut ?? this.isSigningOut,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
        guestModeAvailable,
        user,
        isGuest,
        isLoading,
        isSigningOut,
        error,
      ];
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository, this._session)
      : super(
          AuthState(
            guestModeAvailable: _session.guestModeAvailable,
            user: _repository.currentUser,
            isGuest: _session.isGuest,
          ),
        ) {
    _sessionListener = () => emit(_mappedState());
    _session.addListener(_sessionListener);

    _subscription = _repository.authStateChanges.listen((user) {
      emit(
        state.copyWith(
          user: user,
          isGuest: _session.isGuest,
          isLoading: false,
          isSigningOut: false,
          clearError: true,
        ),
      );
    });
  }

  final AuthRepository _repository;
  final AuthSession _session;
  StreamSubscription<AuthUser?>? _subscription;
  late final VoidCallback _sessionListener;

  AuthState _mappedState() {
    return state.copyWith(
      guestModeAvailable: _session.guestModeAvailable,
      user: _session.user,
      isGuest: _session.isGuest,
    );
  }

  void enterGuestMode() {
    _session.enterGuestMode();
    emit(_mappedState());
  }

  Future<void> signInWithGoogle() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final user = await _repository.signInWithGoogle();
      _session.clearGuestMode();
      emit(state.copyWith(user: user, isGuest: false, isLoading: false));
    } on AuthFailure catch (e) {
      emit(state.copyWith(isLoading: false, error: e.message));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> signOut() async {
    emit(state.copyWith(isSigningOut: true, clearError: true));
    try {
      _session.clearGuestMode();
      if (_repository.currentUser != null) {
        await _repository.signOut();
      }
      emit(
        state.copyWith(
          clearUser: true,
          isGuest: false,
          isSigningOut: false,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isSigningOut: false, error: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _session.removeListener(_sessionListener);
    _subscription?.cancel();
    return super.close();
  }
}
