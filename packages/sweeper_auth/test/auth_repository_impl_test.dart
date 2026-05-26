import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sweeper_auth/data/datasources/auth_remote_datasource.dart';
import 'package:sweeper_auth/data/repositories/auth_repository_impl.dart';
import 'package:sweeper_auth/domain/entities/auth_user.dart';
import 'package:sweeper_auth/domain/failures/auth_failure.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

void main() {
  late MockAuthRemoteDataSource remote;
  late AuthRepositoryImpl repository;

  setUp(() {
    remote = MockAuthRemoteDataSource();
    repository = AuthRepositoryImpl(remote);
  });

  test('signInWithGoogle maps cancelled sign-in to AuthFailure', () async {
    when(remote.signInWithGoogle).thenThrow(StateError('Sign in cancelled'));

    expect(
      () => repository.signInWithGoogle(),
      throwsA(isA<AuthFailure>()),
    );
  });

  test('signInWithGoogle returns user from remote', () async {
    const user = AuthUser(id: '1', email: 'a@b.com');
    when(remote.signInWithGoogle).thenAnswer((_) async => user);

    final result = await repository.signInWithGoogle();

    expect(result, user);
  });

  test('signInWithGoogle maps unexpected errors to AuthFailure', () async {
    when(remote.signInWithGoogle).thenThrow(Exception('network'));

    expect(
      () => repository.signInWithGoogle(),
      throwsA(
        isA<AuthFailure>().having(
          (e) => e.message,
          'message',
          contains('network'),
        ),
      ),
    );
  });

  test('signOut delegates to remote', () async {
    when(remote.signOut).thenAnswer((_) async {});

    await repository.signOut();

    verify(remote.signOut).called(1);
  });

  test('waitForInitialAuthState delegates to remote', () async {
    when(remote.waitForInitialAuthState).thenAnswer((_) async {});

    await repository.waitForInitialAuthState();

    verify(remote.waitForInitialAuthState).called(1);
  });

  test('currentUser delegates to remote', () {
    const user = AuthUser(id: '1', email: 'a@b.com');
    when(() => remote.currentUser).thenReturn(user);

    expect(repository.currentUser, user);
    verify(() => remote.currentUser).called(1);
  });

  test('signInWithGoogle rethrows AuthFailure unchanged', () async {
    when(remote.signInWithGoogle).thenThrow(const AuthFailure('denied'));

    expect(
      () => repository.signInWithGoogle(),
      throwsA(isA<AuthFailure>().having((e) => e.message, 'message', 'denied')),
    );
  });

  test('authStateChanges delegates to remote', () {
    when(remote.watchAuthState).thenAnswer((_) => const Stream.empty());

    expect(repository.authStateChanges, isA<Stream<AuthUser?>>());
    verify(remote.watchAuthState).called(1);
  });
}
