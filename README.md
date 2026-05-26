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

# 3. Copy env template and fill in Firebase / Google Sign-In values
cp .env.example .env
# Values from Firebase Console or `flutterfire configure`

# 4. Add Firebase native config (gitignored — not in the repo)
cp android/app/google-services.json.example android/app/google-services.json
cp ios/Runner/GoogleService-Info.plist.example ios/Runner/GoogleService-Info.plist
# Replace placeholders with values from Firebase Console → Project settings → Your apps

# 5. Run on a device or simulator (Android / iOS only)
flutter run
```

**Platform targets:** **Android** and **iOS** only (`android/`, `ios/` at repo root).

**Internet required** for the Binance WebSocket BTC feed.

**Firebase required:** copy `.env.example` → `.env` and add native config files before running. The app does not start without valid Firebase credentials.

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
- **Settings (gear)** — Opens the bottom sheet (board size, auth). The game pauses silently in the background.
- **Board sizes** — 8×8, 10×10 (default), or 12×12 via Settings. Choice is **persisted** across app restarts.

### Authentication & guest mode

| Scenario | Behaviour |
|----------|-----------|
| **iOS** | Google Sign-In required to play (no guest mode). |
| **Android** | Google Sign-In **or** **Play as guest** (guest is not persisted; sign-in required again after app restart). |

Guest mode is resolved at startup via `AppAccessConfig` (Android-only flag), not scattered `Platform` checks in UI code.

---

## Architecture

Melos monorepo: one **app shell** at the repo root plus **local packages** under `packages/`. Each package is a separate Dart/Flutter module with its own `pubspec.yaml` and tests where applicable.

```
sweeper/                          ← App shell (android/, ios/, lib/)
├── lib/
│   ├── main.dart                 ← Env load, Firebase bootstrap, DI, runApp
│   ├── app.dart                  ← MaterialApp, BlocProviders (cubits), theme, l10n
│   └── core/
│       ├── config/app_env.dart   ← `.env` → FirebaseOptions (gitignored secrets)
│       ├── firebase/             ← FirebaseBootstrap
│       ├── di/injection.dart     ← get_it (services/repos only — no cubits)
│       └── router/               ← go_router, AuthRedirect, AppPaths
├── packages/
│   ├── sweeper_theme/            ← Design tokens, AppTheme, shared widgets + SVG assets
│   ├── sweeper_l10n/             ← JSON translations + easy_localization loader
│   ├── sweeper_auth/             ← Firebase/Google auth, session, login UI
│   ├── sweeper_settings/         ← Board-size preferences (SettingsCubit)
│   └── sweeper_game/             ← Game domain, data, presentation
├── .env.example                  ← Committed template (copy to `.env`, gitignored)
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

State management: **Cubits** (`flutter_bloc`) — registered in the widget tree via `MultiBlocProvider` in `app.dart` (not in get_it). Navigation: **go_router** with typed paths in `AppPaths` (`lib/core/router`). DI: **get_it** for singleton services/repos only.

### Package dependency graph

```
sweeper (app)
  ├── sweeper_auth ──► sweeper_theme, sweeper_l10n
  ├── sweeper_game ──► sweeper_auth, sweeper_theme, sweeper_l10n, sweeper_settings
  ├── sweeper_settings (standalone cubit)
  ├── sweeper_theme
  └── sweeper_l10n

sweeper_game ──► sweeper_settings   (grid size → GameConfig.fromGridSize)
```

No circular dependencies: auth does not depend on game; settings does not depend on game (mapping lives in `GameConfig.fromGridSize`).

### Key design decisions

- **`GameEngine`** stays a single orchestrator (~200 lines) — all methods mutate one `GameSnapshot` and emit events. Board setup is extracted to `BoardInitializer`; grid cloning to `cell_grid_clone.dart`.
- **Theming** lives in `sweeper_theme` (Flip-inspired token system). Package assets (e.g. Google logo SVG) must be loaded with `package: 'sweeper_theme'`.
- **Live gameplay** uses the Binance WebSocket only (no REST API layer).

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
| Fancy animations | Discovery/timer explosions, valid-move slide, snap-back, magic-bomb pulse, game-over sequence |
| Social login | Google Sign-In via Firebase Auth (`sweeper_auth`) |
| Board size setting | `sweeper_settings` + Settings sheet (8×8, 10×10, 12×12) |
| Internationalization | `sweeper_l10n` + **easy_localization** — English, Portuguese, Spanish; **in-app language picker** in Settings (persisted) |

### Intentional notes

- **Google only** for social auth (PDF mentions social login; Apple/Facebook not implemented).
- **Guest mode** is an Android-only product extension for easier local testing; not in the PDF.
- **Magic bomb cap** — remaining hidden bombs cannot exceed the **initial** bomb count for the current board (silent ignore when at cap).

#### Magic bomb trigger (deliberate deviation from literal PDF wording)

The PDF says: *“Every moment the BTC price is divisible by 5.”* A literal reading would re-trigger on **every tick** while the integer price stays on a multiple of 5 (e.g. `$95,050` for many seconds), which can spam bombs even with a cap.

We instead fire when the **displayed whole-dollar price lands on** a value ending in **0** or **5** — i.e. the rounded UI price **changes** to a new divisible-by-5 integer (`BtcPrice.landedOnDivisibleWhole` in `packages/sweeper_game/lib/domain/entities/btc_price.dart`). Same feed and cap rules; one spawn per distinct landing, with dedupe via `lastMagicBombTriggerPrice`.

| PDF literal | This implementation |
|-------------|---------------------|
| Triggers on every tick while price ÷ 5 | Triggers once when whole dollars **land on** 0 or 5 |
| Can spam if price sits on e.g. $95,050 | Ignores repeated ticks at the same whole dollar |
| Jump from $95,049 → $95,051 skips $95,050 | No spawn (did not land on a divisible value) |

See `game_engine_test.dart` for landing, skip, cap, and dedupe cases.

---

## Dependencies (high level)

### App shell (`pubspec.yaml`)

| Package | Purpose |
|---------|---------|
| `firebase_core` | Firebase initialization |
| `flutter_dotenv` | Load `.env` at runtime (local dev secrets) |
| `flutter_bloc` | Cubit providers |
| `get_it` | Dependency injection (services/repos) |
| `go_router` | Declarative routing |
| Local `sweeper_*` packages | See modules above |

### Notable transitive / package deps

| Package | Module | Purpose |
|---------|--------|---------|
| `web_socket_channel` | `sweeper_game` | Binance WebSocket |
| `firebase_auth`, `google_sign_in` | `sweeper_auth` | Google Sign-In |
| `flutter_svg` | `sweeper_theme` | Google logo asset |
| `equatable` | game, auth, settings | Value equality |
| `easy_localization` | App + `sweeper_l10n` | `.tr()` strings, JSON translations |

---

## Development workflow (Melos)

All commands run from the **repo root**:

```bash
dart run melos bootstrap      # pub get + link path packages (run after clone or pubspec changes)
dart run melos analyze        # dart/flutter analyze in every package
dart run melos test             # flutter test in packages that have test/
dart run melos run format       # dart format all packages
```

Edit translation strings in `packages/sweeper_l10n/assets/translations/*.json`. Use `'key'.tr()` in widgets — no `AppLocalizations.of(context)` boilerplate. Stat labels and callouts apply casing via `AppText.labelCaps()` / `AppText.calloutCaps()` at display time, not in the JSON files.

**Single-package work** — you can also `cd packages/sweeper_game && flutter test`.

---

## Build & run by platform

### Android

```bash
flutter run -d android
# or
flutter build apk --debug
```

**Google Sign-In (debug):** add your machine’s **debug SHA-1** to the Firebase Android app. Download or copy `google-services.json` locally (see Firebase setup below). Other developers need their own SHA-1 registered or Sign-In will fail on their devices.

**Guest mode:** with Firebase configured, the login screen shows **Play as guest** on Android only.

### iOS

```bash
flutter run -d ios
# or open ios/Runner.xcworkspace in Xcode
```

Ensure `GoogleService-Info.plist` is in `ios/Runner/` (copy from `.example` or Firebase Console) and the URL scheme from Firebase is in `Info.plist`. Guest mode is **not** offered on iOS.

---

## Firebase & secrets

Firebase API keys and OAuth client IDs **must not** be committed in `.env`. Native Firebase config files are also **gitignored** so reviewers use their own Firebase project locally.

| File | In repo? | Purpose |
|------|----------|---------|
| `.env` | No (gitignored) | Flutter bootstrap via `flutter_dotenv` |
| `android/app/google-services.json` | No (gitignored) | Android Firebase SDK |
| `ios/Runner/GoogleService-Info.plist` | No (gitignored) | iOS Firebase SDK |
| `*.example` templates | Yes | Copy and fill from Firebase Console |

### Local development setup

1. `cp .env.example .env` — fill from Firebase Console or [`flutterfire configure`](https://firebase.google.com/docs/flutter/setup).
2. Copy native config templates and replace placeholders:
   ```bash
   cp android/app/google-services.json.example android/app/google-services.json
   cp ios/Runner/GoogleService-Info.plist.example ios/Runner/GoogleService-Info.plist
   ```
   Or download fresh files from [Firebase Console](https://console.firebase.google.com) → Project settings → Your apps.
3. Set `GOOGLE_SERVER_CLIENT_ID` in `.env` (OAuth 2.0 **Web** client ID from Firebase → Authentication → Google).
4. **Android Sign-In:** register your debug **SHA-1** in the Firebase Android app.

At runtime: `AppEnv.load()` → `FirebaseBootstrap.initialize()` builds `FirebaseOptions` from `.env`. Missing or invalid configuration fails at startup.

### Why native files are gitignored

This is a code-challenge repo meant to be cloned and run locally by reviewers with **their own** Firebase project. Keeping `google-services.json` and `GoogleService-Info.plist` out of git avoids tying the public repo to one Firebase project. The files are client-side config (not server secrets), but gitignoring them is still reasonable for reviewer flexibility.

### CI / production alternatives

| Approach | When to use |
|----------|-------------|
| **`.env` + flutter_dotenv** | Local dev (current default) |
| **`--dart-define-from-file=env.json`** | CI/CD — no dotenv asset; inject secrets from your pipeline |
| **Gitignored `firebase_options.dart`** | Firebase-native; run `flutterfire configure` per machine |

`lib/firebase_options.dart` is gitignored so it cannot be accidentally pushed. Prefer `.env` locally and `--dart-define-from-file` in CI if you want to avoid bundling env files in the app asset manifest.

---

## Firebase setup (Google Sign-In)

1. Create a project at [Firebase Console](https://console.firebase.google.com).
2. Register **Android** and **iOS** apps (bundle ID / application ID must match the project).
3. Copy templates → real files (or download from Console):
   - `android/app/google-services.json.example` → `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist.example` → `ios/Runner/GoogleService-Info.plist`
4. Add **SHA-1** (debug and release) for Android OAuth.
5. Copy Firebase app values into `.env` (see `.env.example`).
6. Add the iOS URL scheme from `REVERSED_CLIENT_ID` to `ios/Runner/Info.plist` if not already present.

---

## Binance WebSocket

- **Endpoint:** `wss://stream.binance.com:9443/ws`
- **Subscribe:** `btcusdt@ticker` (JSON SUBSCRIBE after connect)
- **DTO:** `BtcTickerDto` → `BtcPrice` (whole-dollar display uses `round()` for UI and magic-bomb logic)

---

## Testing

44 tests across the monorepo (game engine, cubit, settings, auth, routing, widgets):

```bash
dart run melos test
```

Game rule tests live in `packages/sweeper_game/test/` — especially `game_engine_test.dart` for magic-bomb landing logic and bomb cap behaviour.

