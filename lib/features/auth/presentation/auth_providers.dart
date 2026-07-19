import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';
import '../data/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => FirebaseAuthRepository(),
);
final currentUserProvider = NotifierProvider<CurrentUserNotifier, UserModel?>(
  CurrentUserNotifier.new,
);

class CurrentUserNotifier extends Notifier<UserModel?> {
  @override
  UserModel? build() => ref.read(authRepositoryProvider).currentUser;

  Future<void> login(String email, String password) async {
    state = await ref.read(authRepositoryProvider).login(email, password);
  }

  Future<void> register(String name, String email, String password) async {
    state = await ref
        .read(authRepositoryProvider)
        .register(name: name, email: email, password: password);
  }

  Future<void> loginWithGoogle() async {
    state = await ref.read(authRepositoryProvider).loginWithGoogle();
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = null;
  }
}
