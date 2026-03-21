// lib/screens/shop_screen.dart
import 'package:flutter/material.dart';
import '../data/item_data.dart';
import '../data/game_state.dart';
import '../theme/app_theme.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});
  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _gs = GameState();
  String? _lastBought;

  static const _tabs = [
    (icon: '🍎', label: 'Comida',   cat: ItemCategory.food),
    (icon: '🛡️', label: 'Equipo',   cat: ItemCategory.gear),
    (icon: '✨', label: 'Especial', cat: ItemCategory.special),
    (icon: '🎨', label: 'Skins',    cat: ItemCategory.skin),
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  void _buy(ShopItem item) {
    final ok = _gs.buyItem(item);
    if (ok) {
      setState(() => _lastBought = item.name);
      _showToast('¡Comprado! +1 ${item.emoji}', success: true);
    } else {
      final need = item.currency == ItemCurrency.coins ? '🪙 monedas' : '💎 gemas';
      _showToast('Sin $need suficientes', success: false);
    }
  }

  void _showToast(String msg, {required bool success}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg,
            style: const TextStyle(
                fontWeight: FontWeight.w800, color: Colors.white)),
        backgroundColor:
            success ? AppColors.greenDeep : AppColors.badgeRed,
        duration: const Duration(milliseconds: 1400),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        // Purple-dark background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A0D2E), Color(0xFF2E1A4A), Color(0xFF1A0D2E)],
            ),
          ),
        ),
        CustomPaint(
          painter: const HexPatternPainter(),
          size: const Size(double.infinity, double.infinity),
        ),
        Column(children: [
          // Top bar
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(children: [
                BackBtn(),
                const SizedBox(width: 10),
                const Text('🛒  Tienda',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 17)),
                const Spacer(),
                CurrencyChip(icon: '🪙', value: '${_gs.coins}'),
                const SizedBox(width: 6),
                CurrencyChip(icon: '💎', value: '${_gs.gems}'),
              ]),
            ),
          ),
          // Tab bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: Colors.white.withOpacity(0.08), width: 1),
            ),
            child: TabBar(
              controller: _tabCtrl,
              indicator: BoxDecoration(
                color: AppColors.shopPurple.withOpacity(0.35),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.shopPurple.withOpacity(0.6), width: 1),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelStyle: const TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w800,
                  fontSize: 11),
              unselectedLabelStyle: const TextStyle(
                  fontFamily: 'Nunito', fontSize: 10),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
              tabs: _tabs
                  .map((t) =>
                      Tab(text: '${t.icon} ${t.label}', height: 34))
                  .toList(),
            ),
          ),
          const SizedBox(height: 8),
          // Tab body
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: _tabs.map((t) => _ShopGrid(
                items: ShopCatalog.byCategory(t.cat),
                gs: _gs,
                onBuy: _buy,
              )).toList(),
            ),
          ),
        ]),
      ]),
    );
  }
}

// ─── Shop item grid ──────────────────────────────────────────────────────────
class _ShopGrid extends StatelessWidget {
  final List<ShopItem> items;
  final GameState gs;
  final void Function(ShopItem) onBuy;

  const _ShopGrid({
    required this.items,
    required this.gs,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.78,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => _ShopItemCard(
        item: items[i],
        qty: gs.getQty(items[i].id),
        onBuy: () => onBuy(items[i]),
      ),
    );
  }
}

// ─── Shop item card ──────────────────────────────────────────────────────────
class _ShopItemCard extends StatefulWidget {
  final ShopItem item;
  final int qty;
  final VoidCallback onBuy;

  const _ShopItemCard({
    required this.item,
    required this.qty,
    required this.onBuy,
  });

  @override
  State<_ShopItemCard> createState() => _ShopItemCardState();
}

class _ShopItemCardState extends State<_ShopItemCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatCtrl;
  late Animation<double> _float;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(vsync: this,
        duration: Duration(milliseconds: 2000 + widget.item.id.hashCode % 800))
      ..repeat(reverse: true);
    _float = Tween<double>(begin: 0, end: -5).animate(
        CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _floatCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isGems = item.currency == ItemCurrency.gems;

    return GestureDetector(
      onTap: widget.onBuy,
      child: Container(
        decoration: BoxDecoration(
          color: item.isFeatured
              ? Colors.amber.withOpacity(0.08)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: item.isFeatured
                ? Colors.amber.withOpacity(0.4)
                : Colors.white.withOpacity(0.1),
            width: item.isFeatured ? 1.5 : 1,
          ),
        ),
        child: Stack(children: [
          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Floating emoji
                AnimatedBuilder(
                  animation: _float,
                  builder: (_, __) => Transform.translate(
                    offset: Offset(0, _float.value),
                    child: Text(item.emoji,
                        style: const TextStyle(fontSize: 28)),
                  ),
                ),
                const SizedBox(height: 5),
                Text(item.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 10),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(item.description,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 8.5),
                    textAlign: TextAlign.center,
                    maxLines: 2),
                const SizedBox(height: 6),
                // Price button
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isGems
                        ? Colors.blue.withOpacity(0.2)
                        : Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isGems
                          ? Colors.blue.withOpacity(0.5)
                          : Colors.orange.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(isGems ? '💎' : '🪙',
                        style: const TextStyle(fontSize: 10)),
                    const SizedBox(width: 3),
                    Text('${item.price}',
                        style: TextStyle(
                            color: isGems
                                ? Colors.lightBlueAccent
                                : AppColors.gold,
                            fontWeight: FontWeight.w900,
                            fontSize: 10)),
                  ]),
                ),
              ],
            ),
          ),
          // Badge label
          if (item.badgeLabel != null)
            Positioned(
              top: -1, right: -1,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.badgeRed,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
                child: Text(item.badgeLabel!,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 7.5,
                        fontWeight: FontWeight.w900)),
              ),
            ),
          // Owned qty badge
          if (widget.qty > 0)
            Positioned(
              bottom: 4, left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.greenAccent.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('×${widget.qty}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w900)),
              ),
            ),
        ]),
      ),
    );
  }
}
