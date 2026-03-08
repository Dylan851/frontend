// lib/game/actors/animal_npc.dart
// NPC animal que aparece en el mapa. Al acercarse muestra un diálogo y
// al interactuar lanza el minijuego correspondiente.

import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import '../../data/animal_data.dart';
import '../../data/game_state.dart';
import '../overlays/encounter_overlay.dart';

class AnimalNpc extends SimpleNpc with ObjectCollision, Sensor {
  final AnimalData animalData;
  bool _encounterShown = false;
  double _bounceTime = 0;

  static const double _tileSize = 32.0;
  static const double _detectionRange = 60.0;

  AnimalNpc({
    required Vector2 position,
    required this.animalData,
  }) : super(
          position: position,
          size: Vector2.all(_tileSize * 1.1),
          animation: SimpleDirectionAnimation(
            idleRight: _idleAnim(),
            runRight: _idleAnim(),
          ),
        ) {
    setupCollision(CollisionConfig(
      collisions: [
        RectangleHitbox(size: Vector2(_tileSize * 0.7, _tileSize * 0.7),
            position: Vector2(_tileSize * 0.15, _tileSize * 0.15)),
      ],
    ));

    setupSensorArea(
      CircleHitbox(radius: _detectionRange),
    );
  }

  static Future<SpriteAnimation> _idleAnim() async {
    // placeholder — retorna animación de 1 frame
    return SpriteAnimation.load(
      'animals/placeholder.png',
      SpriteAnimationData.sequenced(
        amount: 1,
        stepTime: 1.0,
        textureSize: Vector2(16, 16),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _bounceTime += dt;

    // Movimiento de "respira" suave
    final bounce = (Math.sin(_bounceTime * 2) * 2).toDouble();
    position.y = position.y + bounce * dt;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _drawAnimalEmoji(canvas);
    if (!GameState().isAnimalDiscovered(animalData.id)) {
      _drawDiscoveryIndicator(canvas);
    }
  }

  void _drawAnimalEmoji(Canvas canvas) {
    final tp = TextPainter(
      text: TextSpan(
        text: animalData.emoji,
        style: TextStyle(fontSize: size.x * 0.85),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    tp.paint(canvas, Offset((size.x - tp.width) / 2, (size.y - tp.height) / 2));
  }

  void _drawDiscoveryIndicator(Canvas canvas) {
    // Signo de exclamación parpadeante sobre el animal
    final bounce = Math.sin(_bounceTime * 3) * 3;
    final tp = TextPainter(
      text: const TextSpan(text: '❗', style: TextStyle(fontSize: 14)),
      textDirection: TextDirection.ltr,
    )..layout();

    tp.paint(canvas, Offset((size.x - tp.width) / 2, -18 + bounce));
  }

  @override
  void onContact(GameComponent other) {
    if (other is SimplePlayer && !_encounterShown) {
      _encounterShown = true;
      Future.delayed(const Duration(milliseconds: 100), () {
        gameRef.overlays.add(
          EncounterOverlay.id,
        );
        // Pasar los datos del animal a través del overlay manager
        (gameRef as dynamic).currentAnimal = animalData;
      });
    }
  }

  @override
  void onContactExit(GameComponent other) {
    if (other is SimplePlayer) {
      _encounterShown = false;
    }
  }

  @override
  bool get showAboveComponents => true;
}

// Helper para sin sin importar dart:math directamente
class Math {
  static double sin(double x) {
    // Taylor series para sin
    return x - (x * x * x) / 6 + (x * x * x * x * x) / 120;
  }
}
