import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sweeper/core/router/app_paths.dart';
import 'package:sweeper/core/router/auth_redirect.dart';
import 'package:sweeper_auth/config/app_access_config.dart';
import 'package:sweeper_auth/domain/entities/auth_user.dart';
import 'package:sweeper_auth/domain/repositories/auth_repository.dart';
import 'package:sweeper_auth/session/auth_session.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository authRepository;

  setUp(() {
    authRepository = MockAuthRepository();
    when(() => authRepository.authStateChanges)
        .thenAnswer((_) => const Stream.empty());
    when(() => authRepository.currentUser).thenReturn(null);
  });

  AuthSession session({required bool guestEnabled}) {
    return AuthSession(
      authRepository: authRepository,
      accessConfig: AppAccessConfig(androidGuestModeEnabled: guestEnabled),
    );
  }

  test('redirects unauthenticated users to login', () {
    final redirect = AuthRedirect(session(guestEnabled: false));

    expect(redirect.resolve(AppPaths.home), AppPaths.login);
    expect(redirect.resolve(AppPaths.gameOver), AppPaths.login);
    expect(redirect.resolve(AppPaths.login), isNull);
  });

  test('allows guest users to reach home and leave login', () {
    final auth = session(guestEnabled: true);
    auth.enterGuestMode();
    final redirect = AuthRedirect(auth);

    expect(redirect.resolve(AppPaths.home), isNull);
    expect(redirect.resolve(AppPaths.login), AppPaths.home);
  });

  test('allows authenticated users to reach home', () {
    when(() => authRepository.currentUser).thenReturn(
      const AuthUser(id: '1', email: 'player@example.com'),
    );
    final redirect = AuthRedirect(session(guestEnabled: false));

    expect(redirect.resolve(AppPaths.home), isNull);
    expect(redirect.resolve(AppPaths.login), AppPaths.home);
  });
}
