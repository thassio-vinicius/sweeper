import 'package:flutter/foundation.dart';
import 'package:sweeper_auth/session/auth_session.dart';

class AuthRefreshNotifier extends ChangeNotifier {
  AuthRefreshNotifier(this._authSession) {
    _authSession.addListener(notifyListeners);
  }

  final AuthSession _authSession;

  @override
  void dispose() {
    _authSession.removeListener(notifyListeners);
    super.dispose();
  }
}
