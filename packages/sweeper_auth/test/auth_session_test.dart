import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sweeper_auth/session/auth_session.dart';
import 'package:sweeper_auth/config/app_access_config.dart';
import 'package:sweeper_auth/domain/entities/auth_user.dart';
import 'package:sweeper_auth/domain/repositories/auth_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository authRepository;

  setUp(() {
    authRepository = MockAuthRepository();
    when(() => authRepository.currentUser).thenReturn(null);
    when(() => authRepository.authStateChanges)
        .thenAnswer((_) => const Stream.empty());
  });

  test('guest mode available only when configured for Android', () {
    final session = AuthSession(
      authRepository: authRepository,
      accessConfig: const AppAccessConfig(androidGuestModeEnabled: true),
    );

    expect(session.guestModeAvailable, isTrue);

    session.enterGuestMode();
    expect(session.isGuest, isTrue);
    expect(session.canPlayGame, isTrue);
  });

  test('guest mode unavailable on non-Android config', () {
    final session = AuthSession(
      authRepository: authRepository,
      accessConfig: const AppAccessConfig(androidGuestModeEnabled: false),
    );

    session.enterGuestMode();
    expect(session.isGuest, isFalse);
    expect(session.canPlayGame, isFalse);
  });

  test('sign-in clears guest mode', () {
    when(() => authRepository.currentUser).thenReturn(
      const AuthUser(id: '1', email: 'a@b.com'),
    );

    final session = AuthSession(
      authRepository: authRepository,
      accessConfig: const AppAccessConfig(androidGuestModeEnabled: true),
    );

    session.enterGuestMode();
    expect(session.isGuest, isFalse);
    expect(session.canPlayGame, isTrue);
  });
}
