// lib/screens/character_select_screen.dart
//
// Pantalla de selección de personaje.
// Se muestra al pulsar "¡JUGAR!" antes de entrar al mapa.
//
// Para añadir un personaje nuevo:
//   1. Añade sus 4 sprites PNG en assets/images/player/{id}_down/left/right/up.png
//   2. Declara un CharacterInfo en CharacterCatalog.all (player_character.dart)

import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../game/actors/player_character.dart';
import '../data/game_state.dart';
import '../theme/app_theme.dart';

class CharacterSelectScreen extends StatefulWidget {
  const CharacterSelectScreen({super.key});
  @override
  State<CharacterSelectScreen> createState() => _CharacterSelectScreenState();
}

class _CharacterSelectScreenState extends State<CharacterSelectScreen>
    with TickerProviderStateMixin {
  int _selected = 0;
  late final PageController _pageCtrl;

  late AnimationController _bgCtrl, _cardCtrl, _floatCtrl;
  late Animation<double>   _bgAnim, _cardScale, _float;

  final _gs = GameState();

  @override
  void initState() {
    super.initState();

    // Restaurar selección previa si la hay
    final prevIdx = CharacterCatalog.all
        .indexWhere((c) => c.id == _gs.selectedCharacter && !c.locked);
    _selected = prevIdx >= 0 ? prevIdx : 0;

    _pageCtrl = PageController(
      initialPage:  _selected,
      viewportFraction: 0.72,
    );

    _bgCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 6))
      ..repeat();
    _cardCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 420))
      ..forward();
    _floatCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1900))
      ..repeat(reverse: true);

    _bgAnim   = Tween<double>(begin: 0, end: 1).animate(_bgCtrl);
    _cardScale = Tween<double>(begin: 0.7, end: 1.0).animate(
        CurvedAnimation(parent: _cardCtrl, curve: Curves.elasticOut));
    _float = Tween<double>(begin: 0, end: -14).animate(
        CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _bgCtrl.dispose(); _cardCtrl.dispose(); _floatCtrl.dispose();
    super.dispose();
  }

  void _confirm() {
    final info = CharacterCatalog.all[_selected];
    if (info.locked) return;
    _gs.selectedCharacter = info.id;
    _gs.selectedSkin      = info.emoji; // sincronizar emoji del menú
    Navigator.of(context).pushReplacementNamed('/game');
  }

  void _selectPage(int idx) {
    if (CharacterCatalog.all[idx].locked) return;
    setState(() => _selected = idx);
    _cardCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        // ── Fondo animado ────────────────────────────────────────────────
        AnimatedBuilder(
          animation: _bgAnim,
          builder: (_, __) => CustomPaint(
            painter: _BgPainter(_bgAnim.value),
            size: Size.infinite,
          ),
        ),

        SafeArea(
          child: Column(children: [
            // ── Título ────────────────────────────────────────────────
            const SizedBox(height: 14),
            _buildTitle(),

            // ── Carrusel de personajes ────────────────────────────────
            const SizedBox(height: 10),
            Expanded(
              child: PageView.builder(
                controller: _pageCtrl,
                itemCount:  CharacterCatalog.all.length,
                onPageChanged: _selectPage,
                itemBuilder: (_, i) => _buildCard(i),
              ),
            ),

            // ── Indicadores de página ─────────────────────────────────
            _buildDots(),
            const SizedBox(height: 12),

            // ── Botón ¡JUGAR! ─────────────────────────────────────────
            _buildPlayButton(),
            const SizedBox(height: 16),
          ]),
        ),

        // ── Botón atrás ──────────────────────────────────────────────
        SafeArea(
          child: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: BackBtn(onTap: () => Navigator.of(context).pop()),
            ),
          ),
        ),
      ]),
    );
  }

  // ─── Título ──────────────────────────────────────────────────────────────
  Widget _buildTitle() => const OrnateTitle(
        eyebrow: '— ¿QUIÉN PARTIRÁ AL BOSQUE? —',
        text: 'ELIGE TU HÉROE',
      );

  // ─── Tarjeta de personaje ────────────────────────────────────────────────
  Widget _buildCard(int i) {
    final info     = CharacterCatalog.all[i];
    final isActive = i == _selected;
    final accent   = Color(info.colorValue);

    return AnimatedBuilder(
      animation: Listenable.merge([_cardScale, _float]),
      builder: (_, __) {
        final scale  = isActive ? _cardScale.value : 0.88;
        final floatY = isActive ? _float.value : 0.0;

        return Transform.scale(
          scale: scale,
          child: Transform.translate(
            offset: Offset(0, floatY),
            child: GestureDetector(
              onTap: () {
                _pageCtrl.animateToPage(i,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut);
                _selectPage(i);
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end:   Alignment.bottomRight,
                    colors: isActive
                        ? [
                            accent.withOpacity(0.25),
                            Colors.black.withOpacity(0.55),
                          ]
                        : [
                            Colors.black.withOpacity(0.35),
                            Colors.black.withOpacity(0.55),
                          ],
                  ),
                  border: Border.all(
                    color: isActive
                        ? accent.withOpacity(0.8)
                        : Colors.white.withOpacity(0.12),
                    width: isActive ? 2.5 : 1.5,
                  ),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color:      accent.withOpacity(0.35),
                            blurRadius: 28,
                            spreadRadius: 4,
                          )
                        ]
                      : [],
                ),
                child: Stack(children: [
                  // Fondo hexagonal sutil
                  Opacity(
                    opacity: 0.04,
                    child: CustomPaint(
                      painter: _MiniHex(),
                      size: Size.infinite,
                    ),
                  ),

                  // Contenido
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Emoji del personaje (grande)
                        Container(
                          width: 100, height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                accent.withOpacity(0.3),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: Center(
                            child: Text(
                              info.emoji,
                              style: const TextStyle(fontSize: 68),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Nombre
                        Text(
                          info.locked ? '???' : info.name,
                          style: TextStyle(
                            color:      Colors.white,
                            fontSize:   20,
                            fontWeight: FontWeight.w800,
                            shadows: isActive
                                ? [Shadow(color: accent, blurRadius: 12)]
                                : [],
                          ),
                        ),

                        const SizedBox(height: 6),

                        // Subtítulo / estado bloqueado
                        if (info.locked)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color:         Colors.black45,
                              borderRadius:  BorderRadius.circular(20),
                              border: Border.all(
                                  color: Colors.white24, width: 1),
                            ),
                            child: const Text(
                              '🔒 Bloqueado',
                              style: TextStyle(
                                color:    Colors.white54,
                                fontSize: 11,
                              ),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: accent.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: accent.withOpacity(0.5), width: 1),
                            ),
                            child: Text(
                              'Explorador del bosque',
                              style: TextStyle(
                                color:    accent,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                        const SizedBox(height: 16),

                        // Estadísticas visuales
                        if (!info.locked) ...[
                          _statBar('Velocidad',  0.75, accent),
                          const SizedBox(height: 6),
                          _statBar('Sigilo',     0.55, accent),
                          const SizedBox(height: 6),
                          _statBar('Exploración',0.90, accent),
                        ],
                      ],
                    ),
                  ),

                  // Badge seleccionado
                  if (isActive && !info.locked)
                    Positioned(
                      top: 12, right: 12,
                      child: Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(
                          color:  accent,
                          shape:  BoxShape.circle,
                          boxShadow: [BoxShadow(
                              color:      accent.withOpacity(0.6),
                              blurRadius: 8)],
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size:  16,
                        ),
                      ),
                    ),
                ]),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _statBar(String label, double value, Color accent) => Row(children: [
        SizedBox(
          width: 80,
          child: Text(label,
              style: TextStyle(
                color:    Colors.white.withOpacity(0.6),
                fontSize: 9.5,
              )),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(children: [
              Container(height: 6, color: Colors.black38),
              FractionallySizedBox(
                widthFactor: value,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: accent,
                    boxShadow: [
                      BoxShadow(
                        color:      accent.withOpacity(0.5),
                        blurRadius: 4,
                      )
                    ],
                  ),
                ),
              ),
            ]),
          ),
        ),
      ]);

  // ─── Puntos indicadores ──────────────────────────────────────────────────
  Widget _buildDots() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(CharacterCatalog.all.length, (i) {
      final info   = CharacterCatalog.all[i];
      final active = i == _selected;
      final accent = Color(info.colorValue);
      return AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width:  active ? 20 : 8,
        height: 8,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: active
              ? accent
              : Colors.white.withOpacity(0.25),
          boxShadow: active
              ? [BoxShadow(color: accent.withOpacity(0.5), blurRadius: 6)]
              : [],
        ),
      );
    }),
  );

  // ─── Botón JUGAR ─────────────────────────────────────────────────────────
  Widget _buildPlayButton() {
    final info   = CharacterCatalog.all[_selected];
    final locked = info.locked;
    final accent = Color(info.colorValue);

    if (locked) {
      return Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 36),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [
          Text('🔒  BLOQUEADO',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.4,
              )),
        ]),
      );
    }
    return ChunkyButton(
      label: '¡JUGAR AHORA!',
      icon: Icons.arrow_forward_rounded,
      color: accent,
      height: 58,
      wide: true,
      onTap: _confirm,
    );
  }
}

// ─── Painter: fondo verde animado ────────────────────────────────────────────
class _BgPainter extends CustomPainter {
  final double t;
  const _BgPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    // Degradado base
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end:   Alignment.bottomCenter,
          colors: [
            Color(0xFF0F2A18),
            Color(0xFF0A1A10),
            Color(0xFF050E08),
          ],
        ).createShader(rect),
    );

    // Partículas flotantes
    final paint = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    final rng   = math.Random(42);
    for (int i = 0; i < 20; i++) {
      final x   = rng.nextDouble() * size.width;
      final y   = (rng.nextDouble() + t * rng.nextDouble() * 0.3) % 1.0 * size.height;
      final a   = math.sin((t + i * 0.31) * math.pi * 2) * 0.4 + 0.4;
      final rad = 2.0 + rng.nextDouble() * 3;
      paint.color = const Color(0xFFE8B452).withOpacity(a * 0.45);
      canvas.drawCircle(Offset(x, y), rad, paint);
    }
  }

  @override
  bool shouldRepaint(_BgPainter o) => o.t != t;
}

// ─── Painter: mini hexágonos de fondo ────────────────────────────────────────
class _MiniHex extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color      = Colors.white
      ..style      = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    const r = 18.0;
    const h = r * 1.732;
    int col = 0;
    for (double x = 0; x < size.width + r * 2; x += r * 1.5) {
      for (double y = col.isEven ? 0.0 : h / 2; y < size.height + h; y += h) {
        final path = Path();
        for (int i = 0; i < 6; i++) {
          final a = math.pi / 180 * (60 * i - 30);
          i == 0
              ? path.moveTo(x + r * math.cos(a), y + r * math.sin(a))
              : path.lineTo(x + r * math.cos(a), y + r * math.sin(a));
        }
        path.close();
        canvas.drawPath(path, p);
      }
      col++;
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
