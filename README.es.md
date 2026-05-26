# Reversed Minesweeper

**Idiomas:** [English](README.md) · [Português](README.pt.md) · [Español](README.es.md)

Implementación en Flutter del desafío de código **Reversed Minesweeper**. Los jugadores reordenan piezas precolocadas en un tablero para descubrir bombas ocultas antes de que el temporizador las detone. Los precios de BTC en vivo de Binance pueden generar bombas mágicas cuando el valor en dólares enteros mostrado **aterriza** en un número que termina en **0** o **5**.

<p align="center">
  <img src="previews/img.png" alt="Pantalla de inicio de sesión" width="49%" />
  <img src="previews/img_1.png" alt="Gameplay con banner de bomba mágica" width="49%" />
</p>
<p align="center">
  <img src="previews/img_2.png" alt="Hoja de configuración" width="49%" />
  <img src="previews/img_3.png" alt="Pantalla de game over" width="49%" />
</p>

---

## Versiones de Flutter y Dart

| Herramienta | Versión |
|-------------|---------|
| **Dart SDK** (constraint) | `^3.10.4` |
| **Flutter** (probado) | `3.38.5` stable |
| **Melos** | `^6.3.0` (dev dependency en la raíz del repositorio) |

Usa Flutter 3.38.x o cualquier release que incluya Dart 3.10.4+. Si usas [FVM](https://fvm.app/), apunta a un canal stable compatible antes de ejecutar los comandos siguientes.

---

## Inicio rápido

Coloca los archivos de config gitignored en las rutas siguientes antes de ejecutar.

| Archivo | Ubicación |
|---------|-----------|
| `.env` | Raíz del repositorio (`sweeper/.env`) |
| `google-services.json` | `android/app/google-services.json` |
| `GoogleService-Info.plist` | `ios/Runner/GoogleService-Info.plist` |

```bash
# 1. Install Melos once (optional — also available via `dart run melos` at repo root)
dart pub global activate melos

# 2. Link local packages and run pub get everywhere
dart run melos bootstrap

# 3. Añade los archivos de config (ver tabla arriba)

# 4. Run on a device or simulator (Android / iOS only)
flutter run
```

**Plataformas:** solo **Android** e **iOS**.

**Se requiere internet** para el feed de BTC vía WebSocket de Binance.

La app no arranca hasta que `.env` y los archivos nativos de Firebase estén en su lugar.

---

## Cómo jugar

1. **Inicio** — El juego carga un tablero con bombas ocultas y piezas precolocadas.
2. **Arrastrar piezas** — Mueve piezas entre celdas vacías. Soltar en celdas ocupadas hace que la pieza vuelva.
3. **Descubrir bombas** — Al caer en una bomba oculta, se revela y aumenta el contador de descubiertas.
4. **Temporizador** — Cada **10 segundos**, una bomba oculta aleatoria detona automáticamente.
5. **Bombas mágicas** — Cuando el precio de BTC en vivo (dólares enteros, redondeado en la UI) **aterriza** en un valor que termina en **0** o **5**, puede aparecer una nueva bomba oculta (limitada al número inicial de bombas de ese tamaño de tablero).
6. **Victoria / game over** — Cuando todas las bombas estén descubiertas o detonadas, irás a la pantalla de game over con tu recuento de bombas descubiertas.

### Pausa y configuración

- **Botón de pausa** — Pausa el juego y muestra el overlay de pausa.
- **Configuración (engranaje)** — Abre la hoja inferior (tamaño del tablero, autenticación). El juego se pausa silenciosamente en segundo plano.
- **Tamaños del tablero** — 8×8, 10×10 (predeterminado) o 12×12 en Configuración. La elección se **persiste** entre reinicios de la app.

### Autenticación y modo invitado

| Escenario | Comportamiento |
|-----------|----------------|
| **iOS** | Google Sign-In obligatorio para jugar (sin modo invitado). |
| **Android** | Google Sign-In **o** **Jugar como invitado** (sin cuenta). |

El modo invitado se resuelve al iniciar mediante `AppAccessConfig` (flag exclusiva de Android).

---

## Arquitectura

Monorepo Melos: un **app shell** en la raíz del repositorio más **paquetes locales** en `packages/`. Cada paquete es un módulo Dart/Flutter separado con su propio `pubspec.yaml` y tests cuando corresponda.

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

### Capas (paquetes de feature)

Los módulos de feature (`sweeper_auth`, `sweeper_settings`, `sweeper_game`) comparten el mismo diseño de **clean architecture**. Los paquetes de infraestructura (`sweeper_theme`, `sweeper_l10n`) son utilidades compartidas sin esta división; el **app shell** solo arranca la app (env, Firebase, DI, enrutamiento).

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

| Capa | Responsabilidad | Ejemplos (entre paquetes) |
|------|-----------------|---------------------------|
| **Domain** | Reglas de negocio, modelos, interfaces de repositorio — **sin I/O** | `GameEngine`, `UserSettings`, `AuthUser`, `AuthRepository`, `SettingsRepository` |
| **Data** | Habla con el mundo exterior; mapea DTOs → tipos de dominio | `FirebaseAuthDataSource`, `SharedPreferencesSettingsDataSource`, `BinanceWebSocket`, `*RepositoryImpl` |
| **Presentation** | Widgets + Cubits; impulsa la UI desde domain/data | `GameCubit` / `GamePage`, `AuthCubit` / `LoginPage`, `SettingsCubit` / `SettingsSheet` |

Regla de dependencia: **presentation → domain ← data**. Presentation nunca importa datasources directamente; el app shell registra implementaciones concretas en `get_it` (`lib/core/di/injection.dart`).

Código transversal queda junto a las tres carpetas cuando cruza features — p. ej. `sweeper_auth/session/` (ciclo de vida invitado/login) y `config/` (flags de acceso por plataforma).

Gestión de estado: **Cubits** (`flutter_bloc`) — registrados en el árbol de widgets vía `MultiBlocProvider` en `app.dart`. Navegación: **go_router** con rutas tipadas en `AppPaths` (`lib/core/router`). DI: **get_it** para services/repos singleton.

---

## Dependencias (visión general)

### App shell (`pubspec.yaml`)

| Paquete | Propósito |
|---------|-----------|
| `firebase_core` | Inicialización de Firebase |
| `flutter_dotenv` | Carga `.env` en runtime |
| `flutter_bloc` | Proveedores de Cubit |
| `get_it` | Inyección de dependencias (services/repos) |
| `go_router` | Enrutamiento declarativo |
| Paquetes locales `sweeper_*` | Ver módulos arriba |

### Dependencias transitivas / por paquete

| Paquete | Módulo | Propósito |
|---------|--------|-----------|
| `web_socket_channel` | `sweeper_game` | WebSocket de Binance |
| `firebase_auth`, `google_sign_in` | `sweeper_auth` | Google Sign-In |
| `flutter_svg` | `sweeper_theme` | Asset del logo de Google |
| `equatable` | game, auth, settings | Igualdad de valores |
| `easy_localization` | App + `sweeper_l10n` | Strings `.tr()`, traducciones JSON |

---

## Flujo de desarrollo (Melos)

Todos los comandos se ejecutan desde la **raíz del repositorio**:

```bash
dart run melos bootstrap      # pub get + link path packages (run after clone or pubspec changes)
dart run melos analyze        # dart/flutter analyze in every package
dart run melos test             # flutter test in packages that have test/
dart run melos run format       # dart format all packages
```

---

## Pruebas

**119 tests** (unit/widget) en el monorepo — game engine, cubits, settings, auth, enrutamiento y widgets.

```bash
dart run melos test
```

### Cobertura

| Ámbito | Líneas |
| --- | --- |
| **General** (todo `lib/` bajo test) | **87,3%** (751/860) |
| **Lógica central** (domain, data, cubits, session) | **97,7%** (589/603) |

Medido fusionando `coverage/lcov.info` de cada paquete con tests (app shell, `sweeper_auth`, `sweeper_game`, `sweeper_settings`, `sweeper_theme`).

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
