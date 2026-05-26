import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sweeper_auth/session/auth_session.dart';
import 'package:sweeper_auth/config/app_access_config.dart';
import 'package:sweeper_auth/domain/entities/auth_user.dart';
import 'package:sweeper_auth/domain/repositories/auth_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository authRepository;
  late StreamController<AuthUser?> authController;

  setUp(() {
    authRepository = MockAuthRepository();
    authController = StreamController<AuthUser?>.broadcast();

    when(() => authRepository.currentUser).thenReturn(null);
    when(() => authRepository.authStateChanges)
        .thenAnswer((_) => authController.stream);
  });

  tearDown(() async {
    await authController.close();
  });

  test('guest mode available only when configured for Android', () {
    final session = AuthSession(
      authRepository: authRepository,
      accessConfig: const AppAccessConfig(androidGuestModeEnabled: true),
    );
    addTearDown(session.dispose);

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
    addTearDown(session.dispose);

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
    addTearDown(session.dispose);

    session.enterGuestMode();
    expect(session.isGuest, isFalse);
    expect(session.canPlayGame, isTrue);
  });

  test('clearGuestMode resets guest flag', () {
    final session = AuthSession(
      authRepository: authRepository,
      accessConfig: const AppAccessConfig(androidGuestModeEnabled: true),
    );
    addTearDown(session.dispose);

    session.enterGuestMode();
    session.clearGuestMode();

    expect(session.isGuest, isFalse);
    expect(session.canPlayGame, isFalse);
  });

  test('enterGuestMode ignored when already authenticated', () {
    when(() => authRepository.currentUser).thenReturn(
      const AuthUser(id: '1', email: 'a@b.com'),
    );

    final session = AuthSession(
      authRepository: authRepository,
      accessConfig: const AppAccessConfig(androidGuestModeEnabled: true),
    );
    addTearDown(session.dispose);

    session.enterGuestMode();
    expect(session.isGuest, isFalse);
  });

  test('auth stream clears guest mode and notifies listeners', () async {
    final session = AuthSession(
      authRepository: authRepository,
      accessConfig: const AppAccessConfig(androidGuestModeEnabled: true),
    );
    addTearDown(session.dispose);

    session.enterGuestMode();
    var notifications = 0;
    session.addListener(() => notifications++);

    authController.add(const AuthUser(id: '1', email: 'a@b.com'));
    await Future<void>.delayed(Duration.zero);

    expect(session.isGuest, isFalse);
    expect(notifications, greaterThan(0));
  });
}
