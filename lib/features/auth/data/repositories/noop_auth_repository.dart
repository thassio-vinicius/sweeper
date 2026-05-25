import 'package:sweeper/features/auth/domain/repositories/auth_repository.dart';

/// Used when Firebase is not configured — auth is unavailable but the app runs.
class NoOpAuthRepository implements AuthRepository {
  @override
  bool get isAvailable => false;

  @override
  Stream<AuthUser?> get authStateChanges => Stream.value(null);

  @override
  AuthUser? get currentUser => null;

  @override
  Future<AuthUser> signInWithGoogle() async {
    throw UnsupportedError('Firebase is not configured');
  }

  @override
  Future<void> signOut() async {}
}
