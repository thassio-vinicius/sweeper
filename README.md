# Reversed Minesweeper

A Flutter board game where you drag pieces onto a grid while avoiding hidden bombs. Bombs auto-detonate every 10 seconds, and magic bombs appear when the live BTC price (from Binance) lands on whole dollars ending in 0 or 5.

## Features

- 10×10 grid (configurable: 8×8, 10×10, 12×12)
- Drag-and-drop piece rearrangement on the board with snap-back on invalid moves
- Pre-placed pieces (same design) on non-bomb cells at game start
- Hidden bomb discovery mechanics
- 10-second auto-explosion timer
- Live BTC price feed via Binance WebSocket (magic bombs)
- Explosion and game-over animations
- i18n: English, Portuguese, Spanish
- Google Sign-In (bonus — requires Firebase setup)

## Monorepo layout

This project uses [Melos](https://melos.invertase.dev/) to manage local packages:

```
packages/
  sweeper_core/     Shared failures, result type, clock
  sweeper_theme/    Design tokens, theme, shared widgets
  sweeper_l10n/     Generated localizations
  sweeper_network/  HTTP client + interceptors
  sweeper_settings/ Board size and user preferences
  sweeper_auth/     Firebase/Google auth, session, login UI
  sweeper_game/     Game domain, data, presentation
lib/                App glue: main, DI, router, Firebase options
```

The root `sweeper` app wires packages together via `get_it`, `go_router`, and Firebase platform config.

## Prerequisites

- Flutter SDK ^3.10.4
- [Melos](https://melos.invertase.dev/) (installed via `dart pub global activate melos` or as a dev dependency)
- Xcode (iOS) or Android Studio (Android)
- Internet connection (Binance WebSocket)

## Getting Started

```bash
dart pub global activate melos   # once, if not already installed
dart run melos bootstrap
flutter run
```

## Development commands

```bash
dart run melos bootstrap   # link local packages + pub get everywhere
dart run melos analyze     # analyze all packages
dart run melos test        # run package tests
dart run melos run gen-l10n  # regenerate localizations in sweeper_l10n
```

## Running Tests

```bash
dart run melos test
```

Or from the app root:

```bash
flutter test
```

## Firebase Setup (Optional — Google Sign-In)

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Add Android and iOS apps
3. Download `google-services.json` → `android/app/`
4. Download `GoogleService-Info.plist` → `ios/Runner/`
5. Run `flutterfire configure` or add Firebase options manually

Auth gracefully degrades when Firebase is not configured.

## Binance WebSocket

Connects to `wss://stream.binance.com:9443/ws/stream` and subscribes to `btcusdt@ticker`.

## License

Private — code challenge submission.
