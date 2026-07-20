import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'local_store.dart';
import 'api_client.dart';

final localStoreProvider = Provider<LocalStore>((ref) {
  throw StateError('localStoreProvider must be overridden at app bootstrap');
});

final apiClientProvider = Provider<ApiClient>((ref) {
  throw StateError('apiClientProvider must be overridden at app bootstrap');
});
