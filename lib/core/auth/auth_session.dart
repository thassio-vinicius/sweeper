import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sweeper/core/config/app_access_config.dart';
import 'package:sweeper/features/auth/domain/repositories/auth_repository.dart';

/// How outbound HTTP requests should be authenticated.
enum HttpCredentialMode {
  /// Attach a Firebase bearer token (required).
  bearer,

  /// Send without credentials (guest / unauthenticated gameplay).
  anonymous,
}

/// Single source of truth for gameplay and HTTP access state.
class AuthSession extends ChangeNotifier {
  AuthSession({
    required AuthRepository authRepository,
    required AppAccessConfig accessConfig,
  })  : _authRepository = authRepository,
        _accessConfig = accessConfig {
    if (_authRepository.isAvailable) {
      _subscription = _authRepository.authStateChanges.listen(_onAuthChanged);
    }
  }

  final AuthRepository _authRepository;
  final AppAccessConfig _accessConfig;
  StreamSubscription<AuthUser?>? _subscription;

  bool _guestActive = false;

  bool get isAvailable => _authRepository.isAvailable;
  bool get guestModeAvailable =>
      _accessConfig.androidGuestModeEnabled && _authRepository.isAvailable;
  bool get isGuest => _guestActive;
  bool get isAuthenticated => _authRepository.currentUser != null;
  AuthUser? get user => _authRepository.currentUser;

  bool get canPlayGame =>
      isAuthenticated || isGuest || !_authRepository.isAvailable;

  HttpCredentialMode get httpCredentialMode {
    if (isAuthenticated) return HttpCredentialMode.bearer;
    if (isGuest || !_authRepository.isAvailable) {
      return HttpCredentialMode.anonymous;
    }
    return HttpCredentialMode.bearer;
  }

  void enterGuestMode() {
    if (!guestModeAvailable || isAuthenticated) return;
    _guestActive = true;
    notifyListeners();
  }

  void clearGuestMode() {
    if (!_guestActive) return;
    _guestActive = false;
    notifyListeners();
  }

  void _onAuthChanged(AuthUser? user) {
    if (user != null) {
      _guestActive = false;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
