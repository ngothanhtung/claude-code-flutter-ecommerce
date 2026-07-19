#!/usr/bin/env dart
// ignore_for_file: file_names

/// Seeds deterministic e-commerce mock data into Cloud Firestore.
///
/// From this directory:
///   dart pub get
///   dart run mock-data-service.dart --dry-run
///   dart run mock-data-service.dart
///
/// Upserts are safe to repeat. Deleting stale documents requires both
/// `--delete-stale` and `--yes`.
library;

import 'dart:convert';
import 'dart:io';

import 'package:firebase_admin_sdk/firebase_admin_sdk.dart';
import 'package:google_cloud_firestore/google_cloud_firestore.dart'
    hide Credential;

const projectId = 'claude-code-flutter-ecommerce';
const credentialFileName =
    'claude-code-flutter-ecommerce-firebase-adminsdk-fbsvc-630f524fc2.json';
const batchLimit = 400;

typedef JsonMap = Map<String, Object?>;

JsonMap category(
  String id,
  String name,
  String icon,
  String color,
  int sortOrder,
) => {
  'id': id,
  'name': name,
  'icon': icon,
  'color': color,
  'sortOrder': sortOrder,
  'isActive': true,
  'schemaVersion': 1,
};

final categories = <JsonMap>[
  category('fashion', 'Fashion', 'checkroom_rounded', '#13795B', 1),
  category('tech', 'Tech', 'devices_rounded', '#3B668E', 2),
  category('home', 'Home', 'chair_alt_rounded', '#C45D2D', 3),
  category('beauty', 'Beauty', 'spa_rounded', '#A64D79', 4),
  category('fitness', 'Fitness', 'fitness_center_rounded', '#7557A7', 5),
  category('travel', 'Travel', 'luggage_rounded', '#996515', 6),
];

JsonMap product(
  String id,
  String name,
  double price,
  double rating,
  int reviews,
  String icon,
  String color,
  String categoryId,
  String description, {
  bool featured = false,
}) {
  final stock = 20 + id.codeUnits.fold(0, (total, value) => total + value) % 81;
  return {
    'id': id,
    'sku': id.replaceAll('-', '_').toUpperCase(),
    'name': name,
    'price': price,
    'currency': 'USD',
    'rating': rating,
    'reviews': reviews,
    'icon': icon,
    'color': color,
    'categoryId': categoryId,
    'description': description,
    'imageUrl': 'https://picsum.photos/seed/$id-gallery-1/1200/900',
    'imageUrls': List.generate(
      3,
      (index) => 'https://picsum.photos/seed/$id-gallery-${index + 1}/1200/900',
    ),
    'stock': stock,
    'featured': featured,
    'isActive': true,
    'schemaVersion': 2,
  };
}

final products = <JsonMap>[
  product(
    'airflex-runner',
    'AirFlex Runner',
    120,
    4.8,
    328,
    'directions_run_rounded',
    '#13795B',
    'fitness',
    'A featherlight everyday runner with responsive cushioning and breathable knit comfort.',
    featured: true,
  ),
  product(
    'cloud-knit-set',
    'Cloud Knit Set',
    84,
    4.9,
    186,
    'checkroom_rounded',
    '#7557A7',
    'fashion',
    'Soft, relaxed knit separates designed for polished comfort from morning to night.',
    featured: true,
  ),
  product(
    'smart-tumbler',
    'Smart Tumbler',
    42,
    4.7,
    94,
    'water_drop_rounded',
    '#C45D2D',
    'travel',
    'A temperature-aware insulated tumbler that keeps your favorite drink just right.',
    featured: true,
  ),
  product(
    'studio-headset',
    'Studio Headset',
    159,
    4.9,
    412,
    'headphones_rounded',
    '#3B668E',
    'tech',
    'Immersive wireless audio, calm noise cancellation and all-day memory foam comfort.',
    featured: true,
  ),
  product(
    'linen-overshirt',
    'Linen Overshirt',
    68,
    4.6,
    74,
    'dry_cleaning_rounded',
    '#4F7B68',
    'fashion',
    'An easy linen layer with a clean drape and naturally breathable finish.',
  ),
  product(
    'everyday-tote',
    'Everyday Tote',
    56,
    4.8,
    143,
    'shopping_bag_rounded',
    '#9C6B4F',
    'fashion',
    'A structured carryall with smart pockets for workdays and weekends.',
  ),
  product(
    'soft-step-slides',
    'Soft Step Slides',
    38,
    4.5,
    88,
    'ice_skating_rounded',
    '#B06856',
    'fashion',
    'Minimal slides shaped with a soft footbed for effortless daily wear.',
  ),
  product(
    'pocket-speaker',
    'Pocket Speaker',
    79,
    4.7,
    215,
    'speaker_rounded',
    '#3B668E',
    'tech',
    'Room-filling sound in a compact, water-resistant shell made to travel.',
  ),
  product(
    'focus-keyboard',
    'Focus Keyboard',
    109,
    4.8,
    162,
    'keyboard_rounded',
    '#587A85',
    'tech',
    'A quiet low-profile keyboard tuned for focused, comfortable typing.',
  ),
  product(
    'halo-lamp',
    'Halo Desk Lamp',
    64,
    4.6,
    119,
    'light_rounded',
    '#996515',
    'tech',
    'Warm-to-cool task lighting with touch controls and a calm silhouette.',
  ),
  product(
    'mini-power-bank',
    'Mini Power Bank',
    48,
    4.7,
    301,
    'battery_charging_full_rounded',
    '#466A58',
    'tech',
    'Pocket-size fast charging with enough power for a full day away.',
  ),
  product(
    'curve-chair',
    'Curve Lounge Chair',
    240,
    4.9,
    67,
    'chair_rounded',
    '#C45D2D',
    'home',
    'A sculptural accent chair with generous curves and supportive comfort.',
  ),
  product(
    'woven-throw',
    'Woven Throw',
    52,
    4.8,
    132,
    'bed_rounded',
    '#B06A45',
    'home',
    'A softly textured throw woven for cozy layers and quiet color.',
  ),
  product(
    'aroma-diffuser',
    'Aroma Diffuser',
    45,
    4.6,
    207,
    'air_rounded',
    '#6A806C',
    'home',
    'Silent mist and ambient light for a more restful room ritual.',
  ),
  product(
    'stoneware-set',
    'Stoneware Set',
    96,
    4.9,
    91,
    'dinner_dining_rounded',
    '#8E6048',
    'home',
    'Hand-finished everyday tableware with warm, softly varied glazing.',
  ),
  product(
    'dew-serum',
    'Morning Dew Serum',
    39,
    4.8,
    284,
    'water_drop_outlined',
    '#A64D79',
    'beauty',
    'A lightweight hydration serum for calm, luminous-looking skin.',
  ),
  product(
    'velvet-balm',
    'Velvet Lip Balm',
    18,
    4.7,
    191,
    'brush_rounded',
    '#B5526F',
    'beauty',
    'A cushiony tinted balm with a smooth, comfortable finish.',
  ),
  product(
    'ritual-cleanser',
    'Ritual Cleanser',
    28,
    4.6,
    156,
    'bubble_chart_rounded',
    '#7C9A84',
    'beauty',
    'A gentle daily cleanser that lifts away the day without tightness.',
  ),
  product(
    'calm-candle',
    'Calm Candle',
    32,
    4.9,
    233,
    'local_fire_department_rounded',
    '#8A5C70',
    'beauty',
    'Cedar, fig and soft musk poured into a reusable stone vessel.',
  ),
  product(
    'balance-mat',
    'Balance Yoga Mat',
    72,
    4.8,
    176,
    'self_improvement_rounded',
    '#7557A7',
    'fitness',
    'A grippy, cushioned mat designed to keep every practice grounded.',
  ),
  product(
    'motion-bands',
    'Motion Bands',
    34,
    4.6,
    113,
    'linear_scale_rounded',
    '#67528E',
    'fitness',
    'Five smooth resistance levels in a compact carry pouch.',
  ),
  product(
    'trail-bottle',
    'Trail Bottle',
    36,
    4.7,
    249,
    'sports_gymnastics_rounded',
    '#4F7B68',
    'fitness',
    'A durable, easy-carry bottle ready for training and trails.',
  ),
  product(
    'weekender-pack',
    'Weekender Pack',
    118,
    4.9,
    198,
    'backpack_rounded',
    '#996515',
    'travel',
    'A refined carry-on pack with a clamshell opening and clever organization.',
  ),
  product(
    'sleep-kit',
    'Cloud Sleep Kit',
    46,
    4.8,
    127,
    'bedtime_rounded',
    '#6B648C',
    'travel',
    'A soft eye mask, travel pillow and pouch for quieter journeys.',
  ),
];

final promos = <JsonMap>[
  {
    'id': 'weekend-edit',
    'badge': 'WEEKEND EDIT',
    'title': 'Comfort, styled better.',
    'subtitle': 'Up to 40% off modern essentials.',
    'icon': 'checkroom_rounded',
    'color': '#13795B',
    'sortOrder': 1,
    'isActive': true,
    'schemaVersion': 1,
  },
  {
    'id': 'members-only',
    'badge': 'MEMBERS ONLY',
    'title': 'Little upgrades, big joy.',
    'subtitle': 'Earn double points on home picks.',
    'icon': 'chair_alt_rounded',
    'color': '#7557A7',
    'sortOrder': 2,
    'isActive': true,
    'schemaVersion': 1,
  },
  {
    'id': 'fast-delivery',
    'badge': 'FAST DELIVERY',
    'title': 'Fresh picks at your door.',
    'subtitle': r'Free next-day shipping over $80.',
    'icon': 'local_shipping_rounded',
    'color': '#C45D2D',
    'sortOrder': 3,
    'isActive': true,
    'schemaVersion': 1,
  },
];

Map<String, List<JsonMap>> get seedData => {
  'categories': categories,
  'products': products,
  'promos': promos,
};

final class Options {
  Options({
    required this.credentials,
    required this.expectedProjectId,
    required this.dryRun,
    required this.deleteStale,
    required this.confirmed,
  });

  final File credentials;
  final String expectedProjectId;
  final bool dryRun;
  final bool deleteStale;
  final bool confirmed;
}

Never _usage([String? error]) {
  if (error != null) stderr.writeln('Error: $error\n');
  stdout.writeln('''
Usage: dart run mock-data-service.dart [options]

Options:
  --credentials <path>   Service-account JSON path.
  --project-id <id>      Expected Firebase project ID.
  --dry-run              Validate only; do not connect or write.
  --delete-stale         Delete unseeded docs from managed collections.
  --yes                  Required confirmation for --delete-stale.
  --help                 Show this help.
''');
  exit(error == null ? 0 : 64);
}

Options parseOptions(List<String> arguments) {
  final scriptDirectory = File.fromUri(Platform.script).parent;
  var credentials = File('${scriptDirectory.path}/$credentialFileName');
  var expectedProjectId = projectId;
  var dryRun = false;
  var deleteStale = false;
  var confirmed = false;

  String valueAfter(int index, String flag) {
    if (index + 1 >= arguments.length ||
        arguments[index + 1].startsWith('--')) {
      _usage('$flag requires a value.');
    }
    return arguments[index + 1];
  }

  for (var index = 0; index < arguments.length; index++) {
    switch (arguments[index]) {
      case '--credentials':
        credentials = File(valueAfter(index, '--credentials'));
        index++;
      case '--project-id':
        expectedProjectId = valueAfter(index, '--project-id');
        index++;
      case '--dry-run':
        dryRun = true;
      case '--delete-stale':
        deleteStale = true;
      case '--yes':
        confirmed = true;
      case '--help' || '-h':
        _usage();
      default:
        _usage('Unknown option: ${arguments[index]}');
    }
  }

  return Options(
    credentials: credentials.absolute,
    expectedProjectId: expectedProjectId,
    dryRun: dryRun,
    deleteStale: deleteStale,
    confirmed: confirmed,
  );
}

void validateSeed() {
  final categoryIds = categories.map((item) => item['id'] as String).toSet();
  if (categoryIds.length != categories.length) {
    throw const FormatException('Category IDs must be unique.');
  }

  final productIds = products.map((item) => item['id'] as String).toSet();
  if (productIds.length != products.length) {
    throw const FormatException('Product IDs must be unique.');
  }

  final productCategoryIds = products
      .map((item) => item['categoryId'] as String)
      .toSet();
  final unknownCategories = productCategoryIds.difference(categoryIds);
  if (unknownCategories.isNotEmpty) {
    throw FormatException(
      'Products reference unknown categories: $unknownCategories',
    );
  }

  final emptyCategories = categoryIds.difference(productCategoryIds);
  if (emptyCategories.isNotEmpty) {
    throw FormatException('Categories without products: $emptyCategories');
  }

  for (final item in products) {
    final price = item['price'] as num;
    final rating = item['rating'] as num;
    final stock = item['stock'] as int;
    if (price <= 0 || rating < 0 || rating > 5 || stock < 0) {
      throw FormatException('Invalid product values for ${item['id']}.');
    }
  }
}

String credentialProjectId(File credentials) {
  if (!credentials.existsSync()) {
    throw FileSystemException('Credential file not found', credentials.path);
  }
  final decoded = jsonDecode(credentials.readAsStringSync());
  if (decoded is! Map<String, dynamic> ||
      decoded['project_id'] is! String ||
      (decoded['project_id'] as String).isEmpty) {
    throw const FormatException(
      'Credential JSON does not contain a valid project_id.',
    );
  }
  return decoded['project_id'] as String;
}

void printSummary(String action, String targetProjectId) {
  stdout.writeln('$action project: $targetProjectId');
  for (final entry in seedData.entries) {
    stdout.writeln('  ${entry.key}: ${entry.value.length} documents');
  }
}

Iterable<List<T>> chunks<T>(List<T> values, int size) sync* {
  for (var index = 0; index < values.length; index += size) {
    final end = index + size < values.length ? index + size : values.length;
    yield values.sublist(index, end);
  }
}

Future<void> seedFirestore(Options options) async {
  final app = FirebaseApp.initializeApp(
    options: AppOptions(
      credential: Credential.fromServiceAccount(options.credentials),
      projectId: options.expectedProjectId,
    ),
  );

  try {
    final database = app.firestore();

    if (options.deleteStale) {
      for (final entry in seedData.entries) {
        final seededIds = entry.value
            .map((document) => document['id'] as String)
            .toSet();
        final snapshot = await database.collection(entry.key).get();
        final staleDocuments = snapshot.docs
            .where((document) => !seededIds.contains(document.id))
            .toList();

        for (final documentGroup in chunks(staleDocuments, batchLimit)) {
          final batch = database.batch();
          for (final document in documentGroup) {
            batch.delete(document.ref);
          }
          await batch.commit();
        }
        if (staleDocuments.isNotEmpty) {
          stdout.writeln(
            'Deleted ${staleDocuments.length} stale documents from ${entry.key}.',
          );
        }
      }
    }

    for (final entry in seedData.entries) {
      final batch = database.batch();
      for (final document in entry.value) {
        final payload = <String, Object?>{
          ...document,
          'updatedAt': FieldValue.serverTimestamp,
        };
        final reference = database
            .collection(entry.key)
            .doc(document['id'] as String);
        batch.set(reference, payload, options: const SetOptions.merge());
      }
      await batch.commit();
    }

    await database.collection('store_config').doc('catalog_seed').set({
      'schemaVersion': 1,
      'collections': {
        for (final entry in seedData.entries) entry.key: entry.value.length,
      },
      'updatedAt': FieldValue.serverTimestamp,
    }, options: const SetOptions.merge());

    for (final entry in seedData.entries) {
      final expectedIds = entry.value
          .map((document) => document['id'] as String)
          .toSet();
      final snapshot = await database.collection(entry.key).get();
      final storedIds = snapshot.docs.map((document) => document.id).toSet();
      final missingIds = expectedIds.difference(storedIds);
      if (missingIds.isNotEmpty) {
        throw StateError(
          'Verification failed for ${entry.key}; missing: $missingIds',
        );
      }
      stdout.writeln(
        'Verified ${expectedIds.length}/${expectedIds.length} seeded '
        'documents in ${entry.key}.',
      );
    }
  } finally {
    await app.close();
  }
}

Future<void> main(List<String> arguments) async {
  try {
    final options = parseOptions(arguments);
    validateSeed();

    if (options.deleteStale && !options.confirmed) {
      throw const FormatException(
        '--delete-stale requires explicit confirmation with --yes.',
      );
    }

    if (options.dryRun) {
      printSummary('Dry-run for', options.expectedProjectId);
      stdout.writeln(
        'Validation passed; no Firebase connection or write was performed.',
      );
      return;
    }

    final credentialTarget = credentialProjectId(options.credentials);
    if (credentialTarget != options.expectedProjectId) {
      throw FormatException(
        'Project mismatch: credential targets "$credentialTarget", expected '
        '"${options.expectedProjectId}".',
      );
    }

    printSummary('Seeding', options.expectedProjectId);
    await seedFirestore(options);
    stdout.writeln('Firestore seed completed successfully.');
  } on FormatException catch (error) {
    stderr.writeln('Error: ${error.message}');
    exitCode = 64;
  } on FileSystemException catch (error) {
    stderr.writeln('Error: ${error.message}: ${error.path}');
    exitCode = 66;
  } catch (error) {
    stderr.writeln('Firebase seed failed: $error');
    exitCode = 1;
  }
}
