import 'package:flutter/foundation.dart';
import 'package:sweeper/core/auth/auth_session.dart';

/// Notifies [GoRouter] when auth or guest session state changes.
class AuthRefreshNotifier extends ChangeNotifier {
  AuthRefreshNotifier(AuthSession session) {
    _session = session;
    _session.addListener(notifyListeners);
  }

  late final AuthSession _session;

  @override
  void dispose() {
    _session.removeListener(notifyListeners);
    super.dispose();
  }
}
