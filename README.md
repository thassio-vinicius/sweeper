# Reversed Minesweeper

A Flutter board game where you drag pieces onto a grid while avoiding hidden bombs. Bombs auto-detonate every 10 seconds, and magic bombs appear when the live BTC price (from Binance) is divisible by 5.

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

## Architecture

Feature-first clean architecture with three layers:

- **Presentation** — Flutter widgets, Cubits
- **Domain** — Entities, `GameEngine`, repository interfaces
- **Data** — Binance WebSocket, DTOs, repository implementations

## Prerequisites

- Flutter SDK ^3.10.4
- Xcode (iOS) or Android Studio (Android)
- Internet connection (Binance WebSocket)

## Getting Started

```bash
flutter pub get
flutter gen-l10n
flutter run
```

## Running Tests

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

## Project Structure

```
lib/
  core/           # DI, theme, errors, l10n, utils
  features/
    game/         # Main game feature (domain, data, presentation)
    auth/         # Google sign-in (bonus)
    settings/     # Board size picker (bonus)
```

## Binance WebSocket

Connects to `wss://stream.binance.com:9443/ws/stream` and subscribes to `btcusdt@ticker`.

## License

Private — code challenge submission.
