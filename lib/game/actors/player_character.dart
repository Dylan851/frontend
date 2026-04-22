// lib/game/actors/player_character.dart
//
// Héroe con spritesheet RPG-Maker-style (formato 96×128):
//   assets/images/player/{id}.png  →  3 cols × 4 filas de 32×32
//   Fila 0: down   · Fila 1: left · Fila 2: right · Fila 3: up
//
// Para añadir un personaje nuevo: copia un PNG 96×128 a assets/images/player/
// con el nombre de su id y añádelo a CharacterCatalog.

import 'package:bonfire/bonfire.dart';
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';
import '../../data/game_state.dart';

// ─── Catálogo de personajes ────────────────────────────────────────────────
class CharacterInfo {
  final String id;         // id del sprite (player/{id}_down.png …)
  final String name;       // Nombre mostrado en selección
  final String emoji;      // Emoji representativo en la UI del menú
  final int    colorValue; // Color de acento (ARGB)
  final bool   locked;     // true → no seleccionable aún

  const CharacterInfo({
    required this.id,
    required this.name,
    required this.emoji,
    required this.colorValue,
    this.locked = false,
  });
}

class CharacterCatalog {
  CharacterCatalog._();

  // ▸ Añade aquí más personajes cuando tengas sus sprites pixel-art.
  //   Copia los 4 PNG (down/left/right/up) en assets/images/player/
  //   con el prefijo igual al campo `id`.
  static const List<CharacterInfo> all = [
    CharacterInfo(
      id:         'hero',
      name:       'Explorador',
      emoji:      '🧑',
      colorValue: 0xFF56E39F,   // verde acento
    ),
    CharacterInfo(
      id:         'hero',       // ← mismos sprites hasta tener pixel-art propio
      name:       'Aventurera',
      emoji:      '👧',
      colorValue: 0xFFFF6B9D,   // rosa
    ),
    CharacterInfo(
      id:         'hero',       // ← mismos sprites hasta tener pixel-art propio
      name:       'Sabio',
      emoji:      '🧙',
      colorValue: 0xFF9B59B6,   // púrpura
      locked:     true,
    ),
  ];

  static CharacterInfo byId(String id) =>
      all.firstWhere((c) => c.id == id, orElse: () => all.first);
}

// ─── Jugador ────────────────────────────────────────────────────────────────
class WildQuestPlayer extends SimplePlayer with BlockMovementCollision {
  /// Id del botón de interacción en el joystick
  static const int kActionInteract = 1;

  // Sprite nativo 32×32. Cámara zoom 2.6× → ~83×83 px en pantalla,
  // proporción pixel-art correcta y personaje ENTERO visible.
  static const double _w     = 32.0;
  static const double _h     = 32.0;
  static const double _speed = 90.0; // px/s

  WildQuestPlayer({
    required Vector2 position,
    String characterId = 'hero',
  }) : super(
          position: position,
          size:     Vector2(_w, _h),
          speed:    _speed,
          animation: SimpleDirectionAnimation(
            idleRight: _loadAnim(characterId, _dirRight, idle: true),
            runRight:  _loadAnim(characterId, _dirRight),
            idleLeft:  _loadAnim(characterId, _dirLeft,  idle: true),
            runLeft:   _loadAnim(characterId, _dirLeft),
            idleDown:  _loadAnim(characterId, _dirDown,  idle: true),
            runDown:   _loadAnim(characterId, _dirDown),
            idleUp:    _loadAnim(characterId, _dirUp,    idle: true),
            runUp:     _loadAnim(characterId, _dirUp),
          ),
        );

  // Filas del spritesheet RPG-Maker (96×128, tiles de 32×32).
  static const int _dirDown  = 0;
  static const int _dirLeft  = 1;
  static const int _dirRight = 2;
  static const int _dirUp    = 3;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Hitbox pequeña en los pies para poder colarse por huecos estrechos.
    add(RectangleHitbox(
      size:     Vector2(_w * 0.5, _h * 0.22),
      position: Vector2(_w * 0.25, _h * 0.75),
    ));
  }

  /// Carga la animación de una dirección leyendo 3 frames de la fila
  /// correspondiente en player/{id}.png (spritesheet 96×128, 32×32 tiles).
  /// Patrón de caminar: 0-1-2-1 para que sea suave (pie izq → centro → pie der).
  static Future<SpriteAnimation> _loadAnim(
    String characterId,
    int row, {
    bool idle = false,
  }) async {
    final image = await Flame.images.load('player/$characterId.png');
    final sheet = SpriteSheet(
      image: image,
      srcSize: Vector2(32, 32),
    );
    if (idle) {
      return SpriteAnimation.spriteList(
        [sheet.getSprite(row, 1)], // frame central = idle
        stepTime: 1.0,
      );
    }
    return SpriteAnimation.spriteList(
      [
        sheet.getSprite(row, 0),
        sheet.getSprite(row, 1),
        sheet.getSprite(row, 2),
        sheet.getSprite(row, 1),
      ],
      stepTime: 0.14,
    );
  }

  // ─── Botón de interacción del joystick ───────────────────────────────────
  @override
  void onJoystickAction(JoystickActionEvent event) {
    if (event.id == kActionInteract && event.event == ActionEvent.DOWN) {
      double          closest = 48.0;
      GameComponent?  target;
      gameRef.query<SimpleNpc>(onlyVisible: true).forEach((c) {
        final d = position.distanceTo(c.position);
        if (d < closest) { closest = d; target = c; }
      });
      if (target != null) {
        gameRef.camera.moveToTargetAnimated(
          target: target!,
          zoom:             gameRef.camera.zoom,
          effectController: EffectController(duration: 0.3),
        );
      }
    }
    super.onJoystickAction(event);
  }
}
