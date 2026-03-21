// lib/game/actors/player_character.dart
// Jugador principal — usa SimplePlayer de Bonfire con movimiento en 4 direcciones

import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import '../objects/collectible_item.dart';
import '../overlays/hud_overlay.dart';

class PlayerCharacter extends SimplePlayer with ObjectCollision {
  static const double _speed = 80.0;
  static const double _tileSize = 32.0;

  PlayerCharacter({required Vector2 position})
      : super(
          position: position,
          size: Vector2.all(_tileSize * 0.85),
          speed: _speed,
          animation: SimpleDirectionAnimation(
            idleRight: _buildAnim('idle'),
            runRight: _buildAnim('run'),
          ),
        ) {
    setupCollision(CollisionConfig(
      collisions: [
        RectangleHitbox(
          size: Vector2(_tileSize * 0.5, _tileSize * 0.5),
          position: Vector2(_tileSize * 0.17, _tileSize * 0.35),
        ),
      ],
    ));
  }

  /// Animación placeholder con un cuadro de color mientras no hay sprites
  static Future<SpriteAnimation> _buildAnim(String type) async {
    return SpriteAnimation.load(
      'player/player_walk.png',
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.15,
        textureSize: Vector2(16, 16),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _checkNearbyItems();
  }

  void _checkNearbyItems() {
    // detectar ítems cercanos se gestiona en cada CollectibleItem
  }

  @override
  void render(Canvas canvas) {
    // Dibuja el personaje como emoji mientras no hay sprite sheet real
    super.render(canvas);
    _drawPlayerEmoji(canvas);
  }

  void _drawPlayerEmoji(Canvas canvas) {
    const emoji = '🧒';
    final tp = TextPainter(
      text: TextSpan(
        text: emoji,
        style: TextStyle(fontSize: size.x * 0.9),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    tp.paint(
      canvas,
      Offset(
        (size.x - tp.width) / 2,
        (size.y - tp.height) / 2,
      ),
    );
  }

  @override
  bool get showAboveComponents => true;
}
