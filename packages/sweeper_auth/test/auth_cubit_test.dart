import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sweeper_auth/config/app_access_config.dart';
import 'package:sweeper_auth/domain/entities/auth_user.dart';
import 'package:sweeper_auth/domain/failures/auth_failure.dart';
import 'package:sweeper_auth/domain/repositories/auth_repository.dart';
import 'package:sweeper_auth/presentation/cubit/auth_cubit.dart';
import 'package:sweeper_auth/session/auth_session.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;
  late AuthSession session;
  late StreamController<AuthUser?> authController;

  setUp(() {
    repository = MockAuthRepository();
    authController = StreamController<AuthUser?>.broadcast();

    when(() => repository.authStateChanges).thenAnswer((_) => authController.stream);
    when(() => repository.currentUser).thenReturn(null);
    when(() => repository.signInWithGoogle()).thenAnswer(
      (_) async => const AuthUser(id: '1', email: 'player@example.com'),
    );
    when(repository.signOut).thenAnswer((_) async {});

    session = AuthSession(
      authRepository: repository,
      accessConfig: const AppAccessConfig(androidGuestModeEnabled: true),
    );
  });

  tearDown(() async {
    await authController.close();
    session.dispose();
  });

  AuthCubit buildCubit() => AuthCubit(repository, session);

  blocTest<AuthCubit, AuthState>(
    'enterGuestMode updates guest state',
    build: buildCubit,
    act: (cubit) => cubit.enterGuestMode(),
    verify: (cubit) {
      expect(cubit.state.isGuest, isTrue);
      expect(cubit.state.canPlayGame, isTrue);
    },
  );

  blocTest<AuthCubit, AuthState>(
    'signInWithGoogle clears guest and sets user',
    build: buildCubit,
    seed: () => const AuthState(isGuest: true, guestModeAvailable: true),
    act: (cubit) async {
      cubit.enterGuestMode();
      await cubit.signInWithGoogle();
    },
    verify: (cubit) {
      expect(cubit.state.isGuest, isFalse);
      expect(cubit.state.user?.email, 'player@example.com');
      expect(cubit.state.isLoading, isFalse);
    },
  );

  blocTest<AuthCubit, AuthState>(
    'signInWithGoogle surfaces AuthFailure',
    build: buildCubit,
    setUp: () {
      when(repository.signInWithGoogle).thenThrow(const AuthFailure('cancelled'));
    },
    act: (cubit) => cubit.signInWithGoogle(),
    verify: (cubit) {
      expect(cubit.state.error, 'cancelled');
      expect(cubit.state.isLoading, isFalse);
    },
  );

  blocTest<AuthCubit, AuthState>(
    'auth stream updates user from repository',
    build: buildCubit,
    act: (cubit) async {
      authController.add(const AuthUser(id: '2', email: 'stream@example.com'));
      await Future<void>.delayed(Duration.zero);
    },
    verify: (cubit) {
      expect(cubit.state.user?.email, 'stream@example.com');
      expect(cubit.state.error, isNull);
    },
  );

  blocTest<AuthCubit, AuthState>(
    'signInWithGoogle surfaces unexpected errors',
    build: buildCubit,
    setUp: () {
      when(repository.signInWithGoogle).thenThrow(Exception('offline'));
    },
    act: (cubit) => cubit.signInWithGoogle(),
    verify: (cubit) {
      expect(cubit.state.error, contains('offline'));
      expect(cubit.state.isLoading, isFalse);
    },
  );

  blocTest<AuthCubit, AuthState>(
    'signOut clears user',
    build: buildCubit,
    seed: () => const AuthState(
      user: AuthUser(id: '1', email: 'player@example.com'),
    ),
    setUp: () {
      when(() => repository.currentUser).thenReturn(
        const AuthUser(id: '1', email: 'player@example.com'),
      );
    },
    act: (cubit) => cubit.signOut(),
    verify: (cubit) {
      expect(cubit.state.user, isNull);
      expect(cubit.state.isSigningOut, isFalse);
      verify(repository.signOut).called(1);
    },
  );

  blocTest<AuthCubit, AuthState>(
    'signOut surfaces errors from repository',
    build: buildCubit,
    seed: () => const AuthState(
      user: AuthUser(id: '1', email: 'player@example.com'),
    ),
    setUp: () {
      when(() => repository.currentUser).thenReturn(
        const AuthUser(id: '1', email: 'player@example.com'),
      );
      when(repository.signOut).thenThrow(Exception('network'));
    },
    act: (cubit) => cubit.signOut(),
    verify: (cubit) {
      expect(cubit.state.error, contains('network'));
      expect(cubit.state.isSigningOut, isFalse);
    },
  );
}
