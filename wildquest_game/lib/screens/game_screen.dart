// lib/screens/game_screen.dart
// Pantalla principal del juego usando BonfireWidget

import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import '../game/actors/player_character.dart';
import '../game/actors/animal_npc.dart';
import '../game/map/jungle_map_builder.dart';
import '../game/objects/collectible_item.dart';
import '../game/overlays/hud_overlay.dart';
import '../game/overlays/encounter_overlay.dart';
import '../data/animal_data.dart';
import '../data/game_state.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  AnimalData? currentAnimal;

  /// Posiciones fijas de cada animal en el mapa (col, row)
  static const _animalPositions = {
    'fox':       (8,  5),
    'owl':       (30, 4),
    'deer':      (20, 12),
    'butterfly': (12, 20),
    'bear':      (33, 18),
    'frog':      (22, 9),
  };

  /// Posiciones de ítems recogibles
  static const _itemPositions = [
    (6,  10, ItemType.chest),
    (15, 6,  ItemType.gem),
    (28, 14, ItemType.mushroom),
    (10, 24, ItemType.star),
    (35, 22, ItemType.leaf),
    (18, 17, ItemType.berry),
    (25, 25, ItemType.chest),
    (5,  18, ItemType.gem),
  ];

  static const double _tile = JungleMapBuilder.tileSize;

  @override
  Widget build(BuildContext context) {
    return BonfireWidget(
      map: JungleMapBuilder.build(),

      // Jugador
      player: PlayerCharacter(
        position: Vector2(5 * _tile, 5 * _tile),
      ),

      // Animales NPC
      components: [
        ..._buildAnimals(),
        ..._buildItems(),
      ],

      // Cámara suavizada
      cameraConfig: CameraConfig(
        smoothCameraEnabled: true,
        smoothCameraSpeed: 2.0,
        zoom: 2.0,
      ),

      // Joystick para móvil + botón de interacción
      joystick: Joystick(
        directional: JoystickDirectional(
          size: 80,
          color: Colors.white.withOpacity(0.3),
          margin: const EdgeInsets.only(left: 20, bottom: 20),
        ),
        actions: [
          JoystickAction(
            actionId: 1,
            size: 50,
            color: AppColors.greenAccent.withOpacity(0.6),
            margin: const EdgeInsets.only(right: 20, bottom: 20),
            sprite: null,
          ),
        ],
      ),

      // Overlays de Flutter sobre el juego
      overlayBuilderMap: {
        HudOverlay.id: (ctx, game) => const HudOverlay(),
        EncounterOverlay.id: (ctx, game) {
          final animal = (game as dynamic).currentAnimal as AnimalData?;
          if (animal == null) return const SizedBox.shrink();
          return EncounterOverlay(
            animal: animal,
            onClose: () => game.overlays.remove(EncounterOverlay.id),
          );
        },
      },

      initialActiveOverlays: const [HudOverlay.id],

      // Fondo del mundo
      backgroundColor: const Color(0xFF1A5C30),

      // Input de teclado (desktop/web)
      keyboardConfig: KeyboardConfig(
        enableDiagonalInput: true,
        keyboardDirectionalType: KeyboardDirectionalType.wasdAndArrows,
      ),

      // Iluminación ambiental
      lightingColorGame: const Color(0x33000000),
    );
  }

  List<AnimalNpc> _buildAnimals() {
    return AnimalCatalog.all.map((animal) {
      final pos = _animalPositions[animal.id];
      if (pos == null) return null;
      return AnimalNpc(
        position: Vector2(pos.$1 * _tile, pos.$2 * _tile),
        animalData: animal,
      );
    }).whereType<AnimalNpc>().toList();
  }

  List<CollectibleItem> _buildItems() {
    return _itemPositions.asMap().entries.map((e) {
      final idx = e.key;
      final item = e.value;
      return CollectibleItem(
        position: Vector2(item.$1 * _tile, item.$2 * _tile),
        itemType: item.$3,
        itemId: 'item_$idx',
      );
    }).toList();
  }
}

// Constante de colores usada en el joystick
abstract class AppColors {
  static const Color greenAccent = Color(0xFF56E39F);
}
