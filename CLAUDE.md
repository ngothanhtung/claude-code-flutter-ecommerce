# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

"Everyday Store" is a Flutter e-commerce portfolio app with a searchable seeded catalog, cart/wishlist, simulated checkout, order history, notifications, persisted theme, and Material 3 chrome. Most features are offline via `shared_preferences` + `LocalStore`, but authentication and orders are backed by Firebase (`firebase_auth`, `cloud_firestore`) behind swappable repository interfaces.

## Commands

Run from this directory (`flutter_tutorials/`):

```bash
flutter pub get                          # install dependencies
flutter run                              # run the app (add -d <device> to pick a device)
flutter analyze                          # lint/static analysis (flutter_lints, build/ excluded)
flutter test                             # run all tests
flutter test test/widget_test.dart       # run one test file
flutter test --plain-name "logs in"      # run a single test by name substring
flutter test test/features/cart          # run one feature's tests by directory
```

## Architecture

Feature-first under `lib/features/<feature>/{data,presentation}`. Dependencies flow one way: **widgets → Riverpod providers/notifiers → repositories → `LocalStore` / Firebase / in-memory store**. Presentation code must not touch `SharedPreferences`, `LocalStore`, `firebase_auth`, or `cloud_firestore` directly.

- `lib/main.dart` initializes Firebase and `SharedPreferences`, builds a `LocalStore`, picks `FirebaseAuthRepository`, and routes to `LoginScreen` or `MainScreen`. The `MyApp` wrapper further down is a compatibility shim for tutorial embedders and runs `InMemoryAuthRepository` + `InMemoryOrderRepository` against mock prefs.
- `lib/core/local_store.dart` is the defensive JSON boundary around `SharedPreferences`; malformed payloads fall back silently to the supplied default. Every feature repository should go through it (or a Firebase-backed analog), never `SharedPreferences` directly.
- `lib/core/providers.dart` exposes only `localStoreProvider`, which is overridden at bootstrap. Do not add new top-level providers there.
- `lib/app/app.dart` owns named routes + `onGenerateRoute`. Static routes go in the `routes` map; parameterised routes (`ProductDetailScreen`, `CategoryProductsScreen`, `OrderSuccessScreen`, `OrderDetailScreen`, `ReviewProductScreen`) are matched by `settings.name` and `settings.arguments` (note: `ReviewProductScreen` expects a `ReviewScreenArgs` object, the rest expect a String id).
- `lib/app/theme.dart` + `lib/app/store_theme_preset.dart` build Material 3 themes from the active `StoreThemePreset` (see Theme section).
- `lib/shared/` holds `StoreScaffold` (responsive store chrome) and the currency formatter.
- Catalog (`lib/features/catalog/data/seed_data.dart`) is immutable. Cart and wishlist persist product IDs + quantities; orders persist product snapshots so they survive catalog changes. Notifications are seeded at first launch and supplemented by order events.
- `MainScreen` mounts the selected tab and listens to `cartTotalQuantityProvider`, `unreadNotificationsProvider`, and `mainTabProvider` via `ProviderSubscription` so badge counts survive `TickerMode` pauses during route transitions.

### Repository swap pattern

Cross-cutting features declare an interface in `data/` and ship two implementations:

| Interface | Production | Test/preview |
| --- | --- | --- |
| `AuthRepository` | `FirebaseAuthRepository` (`firebase_auth` + `google_sign_in`) | `InMemoryAuthRepository` |
| `OrderRepository` | `FirestoreOrderRepository` (`cloud_firestore` collection `orders`) | `InMemoryOrderRepository` |

The provider in `presentation/auth_providers.dart` / `order_providers.dart` returns the interface, and `main.dart` (or the `MyApp` shim / tests) overrides it via `ProviderScope.overrides`. New repositories should follow this pattern — define the interface, default to the Firebase implementation in the provider, override in tests with an in-memory variant.

`LegacyLocalOrderStore` still reads the old `orders` JSON from `SharedPreferences` so previously-installed local users keep their history after upgrading to Firebase.

### Theme

`storeThemePresetProvider` exposes one of five `StoreThemePreset` values: `freshGreen`, `fastFoodOrange` (default-on-error fallback in code), `autoRed`, `beautyPurple`, `ebookBrown`. Each preset has its own light/dark palette overriding a Material 3 `ColorScheme.fromSeed` with `dynamicSchemeVariant: DynamicSchemeVariant.fidelity`. Persisted under the `store_theme_preset` key. Light/dark system mode is separate, persisted under `theme_mode`, and exposed via `themeModeProvider`.

### Storage keys (LocalStore)

`users`, `session`, `cart`, `orders` (legacy), `wishlist`, `notifications`, `theme_mode`, `store_theme_preset`. Firebase collection: `orders` (documents keyed by order id, queried by `userId`).

## Testing conventions

- Tests mirror the lib tree under `test/`, e.g. `test/features/orders/order_repository_test.dart`.
- Persistence is isolated via `SharedPreferences.setMockInitialValues({...})`; instantiate `LocalStore(await SharedPreferences.getInstance())` inside each test that needs it.
- Firebase-backed features are exercised through their `InMemory*` doubles (`InMemoryAuthRepository`, `InMemoryOrderRepository`). Override the provider under test with `ProviderContainer(overrides: [...])` or `ProviderScope`.
- Preserve these keys when editing UI so widget tests keep finding them: auth flow keys `<prefix>-primary-button`, `<prefix>-secondary-button`, `name-field`, `email-field`, `password-field`; commerce flow keys `product-card-<id>`, `wishlist-<id>`, `add-to-cart-button`, `cart-badge`, `checkout-button`, `place-order-button`, `theme-mode-switch`, `logout-button`.

## Demo credentials

The `InMemoryAuthRepository` ships with `admin@claude.ai` / `147258369` and account name `Tony Nguyen`. The `FirebaseAuthRepository` does not use these — Firebase auth needs a real provider configured in `lib/firebase_options.dart` and `firebase.json`. Plaintext passwords are demo-only.
