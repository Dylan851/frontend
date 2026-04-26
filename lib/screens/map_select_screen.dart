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
    with TickerProviderStateMixin {
  final _gs = GameState();
  String? _selectedId;
  late final AnimationController _fadeCtrl;
  late final AnimationController _raysCtrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _selectedId = _gs.currentMapId;
    _fadeCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 400))..forward();
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _raysCtrl = AnimationController(vsync: this,
        duration: const Duration(seconds: 22))..repeat();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _raysCtrl.dispose();
    super.dispose();
  }

  bool _canUnlock(MapWorld m) => _gs.level >= m.requiredLevel;

  void _selectMap(MapWorld m) {
    if (!_canUnlock(m)) return;
    setState(() => _selectedId = m.id);
    _gs.currentMapId = m.id;
  }

  void _confirmAndGo() => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.forestNight,
      body: FadeTransition(
        opacity: _fade,
        child: Stack(children: [
          // Pixel-art forest frame background
          Positioned.fill(
            child: Image.asset(
              'assets/images/backgrounds/map_select_bg.png',
              fit: BoxFit.cover,
              filterQuality: FilterQuality.none, // preserve pixel art
            ),
          ),
          // Slight darken so UI text reads
          Positioned.fill(child: Container(color: const Color(0x33000000))),
          // Bottom shadow vignette
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: Container(
              height: 200,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xCC020906)],
                ),
              ),
            ),
          ),

          // Top bar
          _topBar(),

          // Title block
          Positioned(
            top: 70, left: 0, right: 0,
            child: const OrnateTitle(
              eyebrow: '— ELIGE TU DESTINO —',
              text: 'MUNDOS POR EXPLORAR',
            ),
          ),

          // Grid of maps
          Positioned(
            top: 130, left: 12, right: 12, bottom: 110,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.95,
              ),
              itemCount: MapCatalog.all.length,
              itemBuilder: (_, i) {
                final m = MapCatalog.all[i];
                return _MapCard(
                  map: m,
                  isSelected: m.id == _selectedId,
                  isUnlocked: _canUnlock(m),
                  isCurrent: m.id == _gs.currentMapId,
                  onTap: () => _selectMap(m),
                );
              },
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(children: [
          const BackBtn(),
          const Spacer(),
          CurrencyChip(icon: '⭐', value: 'NV.${_gs.level}'),
          const SizedBox(width: 8),
          CurrencyChip(icon: '🪙', value: '${_gs.coins}'),
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
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: WoodPanel(
            padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
            child: Row(children: [
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [sel.primaryColor, sel.secondaryColor.withOpacity(0.6)],
                  ),
                  border: Border.all(color: AppColors.amber.withOpacity(0.7), width: 2),
                ),
                child: Center(child: Text(sel.emoji, style: const TextStyle(fontSize: 22))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min, children: [
                  Text(sel.name.toUpperCase(),
                      style: const TextStyle(
                          color: AppColors.parchment,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          letterSpacing: 1.6)),
                  const SizedBox(height: 2),
                  Text('${sel.animalsCount} ANIMALES · ${sel.itemsCount} ÍTEMS',
                      style: TextStyle(
                          color: AppColors.amber.withOpacity(0.85),
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2)),
                ]),
              ),
              const SizedBox(width: 10),
              ChunkyButton(
                label: '¡ELEGIR!',
                onTap: _confirmAndGo,
                height: 46,
                color: AppColors.emeraldGlow,
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

// ─── Map card ───────────────────────────────────────────────────────────
class _MapCard extends StatelessWidget {
  final MapWorld map;
  final bool isSelected;
  final bool isUnlocked;
  final bool isCurrent;
  final VoidCallback onTap;
  const _MapCard({
    required this.map,
    required this.isSelected,
    required this.isUnlocked,
    required this.isCurrent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected
        ? AppColors.amber
        : (isUnlocked ? AppColors.amber.withOpacity(0.35) : Colors.white.withOpacity(0.08));
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: isSelected ? 2.5 : 1.5),
          boxShadow: [
            if (isSelected)
              BoxShadow(color: AppColors.amber.withOpacity(0.45), blurRadius: 22),
            BoxShadow(
              color: AppColors.leafShadow.withOpacity(0.55),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(children: [
            // Card painted background
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isUnlocked
                        ? [map.primaryColor, map.secondaryColor]
                        : [
                            Color.lerp(map.primaryColor, Colors.black, 0.65)!,
                            Color.lerp(map.secondaryColor, Colors.black, 0.7)!,
                          ],
                  ),
                ),
              ),
            ),
            // Subtle leaf overlay
            const Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: LeafLatticePainter(opacity: 0.07)),
              ),
            ),
            // Bottom dark scrim
            Positioned(
              bottom: 0, left: 0, right: 0, height: 90,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xCC02100A)],
                  ),
                ),
              ),
            ),
            // Big radial halo behind emoji
            Positioned(
              top: -12, left: -12,
              child: Container(
                width: 130, height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(isUnlocked ? 0.18 : 0.04),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Hero emoji
            Positioned(
              top: 24, left: 22,
              child: Text(
                map.emoji,
                style: TextStyle(
                  fontSize: 56,
                  color: isUnlocked
                      ? Colors.white
                      : Colors.white.withOpacity(0.3),
                  shadows: [
                    Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 8, offset: const Offset(0, 4)),
                  ],
                ),
              ),
            ),
            // Lock overlay
            if (!isUnlocked)
              Container(color: Colors.black.withOpacity(0.4)),
            if (!isUnlocked)
              const Center(child: Text('🔒', style: TextStyle(fontSize: 38))),
            // "ACTUAL" ribbon
            if (isCurrent && isUnlocked)
              const Positioned(
                top: 16, right: -22,
                child: CornerRibbon(label: 'ACTUAL'),
              ),
            // Bottom info
            Positioned(
              bottom: 10, left: 12, right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    map.name.toUpperCase(),
                    style: TextStyle(
                      color: isUnlocked
                          ? AppColors.parchment
                          : Colors.white.withOpacity(0.45),
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      letterSpacing: 1.6,
                      shadows: const [
                        Shadow(color: Color(0xFF000000), blurRadius: 6, offset: Offset(0, 2)),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isUnlocked
                          ? AppColors.amber.withOpacity(0.85)
                          : const Color(0xFFFF6B35).withOpacity(0.85),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isUnlocked
                          ? '${map.animalsCount} ANIMALES'
                          : '🔒 NV. ${map.requiredLevel}',
                      style: const TextStyle(
                        color: Color(0xFF221208),
                        fontWeight: FontWeight.w900,
                        fontSize: 9,
                        letterSpacing: 1.0,
                      ),
                    ),
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
