import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalStore {
  const LocalStore(this.preferences);

  final SharedPreferences preferences;

  T readJson<T>(String key, T fallback, T Function(Object? json) decode) {
    final raw = preferences.getString(key);
    if (raw == null) return fallback;
    try {
      return decode(jsonDecode(raw));
    } on Object {
      return fallback;
    }
  }

  Future<void> writeJson(String key, Object? value) async {
    final saved = await preferences.setString(key, jsonEncode(value));
    if (!saved) throw StateError('Could not save $key');
  }

  String? readString(String key) => preferences.getString(key);

  Future<void> writeString(String key, String value) async {
    final saved = await preferences.setString(key, value);
    if (!saved) throw StateError('Could not save $key');
  }

  Future<void> remove(String key) async {
    final removed = await preferences.remove(key);
    if (!removed && preferences.containsKey(key)) {
      throw StateError('Could not remove $key');
    }
  }
}
