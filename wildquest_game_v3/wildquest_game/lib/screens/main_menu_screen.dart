// lib/screens/main_menu_screen.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../router/app_router.dart';
import '../theme/app_theme.dart';
import '../data/game_state.dart';
import '../data/animal_data.dart';
import '../data/item_data.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});
  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen>
    with TickerProviderStateMixin {
  late AnimationController _charCtrl, _fadeCtrl;
  late Animation<double> _charBob, _fade;
  final _gs = GameState();

  @override
  void initState() {
    super.initState();
    _charCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
    _fadeCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 500))
      ..forward();
    _charBob = Tween<double>(begin: 0, end: -12).animate(
        CurvedAnimation(parent: _charCtrl, curve: Curves.easeInOut));
    _fade = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _charCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _push(String route) =>
      Navigator.pushNamed(context, route).then((_) {
        if (mounted) setState(() {});
      });

  String get _mapName {
    try {
      return MapCatalog.all.firstWhere((m) => m.id == _gs.currentMapId).name;
    } catch (_) {
      return 'Selva Amazónica';
    }
  }

  String get _mapEmoji {
    try {
      return MapCatalog.all.firstWhere((m) => m.id == _gs.currentMapId).emoji;
    } catch (_) {
      return '🌲';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fade,
        child: Stack(children: [
          _bg(),
          _character(),
          _topBar(),
          _sideCol(),
          _bottomBar(),
        ]),
      ),
    );
  }

  // ── Background ──────────────────────────────────────────────────────────
  Widget _bg() => Stack(children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1A6B3C), Color(0xFF2D9E5F),
                Color(0xFF1A6B3C), Color(0xFF0D3D20),
              ],
              stops: [0.0, 0.3, 0.7, 1.0],
            ),
          ),
        ),
        Opacity(
          opacity: 0.04,
          child: CustomPaint(
            painter: _HexPainter(),
            size: const Size(double.infinity, double.infinity),
          ),
        ),
        Positioned(
          bottom: 0, left: 0, right: 0, height: 120,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Color(0xFF0A2214), Colors.transparent],
              ),
            ),
          ),
        ),
        const Positioned(top: 28, right: 22,
            child: Text('🍃', style: TextStyle(fontSize: 26, color: Colors.white38))),
        const Positioned(top: 74, left: 115,
            child: Text('🌿', style: TextStyle(fontSize: 20, color: Colors.white24))),
        const Positioned(bottom: 70, right: 54,
            child: Text('🌺', style: TextStyle(fontSize: 24, color: Colors.white38))),
        const Positioned(top: 46, right: 172,
            child: Text('🦋', style: TextStyle(fontSize: 16, color: Colors.white24))),
      ]);

  // ── Character ───────────────────────────────────────────────────────────
  Widget _character() => Positioned(
        bottom: 48, left: 0, right: 0,
        child: IgnorePointer(
          child: AnimatedBuilder(
            animation: _charBob,
            builder: (_, __) => Transform.translate(
              offset: Offset(0, _charBob.value),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 88, height: 12,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 14, spreadRadius: 4,
                    )],
                  ),
                ),
                Text(_gs.selectedSkin,
                    style: const TextStyle(fontSize: 88)),
              ]),
            ),
          ),
        ),
      );

  // ── Top Bar ─────────────────────────────────────────────────────────────
  Widget _topBar() => Positioned(
        top: 0, left: 0, right: 0,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(children: [
              // Profile pill → opens profile screen
              GestureDetector(
                onTap: () => _push(AppRouter.profile),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.overlay45,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                        color: AppColors.borderWhite, width: 1.5),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      width: 34, height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                            colors: [AppColors.goldDark, Color(0xFFFF5500)]),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Center(
                        child: Text(_gs.selectedSkin,
                            style: const TextStyle(fontSize: 19)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_gs.playerName,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                        Text(
                          '⭐ Nv.${_gs.level} · '
                          '${_gs.discoveredCount}/${AnimalCatalog.all.length} 🐾',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 9.5),
                        ),
                      ],
                    ),
                  ]),
                ),
              ),
              const Spacer(),
              CurrencyChip(icon: '🪙', value: '${_gs.coins}'),
              const SizedBox(width: 6),
              CurrencyChip(icon: '💎', value: '${_gs.gems}'),
              const SizedBox(width: 8),
              // Settings button
              GestureDetector(
                onTap: () => _push(AppRouter.settings),
                child: Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.overlay45,
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(
                        color: AppColors.borderWhite, width: 1.5),
                  ),
                  child: const Center(
                      child: Text('⚙️', style: TextStyle(fontSize: 19))),
                ),
              ),
            ]),
          ),
        ),
      );

  // ── Side column with 4 buttons ──────────────────────────────────────────
  Widget _sideCol() => Positioned(
        left: 10, top: 0, bottom: 0,
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _sideTile('🛒', 'Tienda', const Color(0xFFFF6B35),
                badge: '2',
                onTap: () => _push(AppRouter.shop)),
            const SizedBox(height: 9),
            _sideTile('📖', 'Animales', const Color(0xFF4ECDC4),
                badge: '${_gs.discoveredCount}',
                onTap: () => _push(AppRouter.collection)),
            const SizedBox(height: 9),
            _sideTile('🎯', 'Misiones', const Color(0xFFFFE66D),
                badge: '!'),
            const SizedBox(height: 9),
            _sideTile('🎒', 'Mochila', AppColors.greenAccent,
                onTap: () => _push(AppRouter.inventory)),
          ]),
        ),
      );

  Widget _sideTile(String icon, String label, Color accent,
      {String? badge, VoidCallback? onTap}) =>
    GestureDetector(
      onTap: onTap,
      child: Stack(clipBehavior: Clip.none, children: [
        Container(
          width: 66,
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: AppColors.overlay45,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: accent.withOpacity(0.6), width: 1.5),
            boxShadow: [
              BoxShadow(
                  color: accent.withOpacity(0.12),
                  blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 3),
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800),
                textAlign: TextAlign.center),
          ]),
        ),
        if (badge != null)
          Positioned(
            top: -6, right: -6,
            child: Container(
              width: 20, height: 20,
              decoration: BoxDecoration(
                color: badge == '!'
                    ? const Color(0xFFFF6B35)
                    : AppColors.greenAccent,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Center(
                child: Text(badge,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 7.5,
                        fontWeight: FontWeight.w900)),
              ),
            ),
          ),
      ]),
    );

  // ── Bottom Bar ──────────────────────────────────────────────────────────
  Widget _bottomBar() => Positioned(
        bottom: 14, left: 88, right: 12,
        child: Row(children: [
          // Map selector pill
          Expanded(
            child: GestureDetector(
              onTap: () => _push(AppRouter.mapSelect),
              child: Container(
                height: 58,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF1B5E3B), AppColors.greenBright]),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.2), width: 1.5),
                  boxShadow: [BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4))],
                ),
                child: Row(children: [
                  Text(_mapEmoji,
                      style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('SELECCIONAR MAPA',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.55),
                              fontSize: 7.5,
                              letterSpacing: 1.5)),
                      Text(_mapName,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 13)),
                    ],
                  ),
                  const Spacer(),
                  Icon(Icons.chevron_right_rounded,
                      color: Colors.white.withOpacity(0.4)),
                ]),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Play button
          GestureDetector(
            onTap: () => _push(AppRouter.game),
            child: const _GlowingPlayButton(),
          ),
        ]),
      );
}

// ─── Glowing play button ────────────────────────────────────────────────────
class _GlowingPlayButton extends StatefulWidget {
  const _GlowingPlayButton();
  @override
  State<_GlowingPlayButton> createState() => _GlowingPlayButtonState();
}

class _GlowingPlayButtonState extends State<_GlowingPlayButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _g;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 1600))
      ..repeat(reverse: true);
    _g = Tween<double>(begin: 0.4, end: 1.0)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
  }
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _g,
        builder: (_, __) => Container(
          height: 58,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [AppColors.greenAccent, AppColors.greenDeep]),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: AppColors.greenAccent.withOpacity(_g.value * 0.7),
                  blurRadius: 28),
              BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Text('¡JUGAR!',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    letterSpacing: 1,
                    shadows: [
                      Shadow(color: Color(0xFF0A3A1A),
                          offset: Offset(0, 2), blurRadius: 4)
                    ])),
            SizedBox(width: 8),
            Icon(Icons.play_arrow_rounded, color: Colors.white, size: 26),
          ]),
        ),
      );
}

// ─── Hex background painter ─────────────────────────────────────────────────
class _HexPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    const r = 30.0;
    const h = r * 1.732;
    int col = 0;
    for (double x = 0; x < size.width + r * 2; x += r * 1.5) {
      for (double y = col.isEven ? 0.0 : h / 2;
          y < size.height + h;
          y += h) {
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
