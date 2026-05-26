import 'package:sweeper_auth/data/datasources/auth_remote_datasource.dart';
import 'package:sweeper_auth/domain/entities/auth_user.dart';
import 'package:sweeper_auth/domain/failures/auth_failure.dart';
import 'package:sweeper_auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote);

  final AuthRemoteDataSource _remote;

  @override
  Stream<AuthUser?> get authStateChanges => _remote.watchAuthState();

  @override
  AuthUser? get currentUser => _remote.currentUser;

  @override
  Future<void> waitForInitialAuthState() => _remote.waitForInitialAuthState();

  @override
  Future<AuthUser> signInWithGoogle() async {
    try {
      return await _remote.signInWithGoogle();
    } on AuthFailure {
      rethrow;
    } on StateError catch (e) {
      throw AuthFailure(e.message);
    } catch (e) {
      throw AuthFailure(e.toString());
    }
  }

  @override
  Future<void> signOut() => _remote.signOut();
}
