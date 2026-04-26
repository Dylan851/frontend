// lib/screens/main_menu_screen.dart
//
// Adaptive layout (works on phone landscape, tablet, desktop):
//   ┌─ profile ───────────────────────── coins · gems · ⚙ ─┐
//   │                                                       │
//   │              ┌── WildQuest ──┐                        │
//   │                                                       │
//   │   Tienda     Animales                                 │
//   │   Misiones   Mochila                                  │
//   │                                                       │
//   │  ┌─ Mundo seleccionado ───┐    ┌── ¡JUGAR! ──┐        │
//   └──┘                        └────┘             └────────┘
//
import 'package:flutter/material.dart';
import '../router/app_router.dart';
import '../theme/app_theme.dart';
import '../data/game_state.dart';
import '../data/animal_data.dart';
import '../data/item_data.dart';
import '../game/overlays/tutorial_overlay.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});
  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  final _gs = GameState();
  bool _showTutorial = false;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500))
      ..forward();
    if (!_gs.hasSeenAppTutorial) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _showTutorial = true);
      });
    }
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _push(String r) =>
      Navigator.pushNamed(context, r).then((_) {
        if (mounted) setState(() {});
      });

  String get _mapName {
    try { return MapCatalog.all.firstWhere((m) => m.id == _gs.currentMapId).name; }
    catch (_) { return 'Aldea Canta'; }
  }
  String get _mapEmoji {
    try { return MapCatalog.all.firstWhere((m) => m.id == _gs.currentMapId).emoji; }
    catch (_) { return '🗺️'; }
  }
  int get _mapAnimals {
    try { return MapCatalog.all.firstWhere((m) => m.id == _gs.currentMapId).animalsCount; }
    catch (_) { return 6; }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeCtrl,
        child: Stack(children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/backgrounds/main_menu_bg.png',
              fit: BoxFit.cover,
              filterQuality: FilterQuality.none,
            ),
          ),
          Positioned.fill(child: Container(color: const Color(0x33000000))),

          SafeArea(
            child: LayoutBuilder(builder: (context, c) {
              final w = c.maxWidth;
              final h = c.maxHeight;
              // scale UI to fit small phones
              final scale = (w / 720).clamp(0.65, 1.15);
              return _buildContent(w, h, scale.toDouble());
            }),
          ),

          if (_showTutorial)
            TutorialOverlay(onFinish: () {
              _gs.hasSeenAppTutorial = true;
              _gs.autosave();
              setState(() => _showTutorial = false);
            }),
        ]),
      ),
    );
  }

  Widget _buildContent(double w, double h, double s) {
    final pad = 12.0 * s;
    return Stack(children: [
      // ─ Top-left: profile pill
      Positioned(top: pad, left: pad, child: _profileCard(s)),

      // ─ Top-right: coins / gems / settings
      Positioned(top: pad + 4, right: pad, child: Row(children: [
        OvalGoldChip(icon: '🪙', value: '${_gs.coins}'),
        SizedBox(width: 8 * s),
        OvalGoldChip(icon: '💎', value: '${_gs.gems}'),
        SizedBox(width: 8 * s),
        _settingsBtn(s),
      ])),

      // ─ Centered WildQuest logo (top-center)
      Positioned(
        top: pad + 4,
        left: 0, right: 0,
        child: IgnorePointer(
          child: Center(child: GameLogo(
            title: 'AnimalGO!',
            subtitle: '🌿  Descubre el mundo animal  🌿',
            fontSize: (w < 520 ? 38 : 56) * s,
          )),
        ),
      ),

      // ─ Side menu (left), vertically centered between profile and bottom row
      Positioned(
        top: pad + 90 * s,
        bottom: pad + 100 * s,
        left: pad,
        child: Center(child: _menuGrid(s, w)),
      ),

      // ─ Bottom-left: map card
      Positioned(left: pad, bottom: pad, child: _mapCard(s, w)),

      // ─ Bottom-right: ¡JUGAR!
      Positioned(right: pad, bottom: pad, child: _playButton(s, w)),
    ]);
  }

  // ── Profile pill (compact, mobile-friendly) ─────────────────────────
  Widget _profileCard(double s) => GestureDetector(
    onTap: () => _push(AppRouter.profile),
    child: SizedBox(
      width: 200 * s, height: 64 * s,
      child: PixelFrame(
        radius: 12,
        padding: EdgeInsets.fromLTRB(6 * s, 5 * s, 8 * s, 5 * s),
        child: Row(children: [
          Container(
            width: 42 * s, height: 42 * s,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(colors: [
                Color(0xFFFFE48A), Color(0xFFB07A2A),
              ]),
              border: Border.all(color: GameTone.goldTrim, width: 1.6),
            ),
            child: Center(child: Text(_gs.selectedSkin, style: TextStyle(fontSize: 24 * s))),
          ),
          SizedBox(width: 7 * s),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_gs.playerName,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: GameTone.textCream,
                    fontWeight: FontWeight.w900,
                    fontSize: 13 * s,
                    height: 1.0,
                    shadows: const [Shadow(color: Color(0xFF1A0E04), offset: Offset(0, 2), blurRadius: 0)],
                  )),
              SizedBox(height: 2 * s),
              Text('Nv. ${_gs.level}',
                  style: TextStyle(
                    color: GameTone.textGold,
                    fontWeight: FontWeight.w800,
                    fontSize: 10 * s,
                  )),
              SizedBox(height: 3 * s),
              Row(children: [
                Text('⭐', style: TextStyle(fontSize: 9 * s)),
                SizedBox(width: 3 * s),
                Expanded(child: Container(
                  height: 6 * s,
                  decoration: BoxDecoration(
                    color: GameTone.woodOuter,
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(color: GameTone.goldTrim.withOpacity(0.7), width: 0.7),
                  ),
                  child: FractionallySizedBox(
                    widthFactor: AnimalCatalog.all.isEmpty ? 0 : (_gs.discoveredCount / AnimalCatalog.all.length),
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [
                          Color(0xFFF6C76B), Color(0xFFD4A04A),
                        ]),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                )),
                SizedBox(width: 4 * s),
                Text('${_gs.discoveredCount}/${AnimalCatalog.all.length}',
                    style: TextStyle(
                      color: GameTone.textCream,
                      fontWeight: FontWeight.w800,
                      fontSize: 9 * s,
                    )),
              ]),
            ],
          )),
        ]),
      ),
    ),
  );

  Widget _settingsBtn(double s) => GestureDetector(
    onTap: () => _push(AppRouter.settings),
    child: Container(
      width: 38 * s, height: 38 * s,
      decoration: BoxDecoration(
        color: GameTone.woodOuter,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: GameTone.goldTrim, width: 1.4),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Center(child: Text('⚙️', style: TextStyle(fontSize: 18 * s))),
    ),
  );

  // ── Vertical menu column (left-aligned) ─────────────────────────────
  Widget _menuGrid(double s, double w) {
    final btnW = (w < 520 ? 210.0 : 250.0) * s;
    final gap  = 12.0 * s;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MenuPill(icon: '🛒', label: 'Tienda',   width: btnW, onTap: () => _push(AppRouter.shop)),
        SizedBox(height: gap),
        MenuPill(icon: '📖', label: 'Animales', width: btnW, onTap: () => _push(AppRouter.collection)),
        SizedBox(height: gap),
        MenuPill(icon: '🎯', label: 'Misiones', width: btnW, onTap: () => _push(AppRouter.missions)),
        SizedBox(height: gap),
        MenuPill(icon: '🎒', label: 'Mochila',  width: btnW, onTap: () => _push(AppRouter.inventory)),
      ],
    );
  }

  // ── Bottom-left: Mundo seleccionado card ────────────────────────────
  Widget _mapCard(double s, double w) {
    final cardW = (w < 520 ? 240.0 : 380.0) * s;
    return GestureDetector(
      onTap: () => _push(AppRouter.mapSelect),
      child: SizedBox(
        width: cardW, height: 86 * s,
        child: PixelFrame(
          radius: 12,
          padding: EdgeInsets.fromLTRB(6 * s, 5 * s, 12 * s, 5 * s),
          child: Row(children: [
            Container(
              width: 60 * s, height: 60 * s,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: GameTone.goldTrim, width: 1.4),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Color(0xFF6BBA5B), Color(0xFF1F4E2A)],
                ),
              ),
              child: Center(child: Text(_mapEmoji, style: TextStyle(fontSize: 30 * s))),
            ),
            SizedBox(width: 10 * s),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('🌿  MUNDO SELECCIONADO',
                    style: TextStyle(
                      color: GameTone.textGold,
                      fontWeight: FontWeight.w800,
                      fontSize: 10 * s,
                      letterSpacing: 1.2,
                    )),
                SizedBox(height: 3 * s),
                Text(_mapName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: GameTone.textCream,
                      fontWeight: FontWeight.w900,
                      fontSize: 18 * s,
                      height: 1.0,
                      shadows: const [Shadow(color: Color(0xFF1A0E04), offset: Offset(0, 2), blurRadius: 0)],
                    )),
                SizedBox(height: 3 * s),
                Container(height: 1, color: GameTone.goldTrim.withOpacity(0.4)),
                SizedBox(height: 3 * s),
                Text('$_mapAnimals animales 🌳',
                    style: TextStyle(
                      color: GameTone.textCream.withOpacity(0.85),
                      fontSize: 11 * s,
                      fontWeight: FontWeight.w700,
                    )),
              ],
            )),
          ]),
        ),
      ),
    );
  }

  // ── Bottom-right: ¡JUGAR! button ────────────────────────────────────
  Widget _playButton(double s, double w) {
    final btnW = (w < 520 ? 180.0 : 240.0) * s;
    return GestureDetector(
      onTap: () => _push(AppRouter.characterSelect),
      child: SizedBox(
        width: btnW,
        height: 86 * s,
        child: const _PlayBtnInline(),
      ),
    );
  }
}

// Inline version of JUGAR that fills its parent height/width.
class _PlayBtnInline extends StatefulWidget {
  const _PlayBtnInline();
  @override
  State<_PlayBtnInline> createState() => _PlayBtnInlineState();
}

class _PlayBtnInlineState extends State<_PlayBtnInline>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
  }
  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6BE095).withOpacity(0.3 + 0.3 * _c.value),
              blurRadius: 22, spreadRadius: 1,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: CustomPaint(
            painter: _GreenButtonPainterInline(),
            child: Center(
              child: Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: const [
                Text('🌿', style: TextStyle(fontSize: 18)),
                SizedBox(width: 6),
                Text('¡JUGAR!',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                      letterSpacing: 1.6,
                      shadows: [
                        Shadow(color: Color(0xFF0E2C18), offset: Offset(-2, 0), blurRadius: 0),
                        Shadow(color: Color(0xFF0E2C18), offset: Offset(2, 0), blurRadius: 0),
                        Shadow(color: Color(0xFF0E2C18), offset: Offset(0, -2), blurRadius: 0),
                        Shadow(color: Color(0xFF0E2C18), offset: Offset(0, 3), blurRadius: 0),
                      ],
                    )),
                SizedBox(width: 6),
                Text('🌿', style: TextStyle(fontSize: 18)),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class _GreenButtonPainterInline extends CustomPainter {
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
      const Offset(10, 8.5),
      Offset(size.width - 10, 8.5),
      Paint()..color = const Color(0x55FFFFFF)..strokeWidth = 1.4,
    );
  }
  @override
  bool shouldRepaint(_) => false;
}
