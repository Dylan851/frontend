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
    ('special', '✨ Especial'),
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
        case 'special': return item.category == ItemCategory.special;
        default:        return true;
      }
    }).toList();
  }

  void _useItem(String id) {
    final item = ShopCatalog.findById(id);
    if (item == null || item.category == ItemCategory.gear ||
        item.category == ItemCategory.skin) {
      _showMsg('Este ítem no se puede usar directamente.');
      return;
    }
    _gs.useItem(id);
    // Apply effects
    for (final e in (item.effects).entries) {
      if (e.key == 'health') {
        _showMsg('+${e.value} ❤️ salud restaurada!');
      } else if (e.key == 'energy') {
        _showMsg('+${e.value} ⚡ energía restaurada!');
      }
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
      body: Stack(children: [
        // Dark green bg
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A2A0D), Color(0xFF2A3A1A), Color(0xFF1A2A0D)],
            ),
          ),
        ),
        CustomPaint(
          painter: const HexPatternPainter(),
          size: const Size(double.infinity, double.infinity),
        ),
        // Layout
        Column(children: [
          _topBar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
              child: Row(crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                // Left panel: character + equip
                SizedBox(width: 145, child: _leftPanel()),
                const SizedBox(width: 10),
                // Right panel: items + stats
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
        // Item detail popup
        if (_focusedItem != null) _itemDetailPopup(),
      ]),
    );
  }

  Widget _topBar() => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(children: [
            BackBtn(),
            const SizedBox(width: 10),
            const Text('🎒  Mochila',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 17)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderWhite),
              ),
              child: Text('$_usedSlots/$_totalSlots slots',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 10,
                      fontWeight: FontWeight.w700)),
            ),
          ]),
        ),
      );

  // ── Left panel ─────────────────────────────────────────────────────────
  Widget _leftPanel() => Column(children: [
        // Character box
        Container(
          width: double.infinity, height: 130,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.35),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderWhite, width: 1.5),
          ),
          child: Stack(alignment: Alignment.center, children: [
            // glow
            Container(
              width: 70, height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(
                  color: AppColors.greenAccent.withOpacity(0.25),
                  blurRadius: 30, spreadRadius: 10,
                )],
              ),
            ),
            Text(_gs.selectedSkin, style: const TextStyle(fontSize: 60)),
            Positioned(
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.greenAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppColors.greenAccent.withOpacity(0.4)),
                ),
                child: Text('Nv. ${_gs.level}',
                    style: const TextStyle(
                        color: AppColors.greenAccent,
                        fontWeight: FontWeight.w900,
                        fontSize: 10)),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 8),
        // Equip slots grid 2×2
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
          childAspectRatio: 1.2,
          physics: const NeverScrollableScrollPhysics(),
          children: _equipSlots.map((slot) {
            final equippedId = _gs.equipped[slot.$1];
            final item = equippedId != null
                ? ShopCatalog.findById(equippedId)
                : null;
            return Container(
              decoration: BoxDecoration(
                color: item != null
                    ? AppColors.greenAccent.withOpacity(0.08)
                    : Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: item != null
                      ? AppColors.greenAccent.withOpacity(0.4)
                      : Colors.white.withOpacity(0.15),
                  width: item != null ? 1.5 : 1,
                  style: item != null
                      ? BorderStyle.solid
                      : BorderStyle.solid,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(item?.emoji ?? slot.$2,
                      style: TextStyle(
                          fontSize: 18,
                          color: item != null
                              ? null
                              : Colors.white.withOpacity(0.3))),
                  const SizedBox(height: 2),
                  Text(slot.$3,
                      style: TextStyle(
                          fontSize: 7.5,
                          color: Colors.white.withOpacity(0.45),
                          fontWeight: FontWeight.w700)),
                ],
              ),
            );
          }).toList(),
        ),
      ]);

  // ── Category filter ─────────────────────────────────────────────────────
  Widget _catFilter() => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _cats.map((c) {
            final active = _selectedCat == c.$1;
            return GestureDetector(
              onTap: () => setState(() => _selectedCat = c.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: active
                      ? AppColors.greenAccent.withOpacity(0.2)
                      : Colors.white.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(
                    color: active
                        ? AppColors.greenAccent.withOpacity(0.6)
                        : Colors.white.withOpacity(0.1),
                    width: active ? 1.5 : 1,
                  ),
                ),
                child: Text(c.$2,
                    style: TextStyle(
                        color: active
                            ? AppColors.greenAccent
                            : Colors.white.withOpacity(0.55),
                        fontWeight: FontWeight.w800,
                        fontSize: 10)),
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
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: Colors.white.withOpacity(0.12), width: 1),
        ),
        child: Stack(children: [
          Center(child: Text(item.emoji,
              style: const TextStyle(fontSize: 22))),
          Positioned(
            bottom: 3, right: 5,
            child: Text('×$qty',
                style: const TextStyle(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w900,
                    fontSize: 8.5)),
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
  Widget _statsBar() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderWhite, width: 1),
        ),
        child: Row(children: [
          const Text('💪', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(child: _statRow('❤️ Salud', 0.75,
              const [Color(0xFFff6b6b), Color(0xFFee5a24)])),
          const SizedBox(width: 10),
          Expanded(child: _statRow('⚡ Energía', 0.55,
              [AppColors.gold, AppColors.goldDark])),
          const SizedBox(width: 10),
          Expanded(child: _statRow('⭐ XP', _gs.xpPercent,
              [AppColors.greenAccent, AppColors.greenDeep])),
        ]),
      );

  Widget _statRow(String label, double fraction, List<Color> colors) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 8,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 3),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 6,
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation(colors.first),
          ),
        ),
      ]);

  // ── Item detail popup ────────────────────────────────────────────────────
  Widget _itemDetailPopup() {
    final item = _focusedItem!;
    final qty = _gs.getQty(item.id);
    final canUse = item.category == ItemCategory.food ||
        item.category == ItemCategory.special;

    return GestureDetector(
      onTap: () => setState(() => _focusedItem = null),
      child: Container(
        color: Colors.black.withOpacity(0.6),
        child: Center(
          child: GestureDetector(
            onTap: () {}, // prevent dismiss
            child: Container(
              width: 280,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1B4A2E), Color(0xFF0D2B1A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppColors.greenAccent.withOpacity(0.4), width: 2),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.greenAccent.withOpacity(0.1),
                      blurRadius: 30)
                ],
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(item.emoji, style: const TextStyle(fontSize: 52)),
                const SizedBox(height: 8),
                Text(item.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18)),
                const SizedBox(height: 4),
                Text(item.description,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.65),
                        fontSize: 12),
                    textAlign: TextAlign.center),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('En mochila: ×$qty',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 13)),
                ),
                const SizedBox(height: 14),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  // Cancel
                  GestureDetector(
                    onTap: () => setState(() => _focusedItem = null),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.3), width: 1.5),
                      ),
                      child: const Text('Cerrar',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13)),
                    ),
                  ),
                  if (canUse && qty > 0) ...[
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => _useItem(item.id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [AppColors.greenAccent, AppColors.greenDeep]),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                                color: AppColors.greenAccent.withOpacity(0.35),
                                blurRadius: 12)
                          ],
                        ),
                        child: const Text('¡Usar!',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 13)),
                      ),
                    ),
                  ],
                ]),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
