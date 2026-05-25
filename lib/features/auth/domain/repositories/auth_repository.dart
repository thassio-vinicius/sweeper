import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  const AuthUser({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
  });

  final String id;
  final String? email;
  final String? displayName;
  final String? photoUrl;

  @override
  List<Object?> get props => [id, email, displayName, photoUrl];
}

abstract class AuthRepository {
  /// Whether Google Sign-In is configured and usable.
  bool get isAvailable;

  Stream<AuthUser?> get authStateChanges;

  AuthUser? get currentUser;

  /// Waits until Firebase restores the persisted session on cold start.
  Future<void> waitForInitialAuthState();

  /// Returns a Firebase ID token for authenticated HTTP requests.
  Future<String?> getIdToken({bool forceRefresh = false});

  Future<AuthUser> signInWithGoogle();

  Future<void> signOut();
}
