# Tests de AnimalGO! (frontend Flutter)

Esta carpeta contiene la batería de **tests unitarios** y **tests de widgets**
del cliente Flutter. Se ha priorizado cubrir la **lógica de juego pura** (sin
dependencias de red, motor gráfico ni plataforma) y los **componentes
visuales reutilizables** del tema.

## 1. Cómo ejecutar

Desde la carpeta `frontend/`:

```bash
# Todos los tests
flutter test

# Una suite concreta
flutter test test/data/game_state_test.dart

# Con cobertura (genera coverage/lcov.info)
flutter test --coverage
```

Para visualizar la cobertura:

```bash
# Linux/macOS
genhtml coverage/lcov.info -o coverage/html
# Windows (PowerShell)
flutter pub global activate coverage
flutter pub global run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info
```

## 2. Estructura

```
test/
├── widget_test.dart              # Smoke test del binding y singleton GameState
├── config/
│   └── api_config_test.dart      # Endpoints y helpers de ApiConfig
├── data/
│   ├── animal_data_test.dart     # Catálogo de animales y AnimalData
│   ├── item_data_test.dart       # Catálogo de la tienda y flags de items
│   ├── mission_data_test.dart    # Misiones, progreso y reclamación
│   ├── food_atlas_test.dart      # Atlas de comida (sprite-sheet)
│   └── game_state_test.dart      # Estado central: progreso, economía, buffs
└── widgets/
    └── theme_widgets_test.dart   # Componentes visuales del tema (theme/)
```

## 3. Cobertura por módulo

| Suite | Foco | Nº tests aprox. |
|---|---|---|
| `animal_data_test.dart` | Integridad del catálogo (legacy + basicPack), `copyWith`, `findById` | 11 |
| `item_data_test.dart` | `byCategory`, `findById`, `isMinigamePowerUp`, `isUsableFromBag`, `lootPool` | 9 |
| `mission_data_test.dart` | `Mission.progress`, `isComplete`, `isClaimable`, `pct`, `MissionCatalog.byId` | 10 |
| `food_atlas_test.dart` | `cellFor`, `assetPath`, `cellSize` | 4 |
| `game_state_test.dart` | descubrir animales, completar minijuegos, buffs, inventario, tienda, cofres, misiones, reset | 19 |
| `api_config_test.dart` | endpoints estáticos, builders por id, `getFullUrl`, `isLocalhost` | 8 |
| `theme_widgets_test.dart` | `CurrencyChip`, `BackBtn`, `GlassBox`, `WoodPanel`, `CornerRibbon`, `ChunkyButton`, `PixelFrame`, `OvalGoldChip`, `MenuPill` | 14 |
| `widget_test.dart` | Smoke test del binding | 1 |
| **Total** | — | **≈ 76 casos** |

## 4. Convenciones

- Cada test es **independiente**: el `setUp` de `game_state_test.dart` y
  `mission_data_test.dart` resetea el singleton `GameState` y vacía
  `SharedPreferences` con `setMockInitialValues({})`.
- Los tests **no salen a red**, **no abren ficheros del sistema** y **no
  arrancan motores gráficos**: por eso se evita instanciar pantallas que
  dependan de `bonfire`/`flame`/`flutter_3d_controller` o servicios externos
  (Stripe, Supabase).
- Los widget tests envuelven el componente probado en un `MaterialApp`
  mínimo (`_wrap()`), nunca en `AnimalGoApp`, para no arrastrar el árbol de
  rutas completo ni `google_fonts`.

## 5. Detalle de las suites

### 5.1 `animal_data_test.dart`
- Verifica que `AnimalCatalog.all` tiene **6 animales legacy** y
  `AnimalCatalog.basicPack` **15 del asset pack**, todos con id único.
- Cada animal del basicPack tiene `spriteAsset` (`.png`), `sound` y
  `wikiFact` no vacíos.
- `findById` busca primero en `all` y luego en `basicPack`, y devuelve
  `null` si no encuentra el id.
- `copyWith` produce una copia con el flag `isDiscovered` actualizado y
  **no muta** el original.

### 5.2 `item_data_test.dart`
- `isMinigamePowerUp` devuelve `true` exactamente para los efectos
  `luckyCharm`, `coinDoubler`, `xpBoost`, `goldenPass`, `reviveScroll`,
  `timeExtender`, `hintReveal`.
- `isUsableFromBag` cubre comida, equipo activo (`speedBoost`,
  `radarAnimals`) y power-ups; las skins quedan fuera.
- `byCategory` y `findById` devuelven los listados/ítems esperados.
- Comprueba que **todos los ids del catálogo son únicos** y los precios
  positivos.
- `lootPool` incluye toda la comida y excluye los power-ups en gemas.

### 5.3 `mission_data_test.dart`
- Cada `MissionGoal` lee del campo correcto del `GameState`
  (`discoveredAnimals`, `completedMinigames`, `level`, `coinsEarnedTotal`…).
- `pct` queda acotado en `[0.0, 1.0]` y devuelve `0.0` si el target es 0.
- `isClaimable` solo es cierto cuando la misión está completa **y no se
  ha reclamado**.
- `MissionCatalog.byId` devuelve la misión correcta o `null`.

### 5.4 `food_atlas_test.dart`
- Garantiza que `cellFor` devuelve coordenadas no negativas para items
  conocidos (`apple`) y `null` para ids desconocidos.

### 5.5 `game_state_test.dart`
La suite más extensa. Cubre:
- **Animales**: `discoverAnimal` da +100 score / +5 coins, es idempotente,
  y `discoveredCount` está acotado por el catálogo.
- **Minijuegos**: 3★ otorgan monedas/XP y descubren al animal; 1★ no.
- **Buffs**: `luckyCharm` añade +1 estrella, `coinDoubler` duplica las
  monedas; `activatePowerUp` consume del inventario, falla sin stock o
  con items no aptos; `clearPendingEffects` vacía la lista.
- **Inventario / tienda**: `buyItem` exige fondos, `useItem` decrementa y
  borra al llegar a 0, `addItem` acumula, `sellItem` por monedas devuelve
  el 50 % del precio, `collectMapItem` es idempotente por id.
- **Misiones**: `claimMission` aplica recompensa una sola vez.
- **Cofres**: `openChest` da recompensa la primera vez y nada en sucesivas.
- **Reset**: vuelve `coins` a 0, `level` a 1 y limpia los sets.

### 5.6 `api_config_test.dart`
- Verifica el valor de los endpoints fijos (`/health`, `/auth/login`, …).
- Comprueba los builders parametrizados (`playerEndpoint`,
  `animalEndpoint`, `mapEndpoint`, …).
- Confirma `getFullUrl` y la heurística `isLocalhost`.
- Los timeouts (`connectionTimeout`, `responseTimeout`) son positivos.

### 5.7 `theme_widgets_test.dart`
Widget tests para el sistema de diseño de la app:
- **`CurrencyChip`** muestra icono y valor; admite `accent`.
- **`BackBtn`** muestra `arrow_back_ios_new_rounded` y dispara `onTap`.
- **`GlassBox`** y **`WoodPanel`** renderizan el `child` (incl. variante
  `parchment` con `emerald: false`).
- **`CornerRibbon`** muestra el label.
- **`ChunkyButton`** muestra label, dispara `onTap` y soporta icono
  opcional.
- **`PixelFrame`** renderiza el child dentro del marco pixelado.
- **`OvalGoldChip`** muestra icono/valor; el botón `+` aparece solo si se
  pasa `onPlusTap` y es pulsable.
- **`MenuPill`** muestra icono y label y dispara `onTap`.

## 6. Qué **no** se cubre aquí (y por qué)

| Área | Motivo |
|---|---|
| `screens/game_screen.dart`, mapas, minijuegos | dependen de `bonfire`/`flame` y de assets físicos; requieren tests de integración con motor real |
| `services/api_service.dart`, `auth_service.dart`, `stripe_payment_service.dart` | hablan con red/Stripe/Supabase; necesitan mocks HTTP (Dio interceptors) o entorno e2e |
| `screens/animal_3d_viewer.dart` | depende de `flutter_3d_controller` y de `path_provider` con plataforma nativa |
| Persistencia real (`load`/`save`) | se ejerce indirectamente vía `setUp` con `SharedPreferences.setMockInitialValues`; verificación end-to-end queda para tests de integración |

Estas áreas se recomienda cubrirlas con **`integration_test`** ejecutado en
emulador/dispositivo real, fuera del alcance de los tests unitarios.

## 7. Añadir nuevos tests

1. Crea el archivo bajo la subcarpeta adecuada (`data/`, `widgets/`,
   `config/`).
2. Si tu test toca `GameState`, copia el `setUp` de
   `game_state_test.dart` (binding + `setMockInitialValues({})` +
   `reset()`).
3. Para widgets, envuélvelos en el helper `_wrap(...)` definido en
   `theme_widgets_test.dart` o equivalente; **no uses `AnimalGoApp`**
   directamente para no arrastrar `google_fonts` ni el router completo.
4. Ejecuta `flutter test` y, si añades cobertura crítica, actualiza la
   tabla de la sección 3.
