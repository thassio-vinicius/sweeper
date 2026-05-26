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
}
