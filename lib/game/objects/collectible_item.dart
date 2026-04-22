// lib/game/objects/collectible_item.dart
// Objeto recogible en el mapa: cofres, setas, gemas, etc.

import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import '../../data/game_state.dart';

enum ItemType { chest, mushroom, gem, star, leaf, berry }

class CollectibleItem extends GameDecoration with Sensor {
  final ItemType itemType;
  final String itemId;
  bool _collected = false;
  double _time = 0;
  double _collectAnim = 0;
  bool _animating = false;

  static const double _tileSize = 32.0;

  CollectibleItem({
    required Vector2 position,
    required this.itemType,
    required this.itemId,
  }) : super(position: position, size: Vector2.all(_tileSize));

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox(
      radius: _tileSize * 0.7,
      collisionType: CollisionType.passive,
      isSolid: true,
    ));
  }

  String get emoji {
    switch (itemType) {
      case ItemType.chest:  return '📦';
      case ItemType.mushroom: return '🍄';
      case ItemType.gem:    return '💎';
      case ItemType.star:   return '⭐';
      case ItemType.leaf:   return '🍃';
      case ItemType.berry:  return '🫐';
    }
  }

  int get value {
    switch (itemType) {
      case ItemType.chest:   return 50;
      case ItemType.gem:     return 30;
      case ItemType.star:    return 20;
      case ItemType.mushroom:return 10;
      case ItemType.leaf:    return 8;
      case ItemType.berry:   return 5;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_collected) return;
    _time += dt;

    if (_animating) {
      _collectAnim += dt * 3;
      if (_collectAnim >= 1.0) removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    if (_collected && !_animating) return;
    super.render(canvas);

    final floatOffset = _animating
        ? -_collectAnim * 30
        : (_time * 2.5 % (2 * 3.14159)).abs() * 2 - 2;

    // Sombra
    if (!_animating) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(size.x / 2, size.y - 4),
          width: size.x * 0.5,
          height: 6,
        ),
        Paint()..color = Colors.black.withOpacity(0.2),
      );
    }

    // Emoji del ítem
    final opacity = _animating ? (1.0 - _collectAnim).clamp(0.0, 1.0) : 1.0;
    final tp = TextPainter(
      text: TextSpan(
        text: emoji,
        style: TextStyle(
          fontSize: size.x * 0.8,
          color: Colors.white.withOpacity(opacity),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    tp.paint(canvas, Offset((size.x - tp.width) / 2, floatOffset));
  }

  @override
  void onContact(GameComponent other) {
    if (_collected || other is! SimplePlayer) return;
    _collect();
  }

  void _collect() {
    _collected = true;
    _animating = true;
    GameState().collectMapItem(itemId);

    // Mostrar +puntos flotando
    gameRef.add(
      _FloatingScore(
        position: Vector2(position.x, position.y - 20),
        text: '+${value}',
      ),
    );
  }
}

/// Texto flotante de puntuación
class _FloatingScore extends GameDecoration {
  final String text;
  double _alpha = 1.0;
  double _offsetY = 0;

  _FloatingScore({required Vector2 position, required this.text})
      : super(position: position, size: Vector2(60, 30));

  @override
  void update(double dt) {
    super.update(dt);
    _offsetY -= 40 * dt;
    _alpha -= dt * 1.5;
    if (_alpha <= 0) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFFFE566).withOpacity(_alpha.clamp(0, 1)),
          shadows: const [Shadow(color: Colors.black54, offset: Offset(1, 1), blurRadius: 3)],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(0, _offsetY));
  }
}
