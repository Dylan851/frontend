// lib/screens/character_select_screen.dart
//
// Pantalla de selección de personaje (estilo AnimalGO: madera + dorado).
// Se muestra al pulsar "¡JUGAR!" antes de entrar al mapa.
//
// Para añadir un personaje nuevo:
//   1. Añade sus 4 sprites PNG en assets/images/player/{id}_down/left/right/up.png
//   2. Declara un CharacterInfo en CharacterCatalog.all (player_character.dart)

import 'package:flutter/material.dart';
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

  late AnimationController _cardCtrl, _floatCtrl, _glowCtrl;
  late Animation<double>   _cardScale, _float, _glow;

  final _gs = GameState();

  // Roles cortos por personaje (paralelo al catálogo).
  static const _roles = ['Explorador del bosque', 'Aventurera del río', 'Sabio ancestral'];

  // Stats por personaje (paralelo al catálogo): velocidad, sigilo, exploración.
  static const _stats = [
    [0.75, 0.55, 0.90],
    [0.85, 0.70, 0.65],
    [0.50, 0.95, 0.80],
  ];

  @override
  void initState() {
    super.initState();
    final prevIdx = CharacterCatalog.all
        .indexWhere((c) => c.id == _gs.selectedCharacter && !c.locked);
    _selected = prevIdx >= 0 ? prevIdx : 0;

    _pageCtrl = PageController(
      initialPage:  _selected,
      viewportFraction: 0.74,
    );

    _cardCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 480))
      ..forward();
    _floatCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
    _glowCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1600))
      ..repeat(reverse: true);

    _cardScale = Tween<double>(begin: 0.85, end: 1.0).animate(
        CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOutBack));
    _float = Tween<double>(begin: -3, end: 5).animate(
        CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));
    _glow = Tween<double>(begin: 0.4, end: 0.85).animate(_glowCtrl);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _cardCtrl.dispose();
    _floatCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  void _confirm() {
    final info = CharacterCatalog.all[_selected];
    if (info.locked) return;
    _gs.selectedCharacter = info.id;
    _gs.selectedSkin      = info.emoji;
    Navigator.of(context).pushReplacementNamed('/game');
  }

  void _selectPage(int idx) {
    if (CharacterCatalog.all[idx].locked) return;
    setState(() => _selected = idx);
    _cardCtrl.forward(from: 0.6);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MenuBackdrop(
        dim: 0.55,
        child: SafeArea(
          child: LayoutBuilder(builder: (ctx, c) {
            final w = c.maxWidth;
            final h = c.maxHeight;
            final s = (w / 720).clamp(0.7, 1.15);
            return Stack(children: [
              // ── Cabecera (back + título) ──────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(12 * s, 10 * s, 12 * s, 0),
                child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                  _woodBack(),
                  const Spacer(),
                  Flexible(child: _heading(s)),
                  const Spacer(),
                  SizedBox(width: 46 * s), // simetría con el back
                ]),
              ),

              // ── Carrusel de tarjetas ────────────────────────────
              Positioned.fill(
                top:    78 * s,
                bottom: 100 * s,
                child: PageView.builder(
                  controller: _pageCtrl,
                  itemCount:  CharacterCatalog.all.length,
                  onPageChanged: _selectPage,
                  itemBuilder: (_, i) => _buildCard(i, h, s),
                ),
              ),

              // ── Indicadores de página ────────────────────────────
              Positioned(
                left: 0, right: 0, bottom: 70 * s,
                child: _buildDots(),
              ),

              // ── Botón JUGAR ─────────────────────────────────────
              Positioned(
                left: 16 * s, right: 16 * s, bottom: 14 * s,
                child: _buildPlayButton(s),
              ),
            ]);
          }),
        ),
      ),
    );
  }

  // ─── Cabecera (botón atrás de madera) ───────────────────────────
  Widget _woodBack() => GestureDetector(
    onTap: () => Navigator.of(context).pop(),
    child: Container(
      width: 46, height: 42,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color(0xFF6B4423), Color(0xFF3A2210)],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: GameTone.goldTrim, width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 6, offset: const Offset(0, 3)),
        ],
      ),
      child: const Icon(Icons.arrow_back_rounded, color: GameTone.textCream, size: 22),
    ),
  );

  Widget _heading(double s) => Column(mainAxisSize: MainAxisSize.min, children: [
    Text(
      '— ¿QUIÉN PARTIRÁ AL BOSQUE? —',
      style: TextStyle(
        color: GameTone.textGold,
        fontSize: 11 * s,
        fontWeight: FontWeight.w800,
        letterSpacing: 2.2,
      ),
    ),
    SizedBox(height: 4 * s),
    Row(mainAxisSize: MainAxisSize.min, children: [
      Text('🌿', style: TextStyle(fontSize: 14 * s)),
      SizedBox(width: 8 * s),
      ShaderMask(
        shaderCallback: (b) => const LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color(0xFFFFE48A), Color(0xFFE8B452), Color(0xFFB07A2A)],
        ).createShader(b),
        child: Text(
          'ELIGE TU HÉROE',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26 * s,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.6,
            height: 1.0,
            shadows: const [
              Shadow(color: Color(0xFF1A0E04), offset: Offset(-2, 0), blurRadius: 0),
              Shadow(color: Color(0xFF1A0E04), offset: Offset(2, 0), blurRadius: 0),
              Shadow(color: Color(0xFF1A0E04), offset: Offset(0, -2), blurRadius: 0),
              Shadow(color: Color(0xFF1A0E04), offset: Offset(0, 3), blurRadius: 0),
              Shadow(color: Color(0x88000000), offset: Offset(0, 6), blurRadius: 8),
            ],
          ),
        ),
      ),
      SizedBox(width: 8 * s),
      Text('🌿', style: TextStyle(fontSize: 14 * s)),
    ]),
  ]);

  // ─── Tarjeta de personaje ───────────────────────────────────────
  Widget _buildCard(int i, double h, double s) {
    final info     = CharacterCatalog.all[i];
    final isActive = i == _selected;
    final accent   = Color(info.colorValue);
    final role     = i < _roles.length ? _roles[i] : 'Explorador';
    final stats    = i < _stats.length ? _stats[i] : const [0.7, 0.7, 0.7];

    return AnimatedBuilder(
      animation: Listenable.merge([_cardScale, _float, _glow]),
      builder: (_, __) {
        final scale  = isActive ? _cardScale.value : 0.86;
        final floatY = isActive ? _float.value : 0.0;

        return Transform.scale(
          scale: scale,
          child: Transform.translate(
            offset: Offset(0, floatY),
            child: GestureDetector(
              onTap: () {
                _pageCtrl.animateToPage(i,
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOut);
                _selectPage(i);
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 4 * s),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: isActive ? [
                    BoxShadow(
                      color: accent.withOpacity(0.35 * _glow.value),
                      blurRadius: 28,
                      spreadRadius: 2,
                    ),
                  ] : [],
                ),
                child: PixelFrame(
                  radius: 18,
                  innerFill: GameTone.panelDark,
                  padding: EdgeInsets.fromLTRB(16 * s, 16 * s, 16 * s, 14 * s),
                  child: Stack(children: [
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Avatar con medallón dorado ────────────────
                        Center(child: _avatar(info, accent, s)),

                        SizedBox(height: 14 * s),

                        // ── Nombre con gradiente dorado ───────────────
                        Center(
                          child: ShaderMask(
                            shaderCallback: (b) => LinearGradient(
                              begin: Alignment.topCenter, end: Alignment.bottomCenter,
                              colors: info.locked
                                  ? const [Color(0xFFAAAAAA), Color(0xFF666666)]
                                  : const [Color(0xFFFFE48A), Color(0xFFE8B452), Color(0xFFB07A2A)],
                            ).createShader(b),
                            child: Text(
                              info.locked ? '???' : info.name.toUpperCase(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22 * s,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.4,
                                height: 1.0,
                                shadows: const [
                                  Shadow(color: Color(0xFF1A0E04), offset: Offset(0, 2), blurRadius: 0),
                                  Shadow(color: Color(0x88000000), offset: Offset(0, 4), blurRadius: 6),
                                ],
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 8 * s),

                        // ── Chip de rol (placa de madera) ─────────────
                        Center(child: _roleChip(role, info.locked, s)),

                        SizedBox(height: 16 * s),

                        // ── Panel de stats ────────────────────────────
                        if (!info.locked)
                          _statsPanel(stats, accent, s)
                        else
                          _lockedPanel(s),

                        const Spacer(),
                      ],
                    ),

                    // Badge seleccionado (esquina sup. derecha)
                    if (isActive && !info.locked)
                      Positioned(
                        top: -2, right: -2,
                        child: _selectedBadge(s),
                      ),
                  ]),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ─── Avatar dentro de medallón con anillo dorado ────────────────
  Widget _avatar(CharacterInfo info, Color accent, double s) {
    return Container(
      width: 130 * s, height: 130 * s,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color(0xFF6B4423), Color(0xFF3A2210)],
        ),
        border: Border.all(color: GameTone.goldTrim, width: 3),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.55), blurRadius: 10, offset: const Offset(0, 5)),
          BoxShadow(color: accent.withOpacity(0.35), blurRadius: 20),
        ],
      ),
      child: Center(
        child: Container(
          width: 108 * s, height: 108 * s,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: info.locked
                  ? const [Color(0xFF2A2A2A), Color(0xFF111111)]
                  : [
                      accent.withOpacity(0.45),
                      accent.withOpacity(0.10),
                      Colors.transparent,
                    ],
              radius: 0.95,
            ),
            border: Border.all(color: GameTone.goldBright.withOpacity(0.55), width: 1.4),
          ),
          child: Center(
            child: Text(
              info.locked ? '🔒' : info.emoji,
              style: TextStyle(fontSize: 64 * s),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Chip rol (plaquita de madera con texto crema) ──────────────
  Widget _roleChip(String role, bool locked, double s) => Container(
    padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 5 * s),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Color(0xFF6B4423), Color(0xFF3A2210)],
      ),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: GameTone.goldTrim, width: 1.4),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.45), blurRadius: 5, offset: const Offset(0, 2)),
      ],
    ),
    child: Text(
      locked ? '🔒  Bloqueado' : role,
      style: TextStyle(
        color: locked ? Colors.white60 : GameTone.textCream,
        fontWeight: FontWeight.w800,
        fontSize: 11 * s,
        letterSpacing: 0.4,
        shadows: const [Shadow(color: Color(0xFF1A0E04), offset: Offset(0, 1), blurRadius: 0)],
      ),
    ),
  );

  // ─── Panel de estadísticas (3 barras con icono) ─────────────────
  Widget _statsPanel(List<double> stats, Color accent, double s) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 10 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF1A0E04).withOpacity(0.55),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: GameTone.goldTrim.withOpacity(0.5), width: 1),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        _statRow('⚡', 'Velocidad',   stats[0], accent, s),
        SizedBox(height: 6 * s),
        _statRow('🌙', 'Sigilo',      stats[1], accent, s),
        SizedBox(height: 6 * s),
        _statRow('🔍', 'Exploración', stats[2], accent, s),
      ]),
    );
  }

  Widget _statRow(String icon, String label, double value, Color accent, double s) =>
      Row(children: [
        Text(icon, style: TextStyle(fontSize: 13 * s)),
        SizedBox(width: 6 * s),
        SizedBox(
          width: 80 * s,
          child: Text(label,
              style: TextStyle(
                color: GameTone.textCream.withOpacity(0.85),
                fontSize: 10.5 * s,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              )),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(children: [
              Container(
                height: 8 * s,
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0500),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: GameTone.goldTrim.withOpacity(0.35), width: 0.8),
                ),
              ),
              FractionallySizedBox(
                widthFactor: value,
                child: Container(
                  height: 8 * s,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFFFFE48A),
                        accent,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(color: accent.withOpacity(0.55), blurRadius: 4),
                    ],
                  ),
                ),
              ),
            ]),
          ),
        ),
        SizedBox(width: 6 * s),
        SizedBox(
          width: 28 * s,
          child: Text('${(value * 100).round()}',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: GameTone.textGold,
                fontSize: 10 * s,
                fontWeight: FontWeight.w900,
              )),
        ),
      ]);

  Widget _lockedPanel(double s) => Container(
    padding: EdgeInsets.all(14 * s),
    decoration: BoxDecoration(
      color: const Color(0xFF1A0E04).withOpacity(0.55),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: GameTone.goldTrim.withOpacity(0.35), width: 1),
    ),
    child: Column(children: [
      Text('🔒', style: TextStyle(fontSize: 22 * s)),
      SizedBox(height: 6 * s),
      Text('Personaje bloqueado',
          style: TextStyle(
            color: GameTone.textCream.withOpacity(0.7),
            fontSize: 11 * s,
            fontWeight: FontWeight.w700,
          )),
      SizedBox(height: 2 * s),
      Text('Captura más animales para desbloquearlo',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: GameTone.textCream.withOpacity(0.55),
            fontSize: 9.5 * s,
          )),
    ]),
  );

  Widget _selectedBadge(double s) => Container(
    width: 36 * s, height: 36 * s,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: const LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Color(0xFF6BBA5B), Color(0xFF1F4E2A)],
      ),
      border: Border.all(color: GameTone.goldTrim, width: 2),
      boxShadow: [
        BoxShadow(color: const Color(0xFF6BE095).withOpacity(0.6), blurRadius: 12),
        BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 4, offset: const Offset(0, 2)),
      ],
    ),
    child: Icon(Icons.check_rounded, color: Colors.white, size: 20 * s),
  );

  // ─── Indicadores de página ──────────────────────────────────────
  Widget _buildDots() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(CharacterCatalog.all.length, (i) {
      final active = i == _selected;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width:  active ? 24 : 8,
        height: 8,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          gradient: active
              ? const LinearGradient(colors: [Color(0xFFFFE48A), Color(0xFFB07A2A)])
              : null,
          color: active ? null : Colors.white.withOpacity(0.22),
          border: Border.all(color: GameTone.goldTrim.withOpacity(active ? 0.9 : 0.3), width: 1),
          boxShadow: active
              ? [BoxShadow(color: GameTone.goldTrim.withOpacity(0.6), blurRadius: 6)]
              : [],
        ),
      );
    }),
  );

  // ─── Botón JUGAR ────────────────────────────────────────────────
  Widget _buildPlayButton(double s) {
    final info   = CharacterCatalog.all[_selected];
    final locked = info.locked;

    if (locked) {
      return Container(
        height: 64 * s,
        decoration: BoxDecoration(
          color: const Color(0xFF1A0E04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white24, width: 1.4),
        ),
        child: Center(
          child: Text('🔒  PERSONAJE BLOQUEADO',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 16 * s,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.6,
              )),
        ),
      );
    }
    return GestureDetector(
      onTap: _confirm,
      child: AnimatedBuilder(
        animation: _glow,
        builder: (_, __) => Container(
          height: 64 * s,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6BE095).withOpacity(0.30 + 0.25 * _glow.value),
                blurRadius: 22,
                spreadRadius: 1,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: CustomPaint(
              painter: _PlayBtnPainter(),
              child: Center(
                child: Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
                  Text('🌿', style: TextStyle(fontSize: 18 * s)),
                  SizedBox(width: 10 * s),
                  Text('¡JUGAR AHORA!',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 22 * s,
                        letterSpacing: 1.8,
                        shadows: const [
                          Shadow(color: Color(0xFF0E2C18), offset: Offset(-2, 0), blurRadius: 0),
                          Shadow(color: Color(0xFF0E2C18), offset: Offset(2, 0), blurRadius: 0),
                          Shadow(color: Color(0xFF0E2C18), offset: Offset(0, -2), blurRadius: 0),
                          Shadow(color: Color(0xFF0E2C18), offset: Offset(0, 3), blurRadius: 0),
                        ],
                      )),
                  SizedBox(width: 10 * s),
                  Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 22 * s),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayBtnPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final outer = RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(14));
    canvas.drawRRect(outer, Paint()..color = const Color(0xFF1A0E04));
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Offset(2, 2) & Size(size.width - 4, size.height - 4), const Radius.circular(12)),
      Paint()..color = GameTone.goldTrim,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Offset(5, 5) & Size(size.width - 10, size.height - 10), const Radius.circular(10)),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color(0xFF6BBA5B), Color(0xFF3A7A3A), Color(0xFF1F4E2A)],
        ).createShader(const Offset(5, 5) & Size(size.width - 10, size.height - 10)),
    );
    canvas.drawLine(
      const Offset(12, 9.5),
      Offset(size.width - 12, 9.5),
      Paint()..color = const Color(0x55FFFFFF)..strokeWidth = 1.4,
    );
  }
  @override
  bool shouldRepaint(_) => false;
}
