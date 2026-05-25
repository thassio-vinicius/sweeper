import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sweeper_auth/session/auth_session.dart';
import 'package:sweeper_network/network_exceptions.dart';
import 'package:sweeper_auth/domain/repositories/auth_repository.dart';

/// HTTP client that resolves credentials from [AuthSession] in one place.
class AuthenticatedHttpClient {
  AuthenticatedHttpClient(
    this._authRepository,
    this._authSession, {
    http.Client? client,
  }) : _client = client ?? http.Client();

  final AuthRepository _authRepository;
  final AuthSession _authSession;
  final http.Client _client;

  Future<http.Response> get(
    Uri url, {
    Map<String, String>? headers,
  }) {
    return _send((authHeaders) => _client.get(url, headers: authHeaders));
  }

  Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) {
    return _send(
      (authHeaders) => _client.post(
        url,
        headers: authHeaders,
        body: body,
        encoding: encoding,
      ),
    );
  }

  Future<http.Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) {
    return _send(
      (authHeaders) => _client.put(
        url,
        headers: authHeaders,
        body: body,
        encoding: encoding,
      ),
    );
  }

  Future<http.Response> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) {
    return _send(
      (authHeaders) => _client.delete(
        url,
        headers: authHeaders,
        body: body,
        encoding: encoding,
      ),
    );
  }

  Future<http.Response> _send(
    Future<http.Response> Function(Map<String, String> headers) request,
  ) async {
    final response = await _authorizedRequest(request, forceRefresh: false);
    if (response.statusCode != 401 ||
        _authSession.httpCredentialMode != HttpCredentialMode.bearer) {
      return response;
    }

    return _authorizedRequest(request, forceRefresh: true);
  }

  Future<http.Response> _authorizedRequest(
    Future<http.Response> Function(Map<String, String> headers) request, {
    required bool forceRefresh,
  }) async {
    final headers = await _buildHeaders(forceRefresh: forceRefresh);
    final response = await request(headers);

    if (response.statusCode == 401 &&
        _authSession.httpCredentialMode == HttpCredentialMode.bearer &&
        forceRefresh) {
      throw const UnauthenticatedFailure(
        'Session expired. Please sign in again.',
      );
    }

    return response;
  }

  Future<Map<String, String>> _buildHeaders({
    required bool forceRefresh,
  }) async {
    switch (_authSession.httpCredentialMode) {
      case HttpCredentialMode.anonymous:
        return const {'Content-Type': 'application/json'};
      case HttpCredentialMode.bearer:
        final token =
            await _authRepository.getIdToken(forceRefresh: forceRefresh);
        if (token == null) {
          throw const UnauthenticatedFailure();
        }
        return {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        };
    }
  }

  void close() => _client.close();
}
