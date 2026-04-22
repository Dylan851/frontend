// lib/screens/map_select_screen.dart
import 'package:flutter/material.dart';
import '../data/item_data.dart';
import '../data/game_state.dart';
import '../theme/app_theme.dart';

class MapSelectScreen extends StatefulWidget {
  const MapSelectScreen({super.key});
  @override
  State<MapSelectScreen> createState() => _MapSelectScreenState();
}

class _MapSelectScreenState extends State<MapSelectScreen>
    with SingleTickerProviderStateMixin {
  final _gs = GameState();
  String? _selectedId;
  late AnimationController _fadeCtrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _selectedId = _gs.currentMapId;
    _fadeCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 400))
      ..forward();
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() { _fadeCtrl.dispose(); super.dispose(); }

  bool _canUnlock(MapWorld map) => _gs.level >= map.requiredLevel;

  void _selectMap(MapWorld map) {
    if (!_canUnlock(map)) return;
    setState(() => _selectedId = map.id);
    _gs.currentMapId = map.id;
  }

  void _confirmAndGo() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fade,
        child: Stack(children: [
          // Starfield bg
          _StarfieldBg(),
          // Top bar
          _topBar(),
          // Grid of maps
          Positioned(
            top: 56, left: 10, right: 10, bottom: 58,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.35,
              ),
              itemCount: MapCatalog.all.length,
              itemBuilder: (_, i) => _MapCard(
                map: MapCatalog.all[i],
                isSelected: MapCatalog.all[i].id == _selectedId,
                isUnlocked: _canUnlock(MapCatalog.all[i]),
                onTap: () => _selectMap(MapCatalog.all[i]),
              ),
            ),
          ),
          // Bottom confirm bar
          _bottomBar(),
        ]),
      ),
    );
  }

  Widget _topBar() => Positioned(
        top: 0, left: 0, right: 0,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(children: [
              BackBtn(),
              const SizedBox(width: 10),
              const Text('🗺️  Seleccionar Mundo',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 17)),
              const Spacer(),
              CurrencyChip(icon: '⭐', value: 'Nv.${_gs.level}'),
            ]),
          ),
        ),
      );

  Widget _bottomBar() {
    final sel = MapCatalog.all.firstWhere(
        (m) => m.id == _selectedId,
        orElse: () => MapCatalog.all.first);
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
          ),
        ),
        child: Row(children: [
          Text(sel.emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, children: [
            Text(sel.name,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13)),
            Text('${sel.animalsCount} animales · ${sel.itemsCount} ítems',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.55), fontSize: 10)),
          ]),
          const Spacer(),
          GestureDetector(
            onTap: _confirmAndGo,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppColors.greenAccent, AppColors.greenDeep]),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(
                    color: AppColors.greenAccent.withOpacity(0.4),
                    blurRadius: 14)],
              ),
              child: const Text('¡Elegir!',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 14)),
            ),
          ),
        ]),
      ),
    );
  }
}

// ─── Map card ───────────────────────────────────────────────────────────────
class _MapCard extends StatelessWidget {
  final MapWorld map;
  final bool isSelected;
  final bool isUnlocked;
  final VoidCallback onTap;

  const _MapCard({
    required this.map,
    required this.isSelected,
    required this.isUnlocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        // Sin transform.scale → evita que la tarjeta seleccionada se monte
        // sobre las vecinas. La selección se indica sólo con borde + glow.
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.greenAccent
                : Colors.white.withOpacity(0.1),
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(
                  color: AppColors.greenAccent.withOpacity(0.35),
                  blurRadius: 16)]
              : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: Stack(children: [
            // Card background gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isUnlocked
                      ? [map.primaryColor, map.secondaryColor]
                      : [
                          Color.lerp(map.primaryColor, Colors.black, 0.5)!,
                          Color.lerp(map.secondaryColor, Colors.black, 0.5)!,
                        ],
                ),
              ),
            ),
            // Dark overlay for locked
            if (!isUnlocked)
              Container(color: Colors.black.withOpacity(0.45)),
            // Bottom gradient scrim
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.75),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Main emoji
            Positioned(
              top: 10, left: 10,
              child: Text(map.emoji,
                  style: TextStyle(
                      fontSize: 28,
                      color: isUnlocked
                          ? Colors.white
                          : Colors.white.withOpacity(0.3))),
            ),
            // "ACTUAL" badge
            if (map.id == GameState().currentMapId && isUnlocked)
              Positioned(
                top: 8, right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.greenAccent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('ACTUAL',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 7,
                          fontWeight: FontWeight.w900)),
                ),
              ),
            // Lock icon
            if (!isUnlocked)
              Positioned(
                top: 8, right: 8,
                child: Container(
                  width: 22, height: 22,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.2), width: 1),
                  ),
                  child: const Center(
                      child: Text('🔒', style: TextStyle(fontSize: 11))),
                ),
              ),
            // Text info
            Positioned(
              bottom: 7, left: 8, right: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(map.name,
                      style: TextStyle(
                          color: isUnlocked
                              ? Colors.white
                              : Colors.white.withOpacity(0.4),
                          fontWeight: FontWeight.w800,
                          fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text(
                    isUnlocked
                        ? '${map.animalsCount} animales'
                        : '🔒 Nv. ${map.requiredLevel}',
                    style: TextStyle(
                        color: isUnlocked
                            ? Colors.white.withOpacity(0.6)
                            : const Color(0xFFFF6B35),
                        fontSize: 9,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ─── Starfield background ────────────────────────────────────────────────────
class _StarfieldBg extends StatefulWidget {
  @override
  State<_StarfieldBg> createState() => _StarfieldBgState();
}

class _StarfieldBgState extends State<_StarfieldBg>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this,
        duration: const Duration(seconds: 4))
      ..repeat(reverse: true);
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0A1E2E), Color(0xFF0D2B3A), Color(0xFF091520)],
        ),
      ),
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) => CustomPaint(
          painter: _StarsPainter(_c.value),
          size: const Size(double.infinity, double.infinity),
        ),
      ),
    );
  }
}

class _StarsPainter extends CustomPainter {
  final double t;
  static const _stars = [
    [0.15, 0.08, 2.0], [0.70, 0.20, 3.0], [0.40, 0.35, 2.0],
    [0.85, 0.50, 2.0], [0.55, 0.10, 3.0], [0.25, 0.65, 2.0],
    [0.60, 0.75, 2.0], [0.10, 0.45, 1.5], [0.90, 0.30, 1.5],
    [0.33, 0.15, 2.5], [0.77, 0.80, 2.0], [0.50, 0.55, 1.5],
  ];

  const _StarsPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < _stars.length; i++) {
      final s = _stars[i];
      final phase = (t + i * 0.17) % 1.0;
      final alpha = (0.5 + 0.5 * _sin(phase * 6.28)).clamp(0.1, 1.0);
      canvas.drawCircle(
        Offset(s[0] * size.width, s[1] * size.height),
        s[2],
        Paint()..color = Colors.white.withOpacity(alpha),
      );
    }
  }

  static double _sin(double x) {
    // simple sin approximation
    double r = x, t = x;
    for (int i = 1; i <= 5; i++) {
      t *= -x * x / ((2 * i) * (2 * i + 1));
      r += t;
    }
    return r;
  }

  @override
  bool shouldRepaint(_StarsPainter o) => o.t != t;
}
