import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sweeper_auth/config/app_access_config.dart';
import 'package:sweeper_auth/domain/repositories/auth_repository.dart';

/// Single source of truth for gameplay access state.
class AuthSession extends ChangeNotifier {
  AuthSession({
    required AuthRepository authRepository,
    required AppAccessConfig accessConfig,
  })  : _authRepository = authRepository,
        _accessConfig = accessConfig {
    _subscription = _authRepository.authStateChanges.listen(_onAuthChanged);
  }

  final AuthRepository _authRepository;
  final AppAccessConfig _accessConfig;
  StreamSubscription<AuthUser?>? _subscription;

  bool _guestActive = false;

  bool get guestModeAvailable => _accessConfig.androidGuestModeEnabled;
  bool get isGuest => _guestActive;
  bool get isAuthenticated => _authRepository.currentUser != null;
  AuthUser? get user => _authRepository.currentUser;

  bool get canPlayGame => isAuthenticated || isGuest;

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
