// lib/game/minigames/taming_game.dart
//
// MINIJUEGO: DOMESTICACIÓN 🐾
// ─────────────────────────────────────────────────────────────────────────────
// El jugador maneja un paddle horizontal para devolver una pelota de "amor"
// (comida/corazones) hacia el animal. Cada vez que la pelota toca al animal
// sube la barra de confianza. Si cae la pelota sin devolverla, baja.
// Hay 3 FASES de comportamiento del animal:
//   FASE 1 — Asustado:   el animal huye, rebotes rápidos, 2 vidas
//   FASE 2 — Curioso:    el animal se mueve lento, rebotes medios, 1 vida
//   FASE 3 — Confiado:   el animal casi no se mueve, rebotes lentos, 1 vida
// Al completar las 3 fases aparece la animación de domesticación.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/animal_data.dart';
import '../../theme/app_theme.dart';

// ════════════════════════════════════════════════════════════════════════════
//  PUBLIC WIDGET
// ════════════════════════════════════════════════════════════════════════════
class TamingGame extends StatefulWidget {
  final AnimalData animal;
  final void Function(int stars) onComplete;

  const TamingGame({
    super.key,
    required this.animal,
    required this.onComplete,
  });

  @override
  State<TamingGame> createState() => _TamingGameState();
}

// ════════════════════════════════════════════════════════════════════════════
//  STATE
// ════════════════════════════════════════════════════════════════════════════
class _TamingGameState extends State<TamingGame>
    with SingleTickerProviderStateMixin {
  // ── Engine ────────────────────────────────────────────────────────────────
  late Ticker _ticker;
  Duration _lastTs = Duration.zero;

  // ── Layout ────────────────────────────────────────────────────────────────
  Size _arena = Size.zero;           // calculated on first layout
  bool _ready = false;

  // ── Ball ──────────────────────────────────────────────────────────────────
  static const double _ballR      = 10.0;
  late Offset _ballPos;
  late Offset _ballVel;             // pixels / second
  bool _ballLaunched = false;

  // ── Paddle ────────────────────────────────────────────────────────────────
  static const double _paddleW    = 90.0;
  static const double _paddleH    = 12.0;
  static const double _paddleY    = 0.88;  // fraction from top
  double _paddleX = 0.0;           // centre X
  double _paddleDragStart = 0.0;
  double _paddleDragOrigin = 0.0;

  // ── Animal ────────────────────────────────────────────────────────────────
  static const double _animalSize = 56.0;
  double _animalX = 0.0;
  double _animalVel = 0.0;
  double _animalY = 0.0;

  // ── Game state ────────────────────────────────────────────────────────────
  int    _phase       = 0;         // 0 / 1 / 2
  int    _lives       = 2;
  double _trust       = 0.0;      // 0 → 1  per phase
  int    _hits        = 0;        // hits this phase
  int    _totalHits   = 0;
  bool   _phaseComplete = false;
  bool   _gameOver    = false;
  bool   _won         = false;
  bool   _showHeart   = false;
  Offset _heartPos    = Offset.zero;
  double _heartAlpha  = 0.0;
  double _heartScale  = 0.0;
  double _heartT      = 0.0;
  int    _missCount   = 0;        // total misses
  double _animalBobT  = 0.0;     // idle bob animation

  // ── Phase config ──────────────────────────────────────────────────────────
  static const _phaseConfig = [
    // hitsNeeded, livesAtStart, ballSpeed, animalSpeed, animalAmplitude
    (12, 2, 280.0, 95.0, 0.38),   // FASE 1 — Asustado
    (10, 1, 230.0, 55.0, 0.22),   // FASE 2 — Curioso
    ( 8, 1, 180.0, 22.0, 0.10),   // FASE 3 — Confiado
  ];

  int get _hitsNeeded => _phaseConfig[_phase].$1;
  double get _ballSpeed => _phaseConfig[_phase].$3;
  double get _animalSpd => _phaseConfig[_phase].$4;
  double get _animalAmp => _phaseConfig[_phase].$5;

  // ── Phase labels ──────────────────────────────────────────────────────────
  static const _phaseEmoji = ['😨', '🤔', '😊'];
  static const _phaseLabel = ['¡Asustado!', 'Curioso…', '¡Confiando!'];
  static const _phaseHint  = [
    'El animal huye. ¡No dejes caer el amor!',
    'Se acerca despacio. ¡Sigue enviando comida!',
    '¡Casi lo consigues! Dale el último empujón.',
  ];

  // ── Particles ─────────────────────────────────────────────────────────────
  final List<_Particle> _particles = [];

  // ── Win animation ─────────────────────────────────────────────────────────
  double _winT = 0.0;
  bool _winAnimPlaying = false;

  // ─────────────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _initArena(Size size) {
    if (_ready && _arena == size) return;
    _arena = size;
    _ready = true;
    _resetForPhase();
  }

  void _resetForPhase() {
    final cfg = _phaseConfig[_phase];
    _lives    = cfg.$2;
    _trust    = 0.0;
    _hits     = 0;
    _phaseComplete = false;
    _animalY  = _arena.height * 0.12;
    _animalX  = _arena.width * 0.5;
    _animalVel = _animalSpd;
    _resetBall();
  }

  void _resetBall() {
    _paddleX    = _arena.width * 0.5;
    _ballPos    = Offset(_paddleX, _arena.height * _paddleY - _paddleH / 2 - _ballR - 2);
    _ballVel    = Offset.zero;
    _ballLaunched = false;
  }

  void _launchBall() {
    if (_ballLaunched) return;
    _ballLaunched = true;
    final angle   = -math.pi / 2 + (math.Random().nextDouble() - 0.5) * 0.5;
    _ballVel      = Offset(_ballSpeed * math.cos(angle), _ballSpeed * math.sin(angle));
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  TICK
  // ─────────────────────────────────────────────────────────────────────────
  void _onTick(Duration elapsed) {
    if (!mounted || !_ready) return;
    final dt = _lastTs == Duration.zero
        ? 0.016
        : (elapsed - _lastTs).inMicroseconds / 1e6;
    _lastTs = elapsed;

    if (_gameOver || _won) {
      if (_winAnimPlaying) setState(() => _winT += dt);
      return;
    }
    if (_phaseComplete) return;

    setState(() {
      _animalBobT += dt;
      _updateAnimal(dt);
      if (_ballLaunched) {
        _updateBall(dt);
      }
      _updateParticles(dt);
      // Heart pulse
      if (_showHeart) {
        _heartT += dt;
        _heartAlpha = (1.0 - _heartT * 1.8).clamp(0, 1);
        _heartScale = 1.0 + _heartT * 2;
        if (_heartT > 0.55) _showHeart = false;
      }
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  ANIMAL MOVEMENT
  // ─────────────────────────────────────────────────────────────────────────
  void _updateAnimal(double dt) {
    final halfAnim = _arena.width * _animalAmp;
    _animalX += _animalVel * dt;
    final leftLimit  = _animalSize / 2 + halfAnim;
    final rightLimit = _arena.width - _animalSize / 2 - halfAnim;
    if (_animalX <= _animalSize / 2) { _animalX = _animalSize / 2; _animalVel = _animalSpd.abs(); }
    if (_animalX >= _arena.width - _animalSize / 2) { _animalX = _arena.width - _animalSize / 2; _animalVel = -_animalSpd.abs(); }
    // Bob
    _animalY = _arena.height * 0.12 + math.sin(_animalBobT * 1.8) * 5;
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  BALL PHYSICS
  // ─────────────────────────────────────────────────────────────────────────
  void _updateBall(double dt) {
    _ballPos = _ballPos + _ballVel * dt;

    // ── Left / Right walls
    if (_ballPos.dx - _ballR <= 0) {
      _ballPos = Offset(_ballR, _ballPos.dy);
      _ballVel = Offset(-_ballVel.dx.abs(), _ballVel.dy);
      HapticFeedback.selectionClick();
    }
    if (_ballPos.dx + _ballR >= _arena.width) {
      _ballPos = Offset(_arena.width - _ballR, _ballPos.dy);
      _ballVel = Offset(-_ballVel.dx.abs().toDouble() * -1, _ballVel.dy);
      _ballVel = Offset(_ballVel.dx.abs() * -1, _ballVel.dy);
      HapticFeedback.selectionClick();
    }
    // Normalize X
    if (_ballVel.dx > 0 && _ballPos.dx + _ballR >= _arena.width) {
      _ballVel = Offset(-_ballVel.dx.abs(), _ballVel.dy);
    }
    if (_ballVel.dx < 0 && _ballPos.dx - _ballR <= 0) {
      _ballVel = Offset(_ballVel.dx.abs(), _ballVel.dy);
    }

    // ── Top wall
    if (_ballPos.dy - _ballR <= 0) {
      _ballPos = Offset(_ballPos.dx, _ballR);
      _ballVel = Offset(_ballVel.dx, _ballVel.dy.abs());
      HapticFeedback.selectionClick();
    }

    // ── Animal collision
    final animalRect = Rect.fromCenter(
      center: Offset(_animalX, _animalY + _animalSize * 0.5),
      width: _animalSize * 0.85,
      height: _animalSize,
    );
    final ballCircle = Rect.fromCircle(center: _ballPos, radius: _ballR);
    if (animalRect.overlaps(ballCircle) && _ballVel.dy < 0) {
      _ballVel = Offset(_ballVel.dx, _ballVel.dy.abs());
      _onHitAnimal();
      HapticFeedback.mediumImpact();
    }

    // ── Paddle collision
    final paddleTop    = _arena.height * _paddleY - _paddleH / 2;
    final paddleLeft   = _paddleX - _paddleW / 2;
    final paddleRight  = _paddleX + _paddleW / 2;
    if (_ballPos.dy + _ballR >= paddleTop &&
        _ballPos.dy - _ballR <= paddleTop + _paddleH &&
        _ballPos.dx >= paddleLeft &&
        _ballPos.dx <= paddleRight &&
        _ballVel.dy > 0) {
      // Angle depends on hit position relative to centre
      final hit    = (_ballPos.dx - _paddleX) / (_paddleW / 2);
      final angle  = hit * (math.pi / 3.5); // max ±51°
      final speed  = _ballVel.distance.clamp(_ballSpeed * 0.9, _ballSpeed * 1.1);
      _ballVel = Offset(
        speed * math.sin(angle),
        -speed * math.cos(angle),
      );
      _ballPos = Offset(_ballPos.dx, paddleTop - _ballR);
      _spawnParticle(_ballPos, AppColors.greenAccent);
      HapticFeedback.lightImpact();
    }

    // ── Ball fell below paddle → miss
    if (_ballPos.dy > _arena.height + 30) {
      _onMiss();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  GAME EVENTS
  // ─────────────────────────────────────────────────────────────────────────
  void _onHitAnimal() {
    _hits++;
    _totalHits++;
    _trust = (_hits / _hitsNeeded).clamp(0, 1);

    // Floating heart
    _heartPos  = Offset(_animalX, _animalY);
    _heartAlpha = 1.0; _heartScale = 1.0; _heartT = 0; _showHeart = true;

    // Particles
    for (int i = 0; i < 6; i++) {
      _spawnParticle(Offset(_animalX, _animalY + 20), AppColors.gold);
    }

    if (_hits >= _hitsNeeded) _completePhase();
  }

  void _onMiss() {
    _missCount++;
    _lives--;
    HapticFeedback.heavyImpact();
    _spawnParticle(Offset(_arena.width / 2, _arena.height - 30), AppColors.badgeRed);

    if (_lives <= 0) {
      _gameOver = true;
      _won      = false;
    } else {
      _resetBall();
    }
  }

  void _completePhase() {
    _phaseComplete = true;
    HapticFeedback.heavyImpact();
    for (int i = 0; i < 14; i++) {
      _spawnParticle(
        Offset(math.Random().nextDouble() * _arena.width, _arena.height * 0.5),
        [AppColors.gold, AppColors.greenAccent, Colors.pinkAccent][i % 3],
      );
    }

    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      final nextPhase = _phase + 1;
      if (nextPhase >= 3) {
        // WON!
        setState(() { _won = true; _winAnimPlaying = true; });
        Future.delayed(const Duration(milliseconds: 2200), () {
          if (!mounted) return;
          final stars = _missCount == 0 ? 3 : _missCount <= 3 ? 2 : 1;
          widget.onComplete(stars);
        });
      } else {
        setState(() {
          _phase = nextPhase;
          _resetForPhase();
        });
      }
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  PARTICLES
  // ─────────────────────────────────────────────────────────────────────────
  void _spawnParticle(Offset pos, Color color) {
    final rng = math.Random();
    final angle = rng.nextDouble() * math.pi * 2;
    final speed = 60.0 + rng.nextDouble() * 100;
    _particles.add(_Particle(
      pos: pos,
      vel: Offset(math.cos(angle) * speed, math.sin(angle) * speed),
      color: color,
      life: 0.6 + rng.nextDouble() * 0.4,
      size: 3 + rng.nextDouble() * 5,
    ));
    if (_particles.length > 80) _particles.removeRange(0, 20);
  }

  void _updateParticles(double dt) {
    for (final p in _particles) {
      p.pos += p.vel * dt;
      p.vel = p.vel * 0.92;
      p.life -= dt * 1.2;
    }
    _particles.removeWhere((p) => p.life <= 0);
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  PADDLE DRAG
  // ─────────────────────────────────────────────────────────────────────────
  void _onPanStart(DragStartDetails d) {
    _paddleDragStart  = d.localPosition.dx;
    _paddleDragOrigin = _paddleX;
  }

  void _onPanUpdate(DragUpdateDetails d) {
    setState(() {
      _paddleX = (_paddleDragOrigin + d.localPosition.dx - _paddleDragStart)
          .clamp(_paddleW / 2, _arena.width - _paddleW / 2);
      // If ball not launched, follow paddle
      if (!_ballLaunched) {
        _ballPos = Offset(_paddleX, _ballPos.dy);
      }
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _buildHeader(),
      Expanded(child: _buildArena()),
    ]);
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(children: [
        // Animal info
        Text(widget.animal.emoji, style: const TextStyle(fontSize: 32)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Text('¡Domestica al ${widget.animal.name}!',
              style: const TextStyle(color: Colors.white,
                  fontWeight: FontWeight.w900, fontSize: 15)),
          Text(_phaseHint[_phase.clamp(0, 2)],
              style: TextStyle(
                  color: Colors.white.withOpacity(0.55), fontSize: 10)),
        ])),
        // Phase pills
        Row(children: List.generate(3, (i) {
          final active  = i == _phase;
          final done    = i < _phase;
          return Container(
            margin: const EdgeInsets.only(left: 5),
            width: 28, height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done
                  ? AppColors.greenAccent.withOpacity(0.3)
                  : active
                      ? Colors.white.withOpacity(0.15)
                      : Colors.white.withOpacity(0.05),
              border: Border.all(
                color: done
                    ? AppColors.greenAccent
                    : active
                        ? Colors.white.withOpacity(0.6)
                        : Colors.white.withOpacity(0.1),
                width: active ? 2 : 1,
              ),
            ),
            child: Center(child: Text(done ? '✅' : _phaseEmoji[i],
                style: const TextStyle(fontSize: 12))),
          );
        })),
        const SizedBox(width: 8),
        // Lives
        Row(children: List.generate(
          _phaseConfig[_phase.clamp(0, 2)].$2,
          (i) => Padding(
            padding: const EdgeInsets.only(left: 2),
            child: Text(i < _lives ? '❤️' : '🖤',
                style: const TextStyle(fontSize: 14)),
          ),
        )),
      ]),
    );
  }

  // ── Arena ────────────────────────────────────────────────────────────────
  Widget _buildArena() {
    return LayoutBuilder(builder: (_, constraints) {
      _initArena(Size(constraints.maxWidth, constraints.maxHeight));
      return GestureDetector(
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onTap: _gameOver ? null : _launchBall,
        child: ClipRect(
          child: CustomPaint(
            painter: _ArenaPainter(
              phase: _phase,
              animal: widget.animal,
              animalX: _animalX,
              animalY: _animalY,
              animalSize: _animalSize,
              ballPos: _ballPos,
              ballR: _ballR,
              paddleX: _paddleX,
              paddleW: _paddleW,
              paddleH: _paddleH,
              paddleYFrac: _paddleY,
              trust: _trust,
              lives: _lives,
              hitsNeeded: _hitsNeeded,
              hits: _hits,
              particles: List.from(_particles),
              showHeart: _showHeart,
              heartPos: _heartPos,
              heartAlpha: _heartAlpha,
              heartScale: _heartScale,
              ballLaunched: _ballLaunched,
              gameOver: _gameOver,
              won: _won,
              winT: _winT,
              phaseComplete: _phaseComplete,
            ),
            child: const SizedBox.expand(),
          ),
        ),
      );
    });
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  CUSTOM PAINTER
// ════════════════════════════════════════════════════════════════════════════
class _ArenaPainter extends CustomPainter {
  final int phase;
  final AnimalData animal;
  final double animalX, animalY, animalSize;
  final Offset ballPos;
  final double ballR;
  final double paddleX, paddleW, paddleH, paddleYFrac;
  final double trust;
  final int lives, hitsNeeded, hits;
  final List<_Particle> particles;
  final bool showHeart;
  final Offset heartPos;
  final double heartAlpha, heartScale;
  final bool ballLaunched, gameOver, won, phaseComplete;
  final double winT;

  static const _phaseLabel = ['FASE 1 — Asustado', 'FASE 2 — Curioso', 'FASE 3 — Confiado'];
  static const _phaseBg = [
    [Color(0xFF1A0D0D), Color(0xFF2E0D1A)],   // red tint
    [Color(0xFF0D1A2E), Color(0xFF0D2B2E)],   // blue tint
    [Color(0xFF0D2B1A), Color(0xFF1A4A2E)],   // green tint
  ];
  static const _phaseAccent = [
    Color(0xFFFF6B6B),
    Color(0xFF4ECDC4),
    Color(0xFF56E39F),
  ];

  const _ArenaPainter({
    required this.phase, required this.animal,
    required this.animalX, required this.animalY, required this.animalSize,
    required this.ballPos, required this.ballR,
    required this.paddleX, required this.paddleW, required this.paddleH,
    required this.paddleYFrac,
    required this.trust, required this.lives, required this.hitsNeeded,
    required this.hits,
    required this.particles,
    required this.showHeart, required this.heartPos,
    required this.heartAlpha, required this.heartScale,
    required this.ballLaunched, required this.gameOver, required this.won,
    required this.phaseComplete, required this.winT,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final p = phase.clamp(0, 2);

    // ── Background ──────────────────────────────────────────────────────────
    final bgGrad = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: _phaseBg[p],
    );
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..shader = bgGrad.createShader(Rect.fromLTWH(0, 0, size.width, size.height)));

    // ── Grid lines ──────────────────────────────────────────────────────────
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    // ── Trust bar (left side) ───────────────────────────────────────────────
    _drawTrustBar(canvas, size, p);

    // ── Phase label ─────────────────────────────────────────────────────────
    _drawText(canvas,
      text: _phaseLabel[p],
      offset: Offset(size.width / 2, 12),
      fontSize: 11,
      color: _phaseAccent[p].withOpacity(0.7),
      bold: true,
      centered: true,
    );

    // ── Particles ───────────────────────────────────────────────────────────
    for (final pt in particles) {
      canvas.drawCircle(
        pt.pos,
        pt.size * pt.life.clamp(0, 1),
        Paint()..color = pt.color.withOpacity(pt.life.clamp(0, 1)),
      );
    }

    // ── Animal ──────────────────────────────────────────────────────────────
    _drawAnimal(canvas, size, p);

    // ── Ball ────────────────────────────────────────────────────────────────
    if (!gameOver && !won) {
      _drawBall(canvas, size, p);
    }

    // ── Paddle ──────────────────────────────────────────────────────────────
    if (!gameOver && !won) {
      _drawPaddle(canvas, size, p);
    }

    // ── Heart pop ──────────────────────────────────────────────────────────
    if (showHeart) {
      _drawHeart(canvas);
    }

    // ── Launch hint ────────────────────────────────────────────────────────
    if (!ballLaunched && !gameOver && !won) {
      _drawText(canvas,
        text: '¡Toca para lanzar! 💕',
        offset: Offset(size.width / 2, size.height * paddleYFrac - 35),
        fontSize: 12,
        color: Colors.white.withOpacity(0.65),
        centered: true,
      );
    }

    // ── Game over overlay ──────────────────────────────────────────────────
    if (gameOver) _drawGameOver(canvas, size);

    // ── Win overlay ────────────────────────────────────────────────────────
    if (won) _drawWin(canvas, size);
  }

  // ── Trust bar ─────────────────────────────────────────────────────────────
  void _drawTrustBar(Canvas canvas, Size size, int p) {
    const barW   = 10.0;
    final barH   = size.height * 0.55;
    final left   = size.width - barW - 10;
    final top    = size.height * 0.2;
    final accent = _phaseAccent[p];

    // Background
    final rrBg = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, barW, barH),
      const Radius.circular(5),
    );
    canvas.drawRRect(rrBg,
        Paint()..color = Colors.white.withOpacity(0.08));

    // Fill
    final fillH = barH * trust;
    if (fillH > 0) {
      final rrFill = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top + barH - fillH, barW, fillH),
        const Radius.circular(5),
      );
      canvas.drawRRect(rrFill,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [accent, accent.withOpacity(0.5)],
            ).createShader(Rect.fromLTWH(left, top, barW, barH))
            ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 0));
    }

    // Heart icon at top
    _drawText(canvas,
      text: '❤️',
      offset: Offset(left + barW / 2, top - 16),
      fontSize: 14,
      centered: true,
    );

    // Percentage
    _drawText(canvas,
      text: '${(trust * 100).toInt()}%',
      offset: Offset(left + barW / 2, top + barH + 10),
      fontSize: 8,
      color: Colors.white.withOpacity(0.45),
      centered: true,
    );
  }

  // ── Animal ────────────────────────────────────────────────────────────────
  void _drawAnimal(Canvas canvas, Size size, int p) {
    final accent = _phaseAccent[p];
    final cx = animalX;
    final cy = animalY + animalSize / 2;

    // Aura / glow (trust-based)
    if (trust > 0.2) {
      canvas.drawCircle(
        Offset(cx, cy),
        animalSize * 0.65 * trust,
        Paint()
          ..color = accent.withOpacity(0.12 * trust)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
      );
    }

    // Shadow
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx, animalY + animalSize + 4),
          width: animalSize * 0.7,
          height: 8),
      Paint()..color = Colors.black.withOpacity(0.3),
    );

    // Emoji
    final tp = TextPainter(
      text: TextSpan(
        text: animal.emoji,
        style: TextStyle(fontSize: animalSize * 0.85),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, animalY));

    // Status ring
    final ringPaint = Paint()
      ..color = accent.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(Offset(cx, cy), animalSize * 0.6, ringPaint);
  }

  // ── Ball ──────────────────────────────────────────────────────────────────
  void _drawBall(Canvas canvas, Size size, int p) {
    final accent = _phaseAccent[p];

    // Trail / glow
    canvas.drawCircle(
      ballPos,
      ballR * 1.8,
      Paint()
        ..color = accent.withOpacity(0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Ball core
    canvas.drawCircle(
      ballPos,
      ballR,
      Paint()
        ..shader = RadialGradient(
          colors: [Colors.white, accent],
        ).createShader(Rect.fromCircle(center: ballPos, radius: ballR)),
    );

    // Ball emoji
    final tp = TextPainter(
      text: const TextSpan(text: '❤️', style: TextStyle(fontSize: 12)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas,
        Offset(ballPos.dx - tp.width / 2, ballPos.dy - tp.height / 2));
  }

  // ── Paddle ────────────────────────────────────────────────────────────────
  void _drawPaddle(Canvas canvas, Size size, int p) {
    final py     = size.height * paddleYFrac - paddleH / 2;
    final accent = _phaseAccent[p];
    final rr = RRect.fromRectAndRadius(
      Rect.fromCenter(
          center: Offset(paddleX, py + paddleH / 2),
          width: paddleW,
          height: paddleH),
      const Radius.circular(paddleH / 2),
    );

    // Glow
    canvas.drawRRect(rr,
        Paint()
          ..color = accent.withOpacity(0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));

    // Body gradient
    canvas.drawRRect(
      rr,
      Paint()
        ..shader = LinearGradient(
          colors: [Colors.white, accent],
        ).createShader(Rect.fromCenter(
              center: Offset(paddleX, py + paddleH / 2),
              width: paddleW, height: paddleH)),
    );
  }

  // ── Floating heart ────────────────────────────────────────────────────────
  void _drawHeart(Canvas canvas) {
    final tp = TextPainter(
      text: TextSpan(
        text: '💕',
        style: TextStyle(
          fontSize: 22 * heartScale,
          color: Colors.white.withOpacity(heartAlpha),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas,
        Offset(heartPos.dx - tp.width / 2, heartPos.dy - 40 - heartScale * 10));
  }

  // ── Game Over ─────────────────────────────────────────────────────────────
  void _drawGameOver(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.black.withOpacity(0.7),
    );
    _drawText(canvas,
      text: '😢',
      offset: Offset(size.width / 2, size.height / 2 - 50),
      fontSize: 52, centered: true,
    );
    _drawText(canvas,
      text: '¡${animal.name} huyó!',
      offset: Offset(size.width / 2, size.height / 2 + 10),
      fontSize: 18, bold: true,
      color: Colors.white, centered: true,
    );
    _drawText(canvas,
      text: 'Intenta de nuevo',
      offset: Offset(size.width / 2, size.height / 2 + 32),
      fontSize: 12,
      color: Colors.white.withOpacity(0.55), centered: true,
    );
  }

  // ── Win ───────────────────────────────────────────────────────────────────
  void _drawWin(Canvas canvas, Size size) {
    final alpha = (winT * 1.5).clamp(0.0, 1.0);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.black.withOpacity(0.75 * alpha),
    );

    // Big emoji bounce
    final bounce = 1.0 + 0.15 * math.sin(winT * 8);
    final tp = TextPainter(
      text: TextSpan(
        text: animal.emoji,
        style: TextStyle(fontSize: 80 * bounce),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas,
        Offset(size.width / 2 - tp.width / 2,
            size.height / 2 - 80 - tp.height / 2));

    _drawText(canvas,
      text: '¡${animal.name} te quiere! 🐾',
      offset: Offset(size.width / 2, size.height / 2 + 20),
      fontSize: 17, bold: true,
      color: Colors.white.withOpacity(alpha), centered: true,
    );
    _drawText(canvas,
      text: '¡Has ganado su confianza!',
      offset: Offset(size.width / 2, size.height / 2 + 44),
      fontSize: 12,
      color: Colors.white.withOpacity(0.65 * alpha), centered: true,
    );
  }

  // ── Text helper ───────────────────────────────────────────────────────────
  void _drawText(Canvas canvas, {
    required String text,
    required Offset offset,
    double fontSize = 12,
    Color color = Colors.white,
    bool bold = false,
    bool centered = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          color: color,
          fontWeight: bold ? FontWeight.w900 : FontWeight.w400,
          fontFamily: 'Nunito',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas,
        centered
            ? Offset(offset.dx - tp.width / 2, offset.dy - tp.height / 2)
            : offset);
  }

  @override
  bool shouldRepaint(_ArenaPainter o) => true;
}

// ════════════════════════════════════════════════════════════════════════════
//  PARTICLE
// ════════════════════════════════════════════════════════════════════════════
class _Particle {
  Offset pos;
  Offset vel;
  Color  color;
  double life;
  double size;

  _Particle({
    required this.pos,
    required this.vel,
    required this.color,
    required this.life,
    required this.size,
  });
}
