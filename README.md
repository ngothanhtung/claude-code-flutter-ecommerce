# Everyday Store

An offline-first Flutter e-commerce demo built as a polished portfolio/tutorial app. It runs without a backend or network connection.

## Features

- Local registration, login, logout, and session restore
- Searchable 24-product catalog with category and product detail screens
- Persistent cart and wishlist
- Simulated COD/demo-card checkout with persistent order history
- Seeded and order-generated notifications with read state
- Persisted light/dark theme
- Riverpod feature-first architecture with repository and LocalStore boundaries

## Run

```bash
flutter pub get
flutter run
```

Demo login: `admin@claude.ai` / `147258369`

All data stays in `shared_preferences`. Credentials are stored in plaintext solely to demonstrate a local tutorial flow; this is not suitable for production authentication.

## Quality checks

```bash
flutter analyze
flutter test
```

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
