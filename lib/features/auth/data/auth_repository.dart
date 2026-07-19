import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  Future<UserModel> loginWithGoogle();

  Future<void> logout();
}

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({FirebaseAuth? auth, GoogleSignIn? googleSignIn})
    : _auth = auth ?? FirebaseAuth.instance,
      _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  Future<void>? _googleInitialization;

  @override
  UserModel? get currentUser => _toUserModel(_auth.currentUser);

  Future<void> _initializeGoogleSignIn() =>
      _googleInitialization ??= _googleSignIn.initialize();

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
      await credential.user?.updateDisplayName(name.trim());
      await credential.user?.reload();
      return _requireUser(_auth.currentUser ?? credential.user);
    } on FirebaseAuthException catch (error) {
      throw _mapFirebaseError(error);
    }
  }

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
      return _requireUser(credential.user);
    } on FirebaseAuthException catch (error) {
      throw _mapFirebaseError(error);
    }
  }

  @override
  Future<UserModel> loginWithGoogle() async {
    try {
      await _initializeGoogleSignIn();
      final googleUser = await _googleSignIn.authenticate();
      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) {
        throw const AuthOperationException(
          'Google did not return a valid identity token.',
        );
      }
      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final result = await _auth.signInWithCredential(credential);
      return _requireUser(result.user);
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        throw const AuthCancelledException();
      }
      throw AuthOperationException(
        error.description ?? 'Unable to sign in with Google.',
      );
    } on FirebaseAuthException catch (error) {
      throw _mapFirebaseError(error);
    }
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
    try {
      await _initializeGoogleSignIn();
      await _googleSignIn.signOut();
    } on GoogleSignInException {
      // Firebase is already signed out; stale Google state can be retried later.
    }
  }

  UserModel _requireUser(User? user) {
    final model = _toUserModel(user);
    if (model == null) {
      throw const AuthOperationException('Authentication returned no user.');
    }
    return model;
  }

  UserModel? _toUserModel(User? user) {
    if (user == null) return null;
    final email = user.email ?? '';
    final fallbackName = email.isEmpty
        ? 'Everyday member'
        : email.split('@').first;
    return UserModel(
      id: user.uid,
      name: user.displayName?.trim().isNotEmpty == true
          ? user.displayName!.trim()
          : fallbackName,
      email: email,
      photoUrl: user.photoURL,
    );
  }

  AuthFailure _mapFirebaseError(FirebaseAuthException error) {
    return switch (error.code) {
      'email-already-in-use' => const DuplicateEmailException(),
      'invalid-credential' ||
      'invalid-email' ||
      'user-disabled' ||
      'user-not-found' ||
      'wrong-password' => const InvalidCredentialsException(),
      'weak-password' => const AuthOperationException(
        'Use a stronger password with at least 6 characters.',
      ),
      'network-request-failed' => const AuthOperationException(
        'Check your internet connection and try again.',
      ),
      'too-many-requests' => const AuthOperationException(
        'Too many attempts. Please wait a moment and try again.',
      ),
      'operation-not-allowed' => const AuthOperationException(
        'This sign-in method is not enabled in Firebase.',
      ),
      _ => AuthOperationException(
        error.message ?? 'Authentication failed. Please try again.',
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
  Future<UserModel> loginWithGoogle() async {
    throw const AuthOperationException(
      'Google Sign-In is unavailable in preview mode.',
    );
  }

  @override
  Future<void> logout() async => _currentUser = null;
}
