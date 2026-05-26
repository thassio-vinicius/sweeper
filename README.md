# Reversed Minesweeper

A Flutter implementation of the **Reversed Minesweeper** code challenge. Players rearrange pre-placed pieces on a grid to discover hidden bombs before the timer explodes them. Live BTC prices from Binance can spawn magic bombs when the displayed whole-dollar price lands on a value ending in **0** or **5**.

The challenge PDF is the functional contract; Figma was used as visual inspiration only.

---

## Flutter & Dart versions

| Tool | Version |
|------|---------|
| **Dart SDK** (constraint) | `^3.10.4` |
| **Flutter** (tested) | `3.38.5` stable |
| **Melos** | `^6.3.0` (dev dependency at repo root) |

Use Flutter 3.38.x or any release that ships Dart 3.10.4+. If you use [FVM](https://fvm.app/), point it at a compatible stable channel before running commands below.

---

## Quick start

```bash
# 1. Install Melos once (optional — also available via `dart run melos` at repo root)
dart pub global activate melos

# 2. Link local packages and run pub get everywhere
dart run melos bootstrap

# 3. Run the app (from repo root)
flutter run
```

**Platform targets:** `android/`, `ios/` at the repo root (standard Flutter layout).

**Internet required** for the Binance WebSocket BTC feed.

---

## How to play

1. **Start** — The game loads a board with hidden bombs and pre-placed pieces (same cyan ◆ design for every piece).
2. **Drag pieces** — Move pieces between empty cells. Drops on occupied cells bounce back (snap-back animation).
3. **Discover bombs** — Landing on a hidden bomb reveals it and increments the discovered counter; the piece stays on that cell.
4. **Timer** — Every **10 seconds** one random hidden bomb auto-explodes.
5. **Magic bombs** — When the live BTC price (whole dollars, UI-rounded) **lands on** a value ending in **0** or **5**, a new hidden bomb may appear (capped at the initial bomb count for that board size).
6. **Win / game over** — When all bombs are discovered or exploded, you are taken to the game-over screen with your discovered-bomb count.

### Pause & settings

- **Pause button** — Pauses the game and shows a pause overlay.
- **Settings (gear)** — Opens the bottom sheet (board size, auth). The game pauses silently in the background (no pause overlay).
- **Board sizes** — 8×8, 10×10 (default), or 12×12 via Settings.

### Authentication & guest mode

| Scenario | Behaviour |
|----------|-----------|
| **Firebase not configured** | Auth is disabled; app goes straight to the game. |
| **Firebase configured — iOS** | Google Sign-In required to play (no guest mode). |
| **Firebase configured — Android** | Google Sign-In **or** **Play as guest** (guest is not persisted; sign-in required again after app restart). |

Guest mode is resolved at startup via `AppAccessConfig` (Android-only flag), not scattered `Platform` checks in UI code.

---

## Architecture

Melos monorepo: one **app shell** at the repo root plus **local packages** under `packages/`. Each package is a separate Dart/Flutter module with its own `pubspec.yaml` and tests where applicable.

```
sweeper/                          ← App shell (android/, ios/, lib/, assets/)
├── lib/
│   ├── main.dart                 ← Firebase init, DI, runApp
│   ├── app.dart                  ← MaterialApp, BlocProviders, theme, l10n
│   ├── firebase_options.dart     ← Generated Firebase config
│   └── core/
│       ├── di/injection.dart     ← get_it wiring
│       └── router/               ← go_router + auth redirect
├── packages/
│   ├── sweeper_core/             ← Failures, Result, Clock (pure Dart)
│   ├── sweeper_theme/            ← Design tokens, AppTheme, shared widgets
│   ├── sweeper_l10n/             ← ARB files + generated localizations
│   ├── sweeper_network/          ← Authenticated HTTP client + interceptors
│   ├── sweeper_auth/             ← Firebase/Google auth, session, login UI
│   ├── sweeper_settings/         ← Board-size preferences (SettingsCubit)
│   └── sweeper_game/             ← Game domain, data, presentation
├── melos.yaml
└── pubspec.yaml
```

### Layering (within `sweeper_game`)

Feature-first **clean architecture**:

| Layer | Responsibility | Examples |
|-------|----------------|----------|
| **Domain** | Pure Dart rules & models | `GameEngine`, `GameConfig`, entities, `BtcPriceRepository` interface |
| **Data** | External I/O | Binance WebSocket, DTOs, repository implementations |
| **Presentation** | UI + state | `GameCubit`, `GamePage`, widgets, animations |

State management: **Cubits** (`flutter_bloc`). Navigation: **go_router**. DI: **get_it** (configured in the app shell).

### Package dependency graph

```
sweeper (app)
  ├── sweeper_auth ──► sweeper_core, sweeper_theme, sweeper_l10n
  ├── sweeper_game ──► sweeper_auth, sweeper_core, sweeper_theme, sweeper_l10n, sweeper_settings
  ├── sweeper_network ──► sweeper_auth, sweeper_core
  ├── sweeper_settings (standalone cubit)
  ├── sweeper_theme
  └── sweeper_l10n

sweeper_game ──► sweeper_settings   (grid size → GameConfig.fromGridSize)
sweeper_network ──► sweeper_auth    (AuthSession for bearer vs anonymous HTTP)
```

No circular dependencies: auth does not depend on game; settings does not depend on game (mapping lives in `GameConfig.fromGridSize`).

### Key design decisions

- **`GameEngine`** stays a single orchestrator (~200 lines) — all methods mutate one `GameSnapshot` and emit events. Board setup is extracted to `BoardInitializer`; grid cloning to `cell_grid_clone.dart`.
- **Theming** lives in `sweeper_theme` (Flip-inspired token system). Package assets (e.g. Google logo SVG) must be loaded with `package: 'sweeper_theme'`.
- **HTTP layer** is ready for future REST APIs (`AuthenticatedHttpClient` reads credential mode from `AuthSession`); live gameplay uses WebSocket only.

---

## PDF specification compliance

Mapping to the original code-challenge PDF (core + bonus items).

### Core requirements

| PDF requirement | Implementation |
|-----------------|----------------|
| 10×10 grid (default) | `GameConfig.gridSize = 10`; configurable 8 / 10 / 12 in Settings |
| Hidden bombs on the board | `BombStatus.hidden`; placed at init via `BoardInitializer` |
| Drag-and-drop | `BoardGrid` + `SnapBackDraggablePiece`; board-to-board only |
| Pre-placed pieces, player rearranges | Pieces on non-bomb cells at start; **no external piece tray** |
| Same design for all pieces | Single `PieceVisual` (cyan ◆ token) |
| Bomb discovery on drop | `movePiece` → `BombDiscoveredEvent`; counter increments |
| 10 s auto-explosion timer | `GameConfig.tickInterval`; `onTimerTick` explodes one random hidden bomb |
| Magic bombs from Binance BTC feed | `BinanceWebSocketDataSource` → `onBtcPriceUpdate` |
| Magic bomb when price divisible by 5 | Triggers when **displayed whole-dollar price lands on** 0 or 5 (`BtcPrice.landedOnDivisibleWhole`) |
| Game over when all bombs found/exploded | `GameEngine._finalize` → `GamePhase.gameOver` |
| Game-over screen with discovered count | `/game-over` route + `GameOverPage` |

### Bonus requirements

| PDF bonus | Implementation |
|-----------|----------------|
| Fancy animations | Custom explosion/magic-bomb/game-over animations; Rive wrapper ready (`assets/animations/explosion.riv`) |
| Social login | Google Sign-In via Firebase Auth (`sweeper_auth`) |
| Board size setting | `sweeper_settings` + Settings sheet (8×8, 10×10, 12×12) |
| Internationalization | `sweeper_l10n` — English, Portuguese, Spanish |

### Intentional notes

- **Google only** for social auth (PDF mentions social login; Apple/Facebook not implemented).
- **Guest mode** is an Android-only product extension for easier local testing; not in the PDF.
- **Magic bomb cap** — remaining hidden bombs cannot exceed the **initial** bomb count for the current board (silent ignore when at cap).

---

## Dependencies (high level)

### App shell (`pubspec.yaml`)

| Package | Purpose |
|---------|---------|
| `firebase_core` | Firebase initialization |
| `flutter_bloc` | Cubit providers |
| `get_it` | Dependency injection |
| `go_router` | Declarative routing |
| Local `sweeper_*` packages | See modules above |

### Notable transitive / package deps

| Package | Module | Purpose |
|---------|--------|---------|
| `web_socket_channel` | `sweeper_game` | Binance WebSocket |
| `rive` | `sweeper_game` | Optional Rive animations |
| `firebase_auth`, `google_sign_in` | `sweeper_auth` | Google Sign-In |
| `http` | `sweeper_network` | Authenticated HTTP client |
| `flutter_svg` | `sweeper_theme` | Google logo asset |
| `equatable` | game, auth, settings | Value equality |
| `intl` | `sweeper_l10n` | Localization formatting |

---

## Development workflow (Melos)

All commands run from the **repo root**:

```bash
dart run melos bootstrap      # pub get + link path packages (run after clone or pubspec changes)
dart run melos analyze        # dart/flutter analyze in every package
dart run melos test             # flutter test in packages that have test/
dart run melos run gen-l10n     # regenerate sweeper_l10n from ARB files
dart run melos run format       # dart format all packages
```

After editing ARB files in `packages/sweeper_l10n/lib/l10n/`, run `gen-l10n` before committing generated Dart.

**Single-package work** — you can also `cd packages/sweeper_game && flutter test`.

---

## Build & run by platform

### Android

```bash
flutter run -d android
# or
flutter build apk --debug
```

**Google Sign-In (debug):** add your machine’s **debug SHA-1** to the Firebase Android app (`google-services.json`). Other developers need their own SHA-1 registered or Sign-In will fail on their devices.

**Guest mode:** with Firebase configured, the login screen shows **Play as guest** on Android only.

### iOS

```bash
flutter run -d ios
# or open ios/Runner.xcworkspace in Xcode
```

Ensure `GoogleService-Info.plist` is in `ios/Runner/` and the URL scheme from Firebase is in `Info.plist`. Guest mode is **not** offered on iOS.

### Without Firebase

If `Firebase.initializeApp` fails or options are missing, the app skips auth and launches the game directly. Useful for playing the core PDF mechanics without OAuth setup.

---

## Firebase setup (Google Sign-In)

1. Create a project at [Firebase Console](https://console.firebase.google.com).
2. Register **Android** and **iOS** apps (bundle ID / application ID must match the project).
3. Download `google-services.json` → `android/app/`.
4. Download `GoogleService-Info.plist` → `ios/Runner/`.
5. Add **SHA-1** (debug and release) for Android OAuth.
6. Run [`flutterfire configure`](https://firebase.google.com/docs/flutter/setup) or maintain `lib/firebase_options.dart` manually.

---

## Binance WebSocket

- **Endpoint:** `wss://stream.binance.com:9443/ws`
- **Subscribe:** `btcusdt@ticker` (JSON SUBSCRIBE after connect)
- **DTO:** `BtcTickerDto` → `BtcPrice` (whole-dollar display uses `round()` for UI and magic-bomb logic)

---

## Testing

32 tests across the monorepo (game engine rules, cubit, auth session, HTTP client, widget smoke test):

```bash
dart run melos test
```

Game rule tests live in `packages/sweeper_game/test/` — especially `game_engine_test.dart` for magic-bomb landing logic and bomb cap behaviour.

---

## License

Private — code challenge submission.
