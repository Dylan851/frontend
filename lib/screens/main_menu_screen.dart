// lib/screens/main_menu_screen.dart
import 'package:flutter/material.dart';
import '../router/app_router.dart';
import '../theme/app_theme.dart';
import '../data/game_state.dart';
import '../data/animal_data.dart';
import 'dart:math' as math;

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});
  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> with TickerProviderStateMixin {
  late AnimationController _charCtrl, _entranceCtrl;
  late Animation<double> _charBob, _entranceFade;
  final _state = GameState();

  @override
  void initState() {
    super.initState();
    _charCtrl    = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat(reverse: true);
    _entranceCtrl= AnimationController(vsync: this, duration: const Duration(milliseconds: 600))..forward();
    _charBob     = Tween<double>(begin: 0, end: -12).animate(CurvedAnimation(parent: _charCtrl, curve: Curves.easeInOut));
    _entranceFade= Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() { _charCtrl.dispose(); _entranceCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _entranceFade,
        child: Stack(children: [
          _buildBg(),
          _buildCharacter(),
          _buildTopBar(),
          _buildLeftBtns(),
          _buildBottomBar(),
        ]),
      ),
    );
  }

  Widget _buildBg() => Stack(children: [
    Container(decoration: const BoxDecoration(gradient: LinearGradient(
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: [Color(0xFF1A6B3C), Color(0xFF2D9E5F), Color(0xFF1A6B3C), Color(0xFF0D3D20)],
      stops: [0.0, 0.3, 0.7, 1.0]))),
    Opacity(opacity: 0.04, child: CustomPaint(painter: _HexPainter(), size: const Size(double.infinity, double.infinity))),
    Positioned(bottom: 0, left: 0, right: 0, height: 120,
      child: Container(decoration: const BoxDecoration(gradient: LinearGradient(
        begin: Alignment.bottomCenter, end: Alignment.topCenter,
        colors: [Color(0xFF0A2214), Colors.transparent])))),
    const Positioned(top: 28, right: 22, child: Text('🍃', style: TextStyle(fontSize: 26, color: Colors.white38))),
    const Positioned(top: 75, left: 115, child: Text('🌿', style: TextStyle(fontSize: 20, color: Colors.white30))),
    const Positioned(bottom: 70, right: 55, child: Text('🌺', style: TextStyle(fontSize: 24, color: Colors.white38))),
  ]);

  Widget _buildCharacter() => Positioned(bottom: 50, left: 0, right: 0,
    child: AnimatedBuilder(animation: _charBob, builder: (_, __) => Transform.translate(
      offset: Offset(0, _charBob.value),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 90, height: 14, decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.35), blurRadius: 14, spreadRadius: 4)])),
        const Text('🦊', style: TextStyle(fontSize: 90)),
      ]),
    )));

  Widget _buildTopBar() => Positioned(top: 0, left: 0, right: 0,
    child: SafeArea(child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(children: [
        _glassBtn(child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 34, height: 34, decoration: BoxDecoration(shape: BoxShape.circle,
            gradient: const LinearGradient(colors: [AppColors.goldDark, Color(0xFFFF5500)]),
            border: Border.all(color: Colors.white, width: 2)),
            child: const Center(child: Text('🧑', style: TextStyle(fontSize: 19)))),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            const Text('Explorador', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            Text('⭐ Nv. 7 · ${_state.discoveredCount}/${AnimalCatalog.all.length} 🦊',
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 9.5)),
          ]),
        ])),
        const Spacer(),
        _chip('🪙', '${_state.coins}'),
        const SizedBox(width: 8),
        _chip('⭐', '${_state.score}'),
        const SizedBox(width: 10),
        _iconBtn('⚙️'),
      ]),
    )));

  Widget _buildLeftBtns() => Positioned(left: 10, top: 0, bottom: 0,
    child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      _sideBtn('🛒', 'Tienda', AppColors.goldDark.withOpacity(0.6)),
      const SizedBox(height: 10),
      _sideBtnNotify('📖', 'Animales', AppColors.collectionTeal, '${_state.discoveredCount}',
        onTap: () => Navigator.pushNamed(context, AppRouter.collection)),
      const SizedBox(height: 10),
      _sideBtn('🎯', 'Misiones', AppColors.missionYellow.withOpacity(0.6)),
    ])));

  static const collectionTeal  = Color(0xFF4ECDC4);
  static const missionYellow   = Color(0xFFFFE66D);

  Widget _buildBottomBar() => Positioned(bottom: 14, left: 88, right: 12,
    child: Row(children: [
      Expanded(child: _glassBtn(
        style: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1B5E3B), AppColors.greenBright]),
          borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 12, offset: const Offset(0,4))]),
        child: SizedBox(height: 58, child: Row(children: [
          const SizedBox(width: 12), const Text('🗺️', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('MAPA', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 8.5, letterSpacing: 1.5)),
            const Text('Selva Amazónica', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          ]),
          const Spacer(),
          Icon(Icons.chevron_right_rounded, color: Colors.white.withOpacity(0.5)),
          const SizedBox(width: 8),
        ])))),
      const SizedBox(width: 10),
      _playButton(),
    ]));

  Widget _playButton() {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRouter.game),
      child: _GlowingPlayButton(),
    );
  }

  Widget _glassBtn({required Widget child, BoxDecoration? style, VoidCallback? onTap}) =>
    GestureDetector(onTap: onTap, child: Container(
      padding: style == null ? const EdgeInsets.symmetric(horizontal: 10, vertical: 6) : EdgeInsets.zero,
      decoration: style ?? BoxDecoration(color: AppColors.overlay45, borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.borderWhite, width: 1.5)),
      child: child));

  Widget _chip(String icon, String val) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: AppColors.overlay45, borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.borderWhite, width: 1)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Text(icon, style: const TextStyle(fontSize: 13)),
      const SizedBox(width: 4),
      Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
    ]));

  Widget _iconBtn(String icon) => Container(width: 42, height: 42,
    decoration: BoxDecoration(color: AppColors.overlay45, borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.borderWhite, width: 1.5)),
    child: Center(child: Text(icon, style: const TextStyle(fontSize: 20))));

  Widget _sideBtn(String icon, String label, Color borderColor, {VoidCallback? onTap}) =>
    GestureDetector(onTap: onTap, child: Container(
      width: 66, padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(color: AppColors.overlay45, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.5)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 3),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
      ])));

  Widget _sideBtnNotify(String icon, String label, Color borderColor, String badge, {VoidCallback? onTap}) =>
    GestureDetector(onTap: onTap, child: Stack(clipBehavior: Clip.none, children: [
      Container(width: 66, padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(color: AppColors.overlay45, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor.withOpacity(0.6), width: 1.5),
          boxShadow: [BoxShadow(color: borderColor.withOpacity(0.2), blurRadius: 10, offset: const Offset(2,2))]),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 3),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        ])),
      Positioned(top: -6, right: -6, child: Container(
        width: 20, height: 20,
        decoration: BoxDecoration(color: AppColors.greenAccent, shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2)),
        child: Center(child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold))))),
    ]));
}

class _GlowingPlayButton extends StatefulWidget {
  @override State<_GlowingPlayButton> createState() => _GlowingPlayButtonState();
}
class _GlowingPlayButtonState extends State<_GlowingPlayButton> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _glow;
  @override void initState() { super.initState(); _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..repeat(reverse: true); _glow = Tween<double>(begin: 0.4, end: 1.0).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut)); }
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => AnimatedBuilder(animation: _glow, builder: (_, __) =>
    Container(height: 58, padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.greenAccent, AppColors.greenDeep]),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: AppColors.greenAccent.withOpacity(_glow.value * 0.7), blurRadius: 28),
          BoxShadow(color: Colors.black.withOpacity(0.35), blurRadius: 8, offset: const Offset(0,4))]),
      child: const Row(mainAxisSize: MainAxisSize.min, children: [
        Text('¡JUGAR!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: 1,
          shadows: [Shadow(color: Color(0xFF0A3A1A), offset: Offset(0,2), blurRadius: 4)])),
        SizedBox(width: 8),
        Icon(Icons.play_arrow_rounded, color: Colors.white, size: 26),
      ])));
}

class _HexPainter extends CustomPainter {
  @override void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 1;
    const r = 30.0; const h = r * 1.732; int col = 0;
    for (double x = 0; x < size.width + r*2; x += r*1.5) {
      for (double y = col.isEven ? 0 : h/2; y < size.height + h; y += h) {
        final path = Path();
        for (int i = 0; i < 6; i++) { final a = math.pi/180*(60*i-30); i==0?path.moveTo(x+r*math.cos(a),y+r*math.sin(a)):path.lineTo(x+r*math.cos(a),y+r*math.sin(a)); }
        path.close(); canvas.drawPath(path, p);
      }
      col++;
    }
  }
  @override bool shouldRepaint(_) => false;
}

extension on AppColors {
  static const Color collectionTeal = Color(0xFF4ECDC4);
  static const Color missionYellow  = Color(0xFFFFE66D);
}
