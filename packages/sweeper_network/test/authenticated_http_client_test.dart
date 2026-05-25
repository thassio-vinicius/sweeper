import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:sweeper_auth/session/auth_session.dart';
import 'package:sweeper_auth/config/app_access_config.dart';
import 'package:sweeper_network/authenticated_http_client.dart';
import 'package:sweeper_network/network_exceptions.dart';
import 'package:sweeper_auth/domain/repositories/auth_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockHttpClient extends Mock implements http.Client {}

AuthSession _guestSession(MockAuthRepository authRepository) {
  when(() => authRepository.isAvailable).thenReturn(true);
  when(() => authRepository.currentUser).thenReturn(null);
  when(() => authRepository.authStateChanges)
      .thenAnswer((_) => const Stream.empty());

  final session = AuthSession(
    authRepository: authRepository,
    accessConfig: const AppAccessConfig(androidGuestModeEnabled: true),
  );
  session.enterGuestMode();
  return session;
}

void main() {
  late MockAuthRepository authRepository;
  late MockHttpClient httpClient;
  late AuthenticatedHttpClient client;

  setUpAll(() {
    registerFallbackValue(Uri.parse('https://example.com'));
  });

  setUp(() {
    authRepository = MockAuthRepository();
    httpClient = MockHttpClient();
    when(() => authRepository.isAvailable).thenReturn(true);
    when(() => authRepository.currentUser).thenReturn(null);
    when(() => authRepository.authStateChanges)
        .thenAnswer((_) => const Stream.empty());
  });

  test('get attaches bearer token for authenticated session', () async {
    when(() => authRepository.currentUser).thenReturn(
      const AuthUser(id: '1', email: 'a@b.com'),
    );
    final session = AuthSession(
      authRepository: authRepository,
      accessConfig: const AppAccessConfig(androidGuestModeEnabled: false),
    );
    client = AuthenticatedHttpClient(authRepository, session, client: httpClient);

    when(() => authRepository.getIdToken(forceRefresh: false))
        .thenAnswer((_) async => 'token-123');
    when(() => httpClient.get(any(), headers: any(named: 'headers')))
        .thenAnswer((_) async => http.Response('ok', 200));

    final response = await client.get(Uri.parse('https://api.example.com/me'));

    expect(response.statusCode, 200);
    final captured = verify(
      () => httpClient.get(
        Uri.parse('https://api.example.com/me'),
        headers: captureAny(named: 'headers'),
      ),
    ).captured.single as Map<String, String>;
    expect(captured['Authorization'], 'Bearer token-123');
  });

  test('guest session sends anonymous headers without token', () async {
    final session = _guestSession(authRepository);
    client = AuthenticatedHttpClient(authRepository, session, client: httpClient);

    when(() => httpClient.get(any(), headers: any(named: 'headers')))
        .thenAnswer((_) async => http.Response('ok', 200));

    final response = await client.get(Uri.parse('https://api.example.com/public'));

    expect(response.statusCode, 200);
    final captured = verify(
      () => httpClient.get(
        Uri.parse('https://api.example.com/public'),
        headers: captureAny(named: 'headers'),
      ),
    ).captured.single as Map<String, String>;
    expect(captured.containsKey('Authorization'), isFalse);
    verifyNever(
      () => authRepository.getIdToken(forceRefresh: any(named: 'forceRefresh')),
    );
  });

  test('get refreshes token and retries on 401', () async {
    when(() => authRepository.currentUser).thenReturn(
      const AuthUser(id: '1', email: 'a@b.com'),
    );
    final session = AuthSession(
      authRepository: authRepository,
      accessConfig: const AppAccessConfig(androidGuestModeEnabled: false),
    );
    client = AuthenticatedHttpClient(authRepository, session, client: httpClient);

    when(() => authRepository.getIdToken(forceRefresh: false))
        .thenAnswer((_) async => 'expired-token');
    when(() => authRepository.getIdToken(forceRefresh: true))
        .thenAnswer((_) async => 'fresh-token');
    when(() => httpClient.get(any(), headers: any(named: 'headers')))
        .thenAnswer((invocation) async {
      final headers =
          invocation.namedArguments[#headers] as Map<String, String>?;
      if (headers?['Authorization'] == 'Bearer expired-token') {
        return http.Response('unauthorized', 401);
      }
      return http.Response('ok', 200);
    });

    final response = await client.get(Uri.parse('https://api.example.com/me'));

    expect(response.statusCode, 200);
    verify(() => authRepository.getIdToken(forceRefresh: true)).called(1);
  });

  test('throws when bearer session has no token', () async {
    final session = AuthSession(
      authRepository: authRepository,
      accessConfig: const AppAccessConfig(androidGuestModeEnabled: false),
    );
    client = AuthenticatedHttpClient(authRepository, session, client: httpClient);

    when(() => authRepository.getIdToken(forceRefresh: any(named: 'forceRefresh')))
        .thenAnswer((_) async => null);

    expect(
      () => client.get(Uri.parse('https://api.example.com/me')),
      throwsA(isA<UnauthenticatedFailure>()),
    );
  });
}
