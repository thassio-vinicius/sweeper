import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sweeper_auth/data/datasources/auth_remote_datasource.dart';
import 'package:sweeper_auth/domain/entities/auth_user.dart';

class FirebaseAuthDataSource implements AuthRemoteDataSource {
  FirebaseAuthDataSource({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    String? googleServerClientId,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ??
            GoogleSignIn(
              serverClientId: googleServerClientId,
            );

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  @override
  Stream<AuthUser?> watchAuthState() =>
      _firebaseAuth.authStateChanges().map(_mapUser);

  @override
  AuthUser? get currentUser => _mapUser(_firebaseAuth.currentUser);

  @override
  Future<void> waitForInitialAuthState() async {
    await watchAuthState().first;
  }

  @override
  Future<AuthUser> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw StateError('Sign in cancelled');
    }

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    final user = _mapUser(userCredential.user);
    if (user == null) {
      throw StateError('Failed to sign in');
    }
    return user;
  }

  @override
  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  AuthUser? _mapUser(User? user) {
    if (user == null) return null;
    return AuthUser(
      id: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }
}
