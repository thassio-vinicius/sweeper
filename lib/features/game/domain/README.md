# Game Domain Layer

Pure Dart game rules — no Flutter imports.

## GameEngine API

| Method | Description |
|--------|-------------|
| `initialize()` | Places hidden bombs and pre-placed pieces on non-bomb cells |
| `movePiece(from, to)` | Rearranges a piece; discovers bomb if hidden under target |
| `onTimerTick()` | Explodes one random hidden bomb |
| `onBtcPriceUpdate(price)` | Adds magic bomb when integer price % 5 == 0 |
| `updateCountdown(seconds)` | Updates next-blast countdown display |
| `restart(config?)` | Re-initializes with optional new config |

## Events

- `BombDiscoveredEvent(row, col)`
- `BombExplodedEvent(row, col)`
- `MagicBombAddedEvent(row, col, triggerPrice)`
- `InvalidMoveEvent()`
- `GameOverEvent(discoveredCount)`
