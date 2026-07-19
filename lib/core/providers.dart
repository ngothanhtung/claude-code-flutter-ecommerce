import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'local_store.dart';

final localStoreProvider = Provider<LocalStore>((ref) {
  throw StateError('localStoreProvider must be overridden at app bootstrap');
});
