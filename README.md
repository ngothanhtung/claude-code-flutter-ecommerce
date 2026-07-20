# Everyday Store

A Flutter e-commerce client backed by the REST API in `../go-tutorials`.

## Features

- REST registration, login, logout, JWT refresh, and session restore
- Products, categories, promos, orders, and reviews from the Go API
- Persistent cart and wishlist
- Simulated COD/demo-card checkout with persistent order history
- Seeded and order-generated notifications with read state
- Persisted light/dark theme
- Riverpod feature-first architecture with repository and LocalStore boundaries

## Run

Start PostgreSQL, Redis, migrations, and the Go server from `../go-tutorials`, then:

```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=http://localhost:8080
```

Android Emulator defaults to `http://10.0.2.2:8080`; iOS/macOS defaults to
`http://localhost:8080`. Use `API_BASE_URL` for a physical device or deployed API.

Development login: `admin@go-tutorials.local` / `Admin@123456`

JWT access/refresh tokens are stored in `shared_preferences`; use secure storage for a production release. Cart, wishlist, notification read state, and theme preferences remain local.

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
