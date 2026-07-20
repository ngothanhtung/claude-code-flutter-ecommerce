import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode, this.code});

  final String message;
  final int? statusCode;
  final int? code;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient(this.preferences, {http.Client? httpClient, String? baseUrl})
    : _http = httpClient ?? http.Client(),
      baseUrl = baseUrl ?? _defaultBaseUrl;

  static const _accessTokenKey = 'api_access_token';
  static const _refreshTokenKey = 'api_refresh_token';
  static const _configuredBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String get _defaultBaseUrl {
    if (_configuredBaseUrl.isNotEmpty) return _configuredBaseUrl;
    return Platform.isAndroid
        ? 'http://10.0.2.2:8080'
        : 'http://localhost:8080';
  }

  final SharedPreferences preferences;
  final http.Client _http;
  final String baseUrl;

  String? get accessToken => preferences.getString(_accessTokenKey);
  String? get refreshToken => preferences.getString(_refreshTokenKey);
  bool get hasSession => refreshToken != null;

  Future<void> saveTokens(Map<String, dynamic> json) async {
    final access = json['access_token'];
    final refresh = json['refresh_token'];
    if (access is! String || refresh is! String) {
      throw const ApiException('The server returned an invalid token pair.');
    }
    await preferences.setString(_accessTokenKey, access);
    await preferences.setString(_refreshTokenKey, refresh);
  }

  Future<void> clearSession() async {
    await preferences.remove(_accessTokenKey);
    await preferences.remove(_refreshTokenKey);
  }

  Future<dynamic> get(String path, {bool authenticated = false}) =>
      request('GET', path, authenticated: authenticated);

  Future<dynamic> post(
    String path, {
    Object? body,
    bool authenticated = false,
  }) => request('POST', path, body: body, authenticated: authenticated);

  Future<dynamic> put(
    String path, {
    Object? body,
    bool authenticated = false,
  }) => request('PUT', path, body: body, authenticated: authenticated);

  Future<dynamic> request(
    String method,
    String path, {
    Object? body,
    bool authenticated = false,
    bool retryAfterRefresh = true,
  }) async {
    final headers = <String, String>{'Accept': 'application/json'};
    if (body != null) headers['Content-Type'] = 'application/json';
    if (authenticated && accessToken != null) {
      headers['Authorization'] = 'Bearer $accessToken';
    }
    final uri = Uri.parse('$baseUrl$path');
    final encodedBody = body == null ? null : jsonEncode(body);
    late http.Response response;
    try {
      response = switch (method) {
        'GET' => await _http.get(uri, headers: headers),
        'POST' => await _http.post(uri, headers: headers, body: encodedBody),
        'PUT' => await _http.put(uri, headers: headers, body: encodedBody),
        'PATCH' => await _http.patch(uri, headers: headers, body: encodedBody),
        'DELETE' => await _http.delete(
          uri,
          headers: headers,
          body: encodedBody,
        ),
        _ => throw ApiException('Unsupported HTTP method: $method'),
      };
    } on ApiException {
      rethrow;
    } on Object {
      throw const ApiException(
        'Cannot connect to the API. Check that go-tutorials is running.',
      );
    }

    if (response.statusCode == 401 &&
        authenticated &&
        retryAfterRefresh &&
        await _refresh()) {
      return request(
        method,
        path,
        body: body,
        authenticated: true,
        retryAfterRefresh: false,
      );
    }

    Map<String, dynamic>? envelope;
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) envelope = decoded;
    } on FormatException {
      // The status-based fallback below gives callers a useful error.
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        envelope?['message'] as String? ??
            'Request failed with status ${response.statusCode}.',
        statusCode: response.statusCode,
        code: envelope?['code'] as int?,
      );
    }
    return envelope?['data'];
  }

  Future<bool> _refresh() async {
    final token = refreshToken;
    if (token == null) return false;
    try {
      final response = await _http.post(
        Uri.parse('$baseUrl/api/v1/auth/refresh'),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': token}),
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        await clearSession();
        return false;
      }
      final envelope = jsonDecode(response.body) as Map<String, dynamic>;
      await saveTokens(envelope['data'] as Map<String, dynamic>);
      return true;
    } on Object {
      return false;
    }
  }
}
