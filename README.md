# Reversed Minesweeper

**Languages:** [English](README.md) · [Português](README.pt.md) · [Español](README.es.md)

A Flutter implementation of the **Reversed Minesweeper** code challenge. Players rearrange pre-placed pieces on a grid to discover hidden bombs before the timer explodes them. Live BTC prices from Binance can spawn magic bombs when the displayed whole-dollar price lands on a value ending in **0** or **5**.

<p align="center">
  <img src="previews/img.png" alt="Login screen" width="49%" />
  <img src="previews/img_1.png" alt="Gameplay with magic bomb banner" width="49%" />
</p>
<p align="center">
  <img src="previews/img_2.png" alt="Settings sheet" width="49%" />
  <img src="previews/img_3.png" alt="Game over screen" width="49%" />
</p>

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

Place the gitignored config files in the paths below before running.

| File | Location |
|------|----------|
| `.env` | Repository root (`sweeper/.env`) |
| `google-services.json` | `android/app/google-services.json` |
| `GoogleService-Info.plist` | `ios/Runner/GoogleService-Info.plist` |

```bash
# 1. Install Melos once (optional — also available via `dart run melos` at repo root)
dart pub global activate melos

# 2. Link local packages and run pub get everywhere
dart run melos bootstrap

# 3. Add the config files (see table above)

# 4. Run on a device or simulator (Android / iOS only)
flutter run
```

**Platform targets:** **Android** and **iOS** only.

**Internet required** for the Binance WebSocket BTC feed.

The app will not start until `.env` and the native Firebase files are in place.

---

## How to play

1. **Start** — The game loads a board with hidden bombs and pre-placed pieces.
2. **Drag pieces** — Move pieces between empty cells. Drops on occupied cells bounce back.
3. **Discover bombs** — Landing on a hidden bomb reveals it and increments the discovered counter.
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
| **Android** | Google Sign-In **or** **Play as guest** to avoid having to register your debug SHA-1 fingerprint certificate manually in Firebase. |

Guest mode is resolved at startup via `AppAccessConfig` (Android-only flag).

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
│       ├── di/injection.dart     ← get_it (services/repos)
│       └── router/               ← go_router, AuthRedirect, AppPaths
├── packages/
│   ├── sweeper_theme/            ← Design tokens, AppTheme, shared widgets + SVG assets
│   ├── sweeper_l10n/             ← JSON translations + easy_localization loader
│   ├── sweeper_auth/             ← Firebase/Google auth, session, login UI
│   ├── sweeper_settings/         ← Preferences (domain, data, presentation)
│   └── sweeper_game/             ← Game domain, data, presentation
├── .env                          ← Gitignored
├── melos.yaml
└── pubspec.yaml
```

### Layering (feature packages)

Feature modules (`sweeper_auth`, `sweeper_settings`, `sweeper_game`) share the same **clean architecture** layout. Infrastructure packages (`sweeper_theme`, `sweeper_l10n`) are shared utilities without this split; the **app shell** only bootstraps the app (env, Firebase, DI, routing).

```
packages/<feature>/lib/
├── domain/
│   ├── entities/           # Value types — no Flutter imports
│   ├── repositories/       # Abstract contracts
│   └── services/           # Pure logic orchestrators (where needed)
├── data/
│   ├── datasources/        # Firebase, SharedPreferences, WebSocket, …
│   ├── dtos/               # Wire / JSON shapes (where needed)
│   └── repositories/       # Implements domain contracts
└── presentation/
    ├── cubit/              # UI state
    ├── pages/              # Full screens
    └── widgets/            # Composable UI
```

| Layer | Responsibility | Examples (across packages) |
|-------|----------------|----------------------------|
| **Domain** | Business rules, models, repository interfaces — **no I/O** | `GameEngine`, `UserSettings`, `AuthUser`, `AuthRepository`, `SettingsRepository` |
| **Data** | Talks to the outside world; maps DTOs → domain types | `FirebaseAuthDataSource`, `SharedPreferencesSettingsDataSource`, `BinanceWebSocket`, `*RepositoryImpl` |
| **Presentation** | Widgets + Cubits; drives UI from domain/data | `GameCubit` / `GamePage`, `AuthCubit` / `LoginPage`, `SettingsCubit` / `SettingsSheet` |

Dependency rule: **presentation → domain ← data**. Presentation never imports datasources directly; the app shell registers concrete implementations in `get_it` (`lib/core/di/injection.dart`).

Some cross-cutting code sits beside the three folders when it spans features — e.g. `sweeper_auth/session/` (guest/sign-in lifecycle) and `config/` (platform access flags).

State management: **Cubits** (`flutter_bloc`) — registered in the widget tree via `MultiBlocProvider` in `app.dart`. Navigation: **go_router** with typed paths in `AppPaths` (`lib/core/router`). DI: **get_it** for singleton services/repos.

---

## Dependencies (high level)

### App shell (`pubspec.yaml`)

| Package | Purpose |
|---------|---------|
| `firebase_core` | Firebase initialization |
| `flutter_dotenv` | Load `.env` at runtime |
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

---

## Testing

**119 tests** (unit/widget) across the monorepo — game engine, cubits, settings, auth, routing, and widgets.

```bash
dart run melos test
```

### Coverage

| Scope | Lines |
| --- | --- |
| **Overall** (all `lib/` under test) | **87.3%** (751/860) |
| **Core logic** (domain, data, cubits, session) | **97.7%** (589/603) |

Measured by merging `coverage/lcov.info` from every package that has tests (app shell, `sweeper_auth`, `sweeper_game`, `sweeper_settings`, `sweeper_theme`).

```bash
dart run melos exec --dir-exists=test -- flutter test --coverage
# then merge the five lcov files (requires lcov):
lcov --add-tracefile coverage/lcov.info \
     --add-tracefile packages/sweeper_auth/coverage/lcov.info \
     --add-tracefile packages/sweeper_game/coverage/lcov.info \
     --add-tracefile packages/sweeper_settings/coverage/lcov.info \
     --add-tracefile packages/sweeper_theme/coverage/lcov.info \
     --output-file coverage/merged.info
lcov --summary coverage/merged.info
```
