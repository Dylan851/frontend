// lib/game/actors/animal_npc.dart
import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:bonfire/bonfire.dart';
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import '../../data/animal_data.dart';
import '../../data/game_state.dart';
import '../overlays/encounter_overlay.dart';

class AnimalNpc extends SimpleNpc with Sensor {
  final AnimalData animalData;
  final void Function(AnimalData)? onEncounter;

  bool   _triggered  = false;
  double _bobT       = 0.0;
  double _bobBase    = 0.0;
  double _exclamT    = 0.0;
  bool   _playerNear = false;

  // Animación manual: lista de 4 frames extraídos del spritesheet 64×16.
  List<Sprite>? _frames;
  int    _frame      = 0;
  double _frameTimer = 0.0;
  static const double _frameDuration = 0.18; // segundos por frame

  static const double _size   = 20.0;
  static const double _sensor = 32.0;

  AnimalNpc({
    required Vector2 position,
    required this.animalData,
    this.onEncounter,
  }) : super(
          position: position,
          size: Vector2.all(_size),
          animation: SimpleDirectionAnimation(
            idleRight: _dummyAnim(),
            runRight:  _dummyAnim(),
          ),
        ) {
    _bobBase = (animalData.id.hashCode % 1000) / 1000 * math.pi * 2;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox(
      radius: _sensor,
      collisionType: CollisionType.passive,
      isSolid: true,
    ));

    // Cargar spritesheet 64×16 → 4 frames de 16×16.
    final path = animalData.spriteAsset;
    if (path != null) {
      try {
        final image = await Flame.images.load(path);
        _frames = List.generate(4, (i) => Sprite(
          image,
          srcPosition: Vector2(i * 16.0, 0),
          srcSize: Vector2(16, 16),
        ));
      } catch (_) {
        // Sin spritesheet → fallback emoji.
      }
    }
  }

  static Future<SpriteAnimation> _dummyAnim() async {
    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      Uint8List(4), 1, 1, ui.PixelFormat.rgba8888, completer.complete,
    );
    final image = await completer.future;
    return SpriteAnimation.spriteList([Sprite(image)], stepTime: 1);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _bobT += dt;

    // Avanzar frame de animación.
    if (_frames != null) {
      _frameTimer += dt;
      if (_frameTimer >= _frameDuration) {
        _frameTimer -= _frameDuration;
        _frame = (_frame + 1) % _frames!.length;
      }
    }

    if (_playerNear && !GameState().isAnimalDiscovered(animalData.id)) {
      _exclamT += dt;
    }
  }

  @override
  void render(Canvas canvas) {
    // Sombra ovalada.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(_size / 2, _size * 0.92),
        width: _size * 0.7,
        height: _size * 0.18,
      ),
      Paint()..color = Colors.black.withOpacity(0.28),
    );

    final bob = math.sin(_bobT * 1.8 + _bobBase) * 1.2;

    // Halo verde si ya está descubierto.
    if (GameState().isAnimalDiscovered(animalData.id)) {
      canvas.drawCircle(
        Offset(_size / 2, _size / 2 + bob),
        _size * 0.55,
        Paint()
          ..color = const Color(0xFF56E39F).withOpacity(0.18)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }

    // Sprite animado (o emoji si no hay spritesheet).
    if (_frames != null) {
      _frames![_frame].render(
        canvas,
        position: Vector2(0, bob),
        size: Vector2.all(_size),
      );
    } else {
      final tp = TextPainter(
        text: TextSpan(
          text: animalData.emoji,
          style: TextStyle(fontSize: _size * 0.85),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset((_size - tp.width) / 2, bob));
    }

    // Burbuja de exclamación si el jugador está cerca y no lo ha descubierto aún.
    if (_playerNear && !GameState().isAnimalDiscovered(animalData.id)) {
      _drawBubble(canvas, bob);
    }

    super.render(canvas);
  }

  void _drawBubble(Canvas canvas, double bob) {
    final pulse = 1.0 + 0.12 * math.sin(_exclamT * 6);
    final by    = bob - _size * 0.85;
    final bx    = _size / 2;

    canvas.drawCircle(
      Offset(bx, by), 6.5 * pulse,
      Paint()..color = Colors.white.withOpacity(0.92),
    );
    canvas.drawCircle(
      Offset(bx, by), 6.5 * pulse,
      Paint()
        ..color = const Color(0xFFFF9900)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    final tp = TextPainter(
      text: const TextSpan(
        text: '!',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w900,
          color: Color(0xFFFF6B00),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(bx - tp.width / 2, by - tp.height / 2));
  }

  // ── Sensor de proximidad ──────────────────────────────────────────────────
  @override
  void onContact(GameComponent other) {
    if (other is! SimplePlayer) return;
    _playerNear = true;

    // ─────────────────────────────────────────────────────────────────────
    // 🔊 SONIDO DE PROXIMIDAD
    // Cuando el jugador se acerca a un animal se reproduce su sonido.
    // Pasos para activarlo:
    //   1. Añade `flame_audio` en pubspec.yaml (dependencies).
    //   2. Copia los archivos de sonido en assets/audio/animals/<id>.ogg
    //   3. Registra la carpeta en pubspec.yaml:
    //        - assets/audio/animals/
    //   4. Descomenta las dos líneas siguientes:
    //
    // import 'package:flame_audio/flame_audio.dart'; // ← añadir al inicio del fichero
    // FlameAudio.play('audio/animals/${animalData.id}.ogg',
    //     volume: GameState().sfxOn ? 0.8 : 0.0);
    // ─────────────────────────────────────────────────────────────────────

    if (!_triggered) {
      _triggered = true;
      // El animal se desbloquea en la colección SOLO al ganar el minijuego,
      // no en el momento del encuentro.
      onEncounter?.call(animalData);
      gameRef.overlays.add(EncounterOverlay.id);
    }
  }

  @override
  void onContactExit(GameComponent other) {
    if (other is! SimplePlayer) return;
    _playerNear = false;
    _triggered  = false;
  }
}
