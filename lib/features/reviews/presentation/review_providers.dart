import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/review_repository.dart';

final reviewRepositoryProvider = Provider<ReviewRepository>(
  (ref) => FirestoreReviewRepository(),
);
