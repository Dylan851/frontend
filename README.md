# 🌿 AnimalGO — RPG Educativo de Animales

Flutter + Bonfire 3.16 · Landscape · Tiled JSON maps

---

## 🚀 Cómo ejecutar

```bash
flutter pub get
flutter run
```

### Android — deshabilitar Impeller
En `android/app/src/main/AndroidManifest.xml`, dentro de `<application>`:
```xml
<meta-data
  android:name="io.flutter.embedding.android.EnableImpeller"
  android:value="false"/>
```

### Web
```bash
flutter build web --web-renderer=canvaskit
```

---

## 🗂️ Estructura del proyecto

```
animalgo_game/
├── assets/
│   ├── images/
│   │   ├── player/
│   │   │   ├── hero.png          ← spritesheet 96×128 (4 dirs × 6 frames)
│   │   │   ├── hero_down.png     ← strip 96×32 (6 frames mirando abajo)
│   │   │   ├── hero_left.png     ← strip 96×32
│   │   │   ├── hero_right.png    ← strip 96×32
│   │   │   └── hero_up.png       ← strip 96×32
│   │   └── tiles/
│   │       ├── tileset_terrain.png  ← 512×512, 32×32 tiles de 16px
│   │       └── tileset_objects.png  ← 512×512, objetos/decoraciones
│   └── maps/
│       ├── jungle.json           ← Mapa Selva Amazónica 40×25
│       ├── savanna.json          ← Mapa Sabana Africana 40×25
│       ├── tileset_terrain.tsx   ← Referencia Tiled Editor
│       └── tileset_objects.tsx
│
└── lib/
    ├── main.dart
    ├── router/app_router.dart
    ├── theme/app_theme.dart          ← AppColors, GlassBox, CurrencyChip, BackBtn
    ├── data/
    │   ├── animal_data.dart          ← 6 animales + MinigameType (incl. taming)
    │   ├── game_state.dart           ← Singleton global (inventario, coins, nivel)
    │   └── item_data.dart            ← ShopCatalog, MapCatalog
    ├── screens/
    │   ├── loading_screen.dart       ← Pantalla de carga con luciérnagas
    │   ├── main_menu_screen.dart     ← Menú principal landscape
    │   ├── game_screen.dart          ← BonfireWidget + mapa Tiled + joystick
    │   ├── map_select_screen.dart    ← 8 mundos (2 desbloqueados)
    │   ├── shop_screen.dart          ← Tienda 4 tabs (comida/equipo/especial/skins)
    │   ├── inventory_screen.dart     ← Mochila + equip slots + stats
    │   ├── collection_screen.dart    ← Pokédex animales
    │   ├── profile_screen.dart       ← Perfil + logros + selector skin
    │   ├── settings_screen.dart      ← Ajustes con toggles reales
    │   └── minigame_screen.dart      ← Router de minijuegos
    └── game/
        ├── actors/
        │   ├── player_character.dart ← Héroe azul con spritesheet real
        │   └── animal_npc.dart       ← NPC con sensor + burbuja ! + overlay
        ├── map/
        │   └── jungle_map_builder.dart  ← (legacy, usar WorldMapByFile)
        ├── objects/
        │   └── collectible_item.dart ← Ítems flotantes recogibles
        ├── overlays/
        │   ├── hud_overlay.dart      ← HUD in-game
        │   └── encounter_overlay.dart← Panel de encuentro con animal
        └── minigames/
            ├── taming_game.dart      ← 🆕 Paddle domesticación (3 fases)
            ├── memory_card_game.dart ← Parejas de cartas (Búho)
            ├── silhouette_game.dart  ← Adivina la silueta (Zorro)
            ├── trivia_game.dart      ← Verdadero/Falso (Ciervo)
            ├── color_match_game.dart ← Pinta el animal (Mariposa)
            ├── puzzle_game.dart      ← Ordena piezas (Oso)
            └── sound_match_game.dart ← Empareja sonidos (Rana)
```

---

## 🗺️ Mapas Tiled

### Format
JSON estándar de Tiled con 3 capas:

| Capa | Propósito |
|------|-----------|
| `ground` | Terreno base (hierba, tierra, agua, piedra) |
| `objects` | Decoraciones (árboles, arbustos, cofres, fogatas) |
| `collision` | Celdas bloqueantes (invisible en juego) |

### Tilesets
- **tileset_terrain.png** — firstGID=1 (GID=row×32+col+1)
- **tileset_objects.png** — firstGID=1025

### Posición del jugador
Definida en `properties` del JSON:
```json
{ "name": "playerStartX", "value": 10 },
{ "name": "playerStartY", "value": 13 }
```
En `game_screen.dart` se usa `GameState().savedX/savedY` (defecto 5,5).

---

## 🐾 Animales y dónde encontrarlos

| Animal | Emoji | Tile (col, row) | Minijuego |
|--------|-------|-----------------|-----------|
| Zorro Rojo | 🦊 | (10, 10) | 🏓 Paddle domesticación |
| Búho Real  | 🦉 | (30, 4)  | 🃏 Parejas de cartas |
| Ciervo     | 🦌 | (22, 16) | ❓ Verdadero/Falso |
| Mariposa   | 🦋 | (14, 20) | 🎨 Colorea el animal |
| Oso Pardo  | 🐻 | (34, 19) | 🧩 Puzzle de piezas |
| Rana       | 🐸 | (24, 8)  | 🎵 Empareja sonidos |

---

## 🎮 Controles

| Plataforma | Movimiento | Interactuar |
|------------|-----------|-------------|
| Móvil | Joystick virtual (abajo izq.) | Botón verde (abajo der.) |
| Desktop/Web | WASD o flechas | — |

El jugador activa automáticamente el encuentro con el animal al acercarse (sensor de proximidad).

---

## 🎨 Spritesheet del héroe

Extraído del tileset2, el héroe azul tiene:
- **6 frames** por dirección  
- **4 direcciones**: down, left, right, up  
- Cada frame: **16×32 px**  
- Strips individuales: `hero_<dir>.png` (96×32 cada uno)

```
hero_down.png:  [f0][f1][f2][f3][f4][f5]   ← camina hacia abajo
hero_left.png:  [f0][f1][f2][f3][f4][f5]   ← camina a la izquierda
hero_right.png: [f0][f1][f2][f3][f4][f5]   ← camina a la derecha
hero_up.png:    [f0][f1][f2][f3][f4][f5]   ← camina hacia arriba
```

---

## 📦 Dependencias

```yaml
bonfire: ^3.16.1   # Motor RPG sobre Flame
flame: ^1.32.0     # Motor 2D base
shared_preferences: ^2.2.2
```
