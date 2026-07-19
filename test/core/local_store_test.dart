import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tutorials/core/local_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('reads fallback, round-trips json and tolerates corrupt data', () async {
    SharedPreferences.setMockInitialValues({});
    final store = LocalStore(await SharedPreferences.getInstance());
    expect(
      store.readJson(
        'missing',
        <String>[],
        (json) => (json as List).cast<String>(),
      ),
      isEmpty,
    );

    await store.writeJson('items', ['one', 'two']);
    expect(
      store.readJson(
        'items',
        <String>[],
        (json) => (json as List).cast<String>(),
      ),
      ['one', 'two'],
    );

    await store.preferences.setString('items', '{broken');
    expect(
      store.readJson(
        'items',
        <String>[],
        (json) => (json as List).cast<String>(),
      ),
      isEmpty,
    );
    await store.remove('items');
    expect(store.preferences.containsKey('items'), isFalse);
  });
}
