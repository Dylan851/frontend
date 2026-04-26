// lib/screens/inventory_screen.dart
import 'package:flutter/material.dart';
import '../data/item_data.dart';
import '../data/game_state.dart';
import '../theme/app_theme.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});
  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen>
    with SingleTickerProviderStateMixin {
  final _gs = GameState();
  String _selectedCat = 'all';
  ShopItem? _focusedItem;

  static const _cats = [
    ('all',     'Todo'),
    ('food',    '🍎 Comida'),
    ('gear',    '🛡️ Equipo'),
    ('powerup', '✨ Power-Ups'),
  ];

  static const _equipSlots = [
    ('head',  '🎩', 'Cabeza'),
    ('hands', '🧤', 'Manos'),
    ('body',  '👕', 'Cuerpo'),
    ('feet',  '👢', 'Pies'),
  ];

  List<MapEntry<String, int>> get _filteredItems {
    final all = _gs.inventory.entries.toList();
    if (_selectedCat == 'all') return all;
    return all.where((e) {
      final item = ShopCatalog.findById(e.key);
      if (item == null) return false;
      switch (_selectedCat) {
        case 'food':    return item.category == ItemCategory.food;
        case 'gear':    return item.category == ItemCategory.gear;
        case 'powerup': return item.category == ItemCategory.powerup;
        default:        return true;
      }
    }).toList();
  }

  void _useItem(String id) {
    final item = ShopCatalog.findById(id);
    if (item == null || !item.isUsableFromBag) {
      _showMsg('Este ítem no se puede usar directamente.');
      return;
    }
    // Power-ups: se activan para el próximo minijuego (no se consumen aquí
    // si ya estaban activos). activatePowerUp consume 1.
    if (item.isMinigamePowerUp) {
      final ok = _gs.activatePowerUp(id);
      _showMsg(ok
          ? '${item.emoji} ${item.name} listo para el próximo minijuego'
          : 'Ya está activo o no queda ninguno');
      setState(() => _focusedItem = null);
      return;
    }
    // Efectos inmediatos (comida, etc.).
    _gs.useItem(id);
    switch (item.effect) {
      case ItemEffect.restoreHealth:
        _showMsg('+${item.magnitude} ❤️ salud restaurada!');
        break;
      case ItemEffect.restoreEnergy:
        _showMsg('+${item.magnitude} ⚡ energía restaurada!');
        break;
      case ItemEffect.speedBoost:
        _showMsg('+${item.magnitude}% velocidad temporal!');
        break;
      case ItemEffect.radarAnimals:
        _showMsg('📡 Radar activo: animales cercanos visibles');
        break;
      default:
        _showMsg('${item.emoji} usado');
    }
    setState(() => _focusedItem = null);
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: const TextStyle(
              fontWeight: FontWeight.w800, color: Colors.white)),
      backgroundColor: AppColors.greenDeep,
      duration: const Duration(milliseconds: 1500),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(12),
    ));
  }

  int get _totalSlots => 24;
  int get _usedSlots => _gs.inventory.values.fold(0, (a, b) => a + (b > 0 ? 1 : 0));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1A10),
      body: MenuBackdrop(
        dim: 0.55,
        child: Stack(children: [
          SafeArea(
            child: Column(children: [
              _topBar(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                    SizedBox(width: 160, child: _leftPanel()),
                    const SizedBox(width: 10),
                    Expanded(child: Column(children: [
                      _catFilter(),
                      const SizedBox(height: 6),
                      Expanded(child: _itemGrid()),
                      const SizedBox(height: 8),
                      _statsBar(),
                    ])),
                  ]),
                ),
              ),
            ]),
          ),
          // Item detail popup
          if (_focusedItem != null) _itemDetailPopup(),
        ]),
      ),
    );
  }

  Widget _topBar() => GameHeader(
        title: 'Mochila',
        trailing: [
          WoodChip(icon: '🎒', label: '$_usedSlots/$_totalSlots slots'),
        ],
      );

  // ── Left panel ─────────────────────────────────────────────────────────
  Widget _leftPanel() => PixelFrame(
        radius: 14,
        padding: const EdgeInsets.all(8),
        child: Column(children: [
          // Character portrait
          Expanded(
            child: Center(
              child: Text(_gs.selectedSkin, style: const TextStyle(fontSize: 70)),
            ),
          ),
          // Level badge
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Color(0xFF6BBA5B), Color(0xFF1F4E2A)],
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: GameTone.goldTrim, width: 1.4),
            ),
            child: Text('Nv. ${_gs.level}',
                style: const TextStyle(
                  color: GameTone.textCream,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  letterSpacing: 0.6,
                  shadows: [Shadow(color: Color(0xFF1A0E04), offset: Offset(0, 2), blurRadius: 0)],
                )),
          ),
          // Equip slots 2×2
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
            childAspectRatio: 1.0,
            physics: const NeverScrollableScrollPhysics(),
            children: _equipSlots.map((slot) {
              final equippedId = _gs.equipped[slot.$1];
              final item = equippedId != null
                  ? ShopCatalog.findById(equippedId)
                  : null;
              return Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Color(0xFF6B4423), Color(0xFF3A2210)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: GameTone.goldTrim.withOpacity(0.7), width: 1.2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(item?.emoji ?? slot.$2,
                        style: TextStyle(
                            fontSize: 22,
                            color: item != null
                                ? null
                                : GameTone.textCream.withOpacity(0.55))),
                    const SizedBox(height: 2),
                    Text(slot.$3,
                        style: const TextStyle(
                            fontSize: 9,
                            color: GameTone.textCream,
                            fontWeight: FontWeight.w800)),
                  ],
                ),
              );
            }).toList(),
          ),
        ]),
      );

  // ── Category filter ─────────────────────────────────────────────────────
  Widget _catFilter() => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _cats.map((c) {
            final active = _selectedCat == c.$1;
            // Split label "🍎 Comida" → icon + label
            final parts = c.$2.split(' ');
            final hasEmoji = parts.length > 1 && parts.first.isNotEmpty;
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: WoodTab(
                icon: hasEmoji ? parts.first : '🌿',
                label: hasEmoji ? parts.sublist(1).join(' ') : c.$2,
                active: active,
                onTap: () => setState(() => _selectedCat = c.$1),
              ),
            );
          }).toList(),
        ),
      );

  // ── Item grid ───────────────────────────────────────────────────────────
  Widget _itemGrid() {
    final items = _filteredItems;
    // Fill to multiple of 5
    final padded = List<MapEntry<String, int>?>.from(items);
    while (padded.length % 5 != 0) padded.add(null);

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
      ),
      itemCount: padded.length,
      itemBuilder: (_, i) {
        final e = padded[i];
        if (e == null) return _emptySlot();
        final item = ShopCatalog.findById(e.key);
        return _invSlot(item, e.value);
      },
    );
  }

  Widget _invSlot(ShopItem? item, int qty) {
    if (item == null) return _emptySlot();
    return GestureDetector(
      onTap: () => setState(() => _focusedItem = item),
      child: PixelFrame(
        radius: 10,
        innerFill: const Color(0xFF1F3A1F),
        padding: const EdgeInsets.all(2),
        child: Stack(children: [
          Center(child: Text(item.emoji, style: const TextStyle(fontSize: 28))),
          Positioned(
            bottom: 0, right: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: GameTone.woodOuter,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: GameTone.goldTrim.withOpacity(0.7), width: 0.8),
              ),
              child: Text('×$qty',
                  style: const TextStyle(
                      color: GameTone.textGold,
                      fontWeight: FontWeight.w900,
                      fontSize: 9)),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _emptySlot() => Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: Colors.white.withOpacity(0.07),
              width: 1,
              style: BorderStyle.solid),
        ),
        child: Center(
          child: Text('+',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.15), fontSize: 16)),
        ),
      );

  // ── Stats bar ───────────────────────────────────────────────────────────
  Widget _statsBar() => Row(children: [
        Expanded(child: _statBar('❤️', 'Salud', 0.75,
            const [Color(0xFFE85B5B), Color(0xFF8C2A2A)])),
        const SizedBox(width: 8),
        Expanded(child: _statBar('⚡', 'Energía', 0.55,
            const [Color(0xFFF6C76B), Color(0xFFB07A2A)])),
        const SizedBox(width: 8),
        Expanded(child: _statBar('⭐', 'XP', _gs.xpPercent,
            const [Color(0xFF6BBA5B), Color(0xFF1F4E2A)])),
      ]);

  Widget _statBar(String icon, String label, double fraction, List<Color> colors) =>
      PixelFrame(
        radius: 10,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(icon, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 5),
            Text(label,
                style: const TextStyle(
                  color: GameTone.textCream,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  letterSpacing: 0.4,
                )),
          ]),
          const SizedBox(height: 4),
          // Pixel-art segmented bar
          Container(
            height: 10,
            decoration: BoxDecoration(
              color: GameTone.woodOuter,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: GameTone.goldTrim, width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: FractionallySizedBox(
                widthFactor: fraction.clamp(0.0, 1.0),
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: colors),
                  ),
                ),
              ),
            ),
          ),
        ]),
      );

  // ── Item detail popup ────────────────────────────────────────────────────
  Widget _itemDetailPopup() {
    final item = _focusedItem!;
    final qty = _gs.getQty(item.id);
    final canUse = item.isUsableFromBag;

    return GestureDetector(
      onTap: () => setState(() => _focusedItem = null),
      child: Container(
        color: Colors.black.withOpacity(0.6),
        child: Center(
          child: GestureDetector(
            onTap: () {}, // prevent dismiss
            child: SizedBox(
              width: 290,
              child: WoodPanel(
                padding: const EdgeInsets.all(22),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 88, height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [
                        AppColors.amber.withOpacity(0.35),
                        Colors.transparent,
                      ]),
                      border: Border.all(color: AppColors.amber.withOpacity(0.55), width: 2),
                    ),
                    child: Center(child: Text(item.emoji, style: const TextStyle(fontSize: 50))),
                  ),
                  const SizedBox(height: 10),
                  Text(item.name.toUpperCase(),
                      style: const TextStyle(
                          color: AppColors.parchment,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          letterSpacing: 1.6)),
                  const SizedBox(height: 6),
                  Text(item.description,
                      style: AppText.bodyLight,
                      textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  CurrencyChip(icon: '🎒', value: '×$qty EN MOCHILA'),
                  const SizedBox(height: 16),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    GestureDetector(
                      onTap: () => setState(() => _focusedItem = null),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.parchment.withOpacity(0.35), width: 1.5),
                        ),
                        child: const Text('CERRAR',
                            style: TextStyle(
                                color: AppColors.parchment,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                                letterSpacing: 1.4)),
                      ),
                    ),
                    if (canUse && qty > 0) ...[
                      const SizedBox(width: 10),
                      ChunkyButton(
                        label: '¡USAR!',
                        height: 44,
                        onTap: () => _useItem(item.id),
                      ),
                    ],
                  ]),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
