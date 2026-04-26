// lib/game/objects/collectible_item.dart
// Objeto recogible en el mapa: cofres, setas, gemas, etc.
//
// Cofres (ItemType.chest / treasureChest):
//   - Al tocarlos se abren y entregan monedas + gemas + posible item aleatorio.
//   - Muestran un diálogo con el botín.
// Resto:
//   - Se recogen silenciosamente y van a la mochila.

import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../data/game_state.dart';
import '../../data/item_data.dart';

enum ItemType { chest, treasureChest, mushroom, gem, star, leaf, berry }

class CollectibleItem extends GameDecoration with Sensor {
  final ItemType itemType;
  final String itemId;
  bool _collected = false;
  double _time = 0;
  double _collectAnim = 0;
  bool _animating = false;

  static const double _tileSize = 32.0;
  static BuildContext? uiContext;

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

  bool get isChest => itemType == ItemType.chest || itemType == ItemType.treasureChest;

  String get emoji {
    switch (itemType) {
      case ItemType.chest:         return '🧰';
      case ItemType.treasureChest: return '💰';
      case ItemType.mushroom:      return '🍄';
      case ItemType.gem:           return '💎';
      case ItemType.star:          return '⭐';
      case ItemType.leaf:          return '🍃';
      case ItemType.berry:         return '🫐';
    }
  }

  int get value {
    switch (itemType) {
      case ItemType.chest:         return 50;
      case ItemType.treasureChest: return 150;
      case ItemType.gem:           return 30;
      case ItemType.star:          return 20;
      case ItemType.mushroom:      return 10;
      case ItemType.leaf:          return 8;
      case ItemType.berry:         return 5;
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

    if (isChest) {
      final reward = GameState().openChest(itemId);
      gameRef.add(_FloatingScore(
        position: Vector2(position.x, position.y - 20),
        text: '+${reward.coins} 🪙',
      ));
      // Mostrar popup de botín si hay un BuildContext disponible.
      final ctx = uiContext;
      if (ctx != null && ctx.mounted) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (ctx.mounted) _showChestDialog(ctx, reward);
        });
      }
    } else {
      GameState().collectMapItem(itemId);
      gameRef.add(_FloatingScore(
        position: Vector2(position.x, position.y - 20),
        text: '+$value',
      ));
    }
  }

  static void _showChestDialog(BuildContext ctx, ChestReward reward) {
    showDialog(
      context: ctx,
      barrierDismissible: true,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6B4423), Color(0xFF3A2410)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFFD966), width: 2),
            boxShadow: [
              BoxShadow(color: const Color(0xFFFFD966).withOpacity(0.35), blurRadius: 30),
            ],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('💰', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 8),
            const Text('¡Cofre abierto!',
                style: TextStyle(color: Color(0xFFFFD966), fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            _rewardRow('🪙', '+${reward.coins} monedas'),
            if (reward.gems > 0) _rewardRow('💎', '+${reward.gems} gemas'),
            if (reward.bonusItem != null)
              _rewardRow(reward.bonusItem!.emoji,
                  '¡${reward.bonusItem!.name} añadido a la mochila!'),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => Navigator.of(ctx).pop(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD966),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('¡Genial!',
                    style: TextStyle(color: Color(0xFF3A2410), fontWeight: FontWeight.w900, fontSize: 14)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  static Widget _rewardRow(String emoji, String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Text(text,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
        ]),
      );
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
