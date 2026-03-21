# 🌿 WildQuest — Juego RPG de Animales

RPG educativo para niños. Explora la selva, encuentra animales, aprende sobre ellos y completa minijuegos.
Construido con **Flutter + Bonfire 3.16.1 (Flame 1.32)**

---

## 📁 Estructura del proyecto

```
wildquest_game/
├── pubspec.yaml
└── lib/
    ├── main.dart                          ← Entry point, landscape mode
    │
    ├── router/
    │   └── app_router.dart                ← Rutas nombradas
    │
    ├── theme/
    │   └── app_theme.dart                 ← AppColors, estilos
    │
    ├── data/
    │   ├── animal_data.dart               ← 6 animales con datos y tipo de minijuego
    │   └── game_state.dart                ← Estado global (singleton)
    │
    ├── screens/
    │   ├── loading_screen.dart            ← Pantalla de carga
    │   ├── main_menu_screen.dart          ← Menú principal landscape
    │   ├── game_screen.dart               ← BonfireWidget — mapa + jugador + NPCs
    │   ├── collection_screen.dart         ← Pokédex de animales descubiertos
    │   └── minigame_screen.dart           ← Router de minijuegos
    │
    ├── game/
    │   ├── map/
    │   │   └── jungle_map_builder.dart    ← Mapa procedural 40×30 tiles
    │   │
    │   ├── actors/
    │   │   ├── player_character.dart      ← SimplePlayer con joystick/teclado
    │   │   └── animal_npc.dart            ← NPC animal con sensor de proximidad
    │   │
    │   ├── objects/
    │   │   └── collectible_item.dart      ← Objetos recogibles (cofre, gema, etc.)
    │   │
    │   ├── overlays/
    │   │   ├── hud_overlay.dart           ← HUD: monedas, score, animales
    │   │   └── encounter_overlay.dart     ← Panel de encuentro con animal
    │   │
    │   └── minigames/
    │       ├── memory_card_game.dart      ← 🦉 Búho: parejas de cartas
    │       ├── silhouette_game.dart       ← 🦊 Zorro: adivina la silueta
    │       ├── trivia_game.dart           ← 🦌 Ciervo: verdadero/falso
    │       ├── color_match_game.dart      ← 🦋 Mariposa: pinta el animal
    │       ├── puzzle_game.dart           ← 🐻 Oso: ordena las piezas
    │       └── sound_match_game.dart      ← 🐸 Rana: empareja sonidos
    │
    └── assets/
        ├── images/
        │   ├── player/    ← player_walk.png (spritesheet 4 frames, 16×16 cada uno)
        │   ├── animals/   ← placeholder.png (16×16)
        │   ├── tiles/     ← tree.png, water.png (16×16)
        │   └── items/     ← (opcional)
        └── fonts/
```

---

## 🐾 Los 6 animales

| Animal | Emoji | Minijuego | Habitat |
|---|---|---|---|
| Zorro Rojo     | 🦊 | Adivina la silueta    | Bosque           |
| Ciervo         | 🦌 | Verdadero o Falso     | Pradera / Bosque |
| Búho Real      | 🦉 | Cartas de memoria     | Bosque nocturno  |
| Mariposa Monarca| 🦋 | Pinta el animal      | Prado / Jardín   |
| Oso Pardo      | 🐻 | Ordena el puzzle     | Montaña / Bosque |
| Rana Venenosa  | 🐸 | Empareja sonidos     | Río / Charca     |

---

## 🗺️ Flujo del juego

```
LoadingScreen
     ↓
MainMenuScreen ──→ CollectionScreen (Pokédex)
     ↓
GameScreen (BonfireWidget)
   ├── Joystick / WASD para mover al jugador
   ├── Colisión con AnimalNPC → EncounterOverlay
   │      └── Botón "Jugar minijuego" → MinigameScreen
   │              └── Resultado → volver al mapa
   └── Recoger CollectibleItems → +monedas +puntos
```

---

## 🚀 Setup

```bash
# 1. Instalar dependencias
flutter pub get

# 2. Assets — por ahora el juego usa emojis como placeholders.
#    Para producción: añadir spritesheets en assets/images/

# 3. Ejecutar
flutter run

# 4. Android: deshabilitar Impeller en AndroidManifest.xml:
#    <meta-data android:name="io.flutter.embedding.android.EnableImpeller" android:value="false"/>

# 5. Web
flutter build web --web-renderer=canvaskit
```

---

## 🎮 Controles

| Plataforma | Movimiento |
|---|---|
| Móvil    | Joystick virtual (abajo izquierda) |
| Desktop  | WASD o flechas                     |

---

## 📦 Dependencias clave

```yaml
bonfire: ^3.16.1    # Motor RPG sobre Flame
flame: ^1.32.0      # Motor 2D base
```

---

## 🔮 Próximas mejoras

- [ ] Spritesheets reales (jugador y animales animados)  
- [ ] Mapa Tiled (.tmx) con decoraciones detalladas  
- [ ] Tienda de objetos  
- [ ] Sistema de misiones  
- [ ] Efectos de sonido y música  
- [ ] Guardado con `shared_preferences`  
- [ ] Más mapas: Sabana, Océano, Ártico  
