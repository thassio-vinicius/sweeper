import 'package:sweeper_auth/domain/entities/auth_user.dart';

/// Remote auth I/O — Firebase Auth and Google Sign-In.
abstract class AuthRemoteDataSource {
  Stream<AuthUser?> watchAuthState();

  AuthUser? get currentUser;

  Future<void> waitForInitialAuthState();

  Future<AuthUser> signInWithGoogle();

  Future<void> signOut();
}
