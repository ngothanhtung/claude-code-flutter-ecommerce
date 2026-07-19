# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

"Everyday Store" is an offline-first Flutter e-commerce portfolio app. It has local authentication/session restore, a searchable seeded catalog, persistent cart and wishlist, simulated checkout with order history, generated notifications, and persisted light/dark theme selection. There is no backend; `shared_preferences` stores the small JSON datasets.

## Commands

Run from this directory (`flutter_tutorials/`):

```bash
flutter pub get                          # install dependencies
flutter run                              # run the app (add -d <device> to pick a device)
flutter analyze                          # lint/static analysis (flutter_lints ruleset)
flutter test                             # run all tests
flutter test test/widget_test.dart       # run one test file
flutter test --plain-name "logs in"      # run a single test by name substring
```

## Architecture

The app is feature-first under `lib/features/<feature>/data|presentation`. Dependencies flow in one direction: **widgets → Riverpod providers/notifiers → repositories → LocalStore**. Presentation code must not access `SharedPreferences` or `LocalStore` directly.

- `lib/main.dart` initializes `SharedPreferences`, restores the session, overrides `localStoreProvider`, and chooses Login/Main.
- `lib/app/` owns named routes and Material 3 light/dark themes (seed `0xFF1B5E4B`).
- `lib/core/local_store.dart` is the defensive JSON boundary; malformed stored data falls back safely.
- `lib/shared/` contains responsive store chrome and currency formatting.
- Catalog is immutable seed data; cart/wishlist persist product IDs, while orders persist product snapshots.
- `MainScreen` mounts the selected tab and listens to cart/unread badge providers independently of route `TickerMode`.

Storage keys: `users`, `session`, `cart`, `orders`, `wishlist`, `theme_mode`, `notifications`.

Demo credentials remain `admin@claude.ai` / `147258369`. Plaintext passwords are explicitly demo-only and must not be copied into a production architecture.

## Testing conventions

Tests isolate persistence with `SharedPreferences.setMockInitialValues`. Preserve auth keys (`<prefix>-primary-button`, `<prefix>-secondary-button`, `name-field`, `email-field`, `password-field`) and flow keys such as `product-card-<id>`, `wishlist-<id>`, `add-to-cart-button`, `cart-badge`, `checkout-button`, `place-order-button`, `theme-mode-switch`, and `logout-button`.
