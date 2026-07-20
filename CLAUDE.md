# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

"Everyday Store" is a Flutter e-commerce client for the REST service in `../go-tutorials`. Auth uses access/refresh JWTs; catalog, orders, and reviews come from the API. Cart, wishlist, notifications, and theme preferences remain local.

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

Feature-first under `lib/features/<feature>/{data,presentation}`. Dependencies flow one way: **widgets → Riverpod providers/notifiers → repositories → `ApiClient` / `LocalStore` / in-memory store**. Presentation code must not touch `SharedPreferences` or raw HTTP directly.

- `lib/main.dart` creates `ApiClient`, restores a JWT session, loads the catalog, and routes to `LoginScreen` or `MainScreen`. `MyApp` remains an offline compatibility shim for widget tests.
- `lib/core/api_client.dart` owns the API base URL, JSON envelope parsing, bearer token injection, and refresh-token rotation.
- `lib/core/local_store.dart` is the defensive JSON boundary around `SharedPreferences`; malformed payloads fall back to defaults.
- `lib/app/app.dart` owns named routes + `onGenerateRoute`. Static routes go in the `routes` map; parameterised routes (`ProductDetailScreen`, `CategoryProductsScreen`, `OrderSuccessScreen`, `OrderDetailScreen`, `ReviewProductScreen`) are matched by `settings.name` and `settings.arguments` (note: `ReviewProductScreen` expects a `ReviewScreenArgs` object, the rest expect a String id).
- `lib/app/theme.dart` + `lib/app/store_theme_preset.dart` build Material 3 themes from the active `StoreThemePreset` (see Theme section).
- `lib/shared/` holds `StoreScaffold` (responsive store chrome) and the currency formatter.
- The production catalog is loaded from `/api/v1/catalog`; `seed_data.dart` is retained only for tests/preview. Cart and wishlist persist product IDs + quantities locally.
- `MainScreen` mounts the selected tab and listens to `cartTotalQuantityProvider`, `unreadNotificationsProvider`, and `mainTabProvider` via `ProviderSubscription` so badge counts survive `TickerMode` pauses during route transitions.

### Repository swap pattern

Cross-cutting features declare an interface in `data/` and ship two implementations:

| Interface | Production | Test/preview |
| --- | --- | --- |
| `AuthRepository` | `ApiAuthRepository` | `InMemoryAuthRepository` |
| `OrderRepository` | `ApiOrderRepository` | `InMemoryOrderRepository` |

The provider in `presentation/auth_providers.dart` / `order_providers.dart` returns the interface, and tests override it via `ProviderScope.overrides`.

`LegacyLocalOrderStore` reads the old local `orders` JSON for one-time migration to the API.

### Theme

`storeThemePresetProvider` exposes one of five `StoreThemePreset` values: `freshGreen`, `fastFoodOrange` (default-on-error fallback in code), `autoRed`, `beautyPurple`, `ebookBrown`. Each preset has its own light/dark palette overriding a Material 3 `ColorScheme.fromSeed` with `dynamicSchemeVariant: DynamicSchemeVariant.fidelity`. Persisted under the `store_theme_preset` key. Light/dark system mode is separate, persisted under `theme_mode`, and exposed via `themeModeProvider`.

### Storage keys (LocalStore)

`cart`, `orders` (legacy), `wishlist`, `notifications`, `theme_mode`, `store_theme_preset`, `api_access_token`, `api_refresh_token`.

## Testing conventions

- Tests mirror the lib tree under `test/`, e.g. `test/features/orders/order_repository_test.dart`.
- Persistence is isolated via `SharedPreferences.setMockInitialValues({...})`; instantiate `LocalStore(await SharedPreferences.getInstance())` inside each test that needs it.
- API-backed features are exercised through their `InMemory*` doubles. Override providers under test with `ProviderContainer(overrides: [...])` or `ProviderScope`.
- Preserve these keys when editing UI so widget tests keep finding them: auth flow keys `<prefix>-primary-button`, `<prefix>-secondary-button`, `name-field`, `email-field`, `password-field`; commerce flow keys `product-card-<id>`, `wishlist-<id>`, `add-to-cart-button`, `cart-badge`, `checkout-button`, `place-order-button`, `theme-mode-switch`, `logout-button`.

## Demo credentials

The API development admin is `admin@go-tutorials.local` / `Admin@123456`. `InMemoryAuthRepository` retains its separate credentials for automated tests only.
