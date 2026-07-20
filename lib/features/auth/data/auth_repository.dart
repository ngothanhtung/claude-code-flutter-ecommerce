import '../../../core/api_client.dart';
import 'user_model.dart';

sealed class AuthFailure implements Exception {
  const AuthFailure(this.message);
  final String message;
}

class DuplicateEmailException extends AuthFailure {
  const DuplicateEmailException()
    : super('An account with this email already exists.');
}

class InvalidCredentialsException extends AuthFailure {
  const InvalidCredentialsException()
    : super('The email or password is incorrect.');
}

class AuthCancelledException extends AuthFailure {
  const AuthCancelledException() : super('Sign-in was cancelled.');
}

class AuthOperationException extends AuthFailure {
  const AuthOperationException(super.message);
}

abstract interface class AuthRepository {
  UserModel? get currentUser;

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  });

  Future<UserModel> login(String email, String password);

  Future<void> logout();
}

class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository(this.api);

  final ApiClient api;
  UserModel? _currentUser;

  @override
  UserModel? get currentUser => _currentUser;

  Future<UserModel?> restoreSession() async {
    if (!api.hasSession) return null;
    try {
      return _currentUser = await _loadCurrentUser();
    } on Object {
      await api.clearSession();
      return null;
    }
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final data =
          await api.post(
                '/api/v1/auth/register',
                body: {
                  'name': name.trim(),
                  'email': email.trim().toLowerCase(),
                  'password': password,
                },
              )
              as Map<String, dynamic>;
      await api.saveTokens(data['tokens'] as Map<String, dynamic>);
      return _currentUser = UserModel.fromJson(
        data['user'] as Map<String, dynamic>,
      );
    } on ApiException catch (error) {
      throw _mapApiError(error);
    }
  }

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final tokens =
          await api.post(
                '/api/v1/auth/login',
                body: {
                  'email': email.trim().toLowerCase(),
                  'password': password,
                },
              )
              as Map<String, dynamic>;
      await api.saveTokens(tokens);
      return _currentUser = await _loadCurrentUser();
    } on ApiException catch (error) {
      throw _mapApiError(error);
    }
  }

  @override
  Future<void> logout() async {
    final refreshToken = api.refreshToken;
    try {
      if (refreshToken != null) {
        await api.post(
          '/api/v1/auth/logout',
          authenticated: true,
          body: {'refresh_token': refreshToken},
        );
      }
    } on Object {
      // Local logout must still succeed when the server is unavailable.
    } finally {
      _currentUser = null;
      await api.clearSession();
    }
  }

  Future<UserModel> _loadCurrentUser() async {
    final data =
        await api.get('/api/v1/users/me', authenticated: true)
            as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }

  AuthFailure _mapApiError(ApiException error) {
    return switch (error.code) {
      4013 => const DuplicateEmailException(),
      4010 => const InvalidCredentialsException(),
      _ => AuthOperationException(
        error.statusCode == null
            ? 'Cannot connect to the API. Check that go-tutorials is running.'
            : error.message,
      ),
    };
  }
}

/// In-memory auth used only by the compatibility app wrapper and automated tests.
class InMemoryAuthRepository implements AuthRepository {
  static const demoEmail = 'admin@claude.ai';
  static const demoPassword = '147258369';

  final Map<String, ({String name, String password})> _accounts = {
    demoEmail: (name: 'Tony Nguyen', password: demoPassword),
  };
  UserModel? _currentUser;

  @override
  UserModel? get currentUser => _currentUser;

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final normalized = email.trim().toLowerCase();
    if (_accounts.containsKey(normalized)) {
      throw const DuplicateEmailException();
    }
    _accounts[normalized] = (name: name.trim(), password: password);
    return _currentUser = UserModel(
      id: normalized,
      name: name.trim(),
      email: normalized,
    );
  }

  @override
  Future<UserModel> login(String email, String password) async {
    final normalized = email.trim().toLowerCase();
    final account = _accounts[normalized];
    if (account == null || account.password != password) {
      throw const InvalidCredentialsException();
    }
    return _currentUser = UserModel(
      id: normalized,
      name: account.name,
      email: normalized,
    );
  }

  @override
  Future<void> logout() async => _currentUser = null;
}
