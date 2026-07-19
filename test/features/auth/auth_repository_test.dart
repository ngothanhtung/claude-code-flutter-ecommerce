import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tutorials/features/auth/data/auth_repository.dart';

void main() {
  late InMemoryAuthRepository repository;

  setUp(() {
    repository = InMemoryAuthRepository();
  });

  test('registers, normalizes email and restores current user', () async {
    final user = await repository.register(
      name: 'Mai Tran',
      email: ' MAI@Example.com ',
      password: 'secret1',
    );
    expect(user.email, 'mai@example.com');
    expect(repository.currentUser?.name, 'Mai Tran');
  });

  test('rejects duplicate email case-insensitively', () async {
    await repository.register(
      name: 'Mai',
      email: 'mai@example.com',
      password: 'secret1',
    );
    expect(
      () => repository.register(
        name: 'Other',
        email: 'MAI@example.com',
        password: 'secret2',
      ),
      throwsA(isA<DuplicateEmailException>()),
    );
  });

  test('supports preview login and rejects a wrong password', () async {
    expect(
      (await repository.login(
        InMemoryAuthRepository.demoEmail,
        InMemoryAuthRepository.demoPassword,
      )).name,
      'Tony Nguyen',
    );
    expect(
      () =>
          repository.login(InMemoryAuthRepository.demoEmail, 'wrong-password'),
      throwsA(isA<InvalidCredentialsException>()),
    );
  });

  test('removes the active user on logout', () async {
    await repository.login(
      InMemoryAuthRepository.demoEmail,
      InMemoryAuthRepository.demoPassword,
    );
    await repository.logout();
    expect(repository.currentUser, isNull);
  });
}
