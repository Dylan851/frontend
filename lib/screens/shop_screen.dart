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
    (icon: '✨', label: 'Power-Ups', cat: ItemCategory.powerup),
    (icon: '🎨', label: 'Skins',    cat: ItemCategory.skin),
    (icon: '💱', label: 'Canjear',  cat: null),
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
  }

  void _sell(ShopItem item, {required bool forXp}) {
    final gained = _gs.sellItem(item.id, forXp: forXp);
    if (gained <= 0) {
      _showToast('No tienes ${item.emoji} para canjear', success: false);
      return;
    }
    setState(() {});
    _showToast(
      '¡Canjeado ${item.emoji}! +$gained ${forXp ? "⭐ XP" : "🪙"}',
      success: true,
    );
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
      backgroundColor: const Color(0xFF0A1A10),
      body: MenuBackdrop(
        dim: 0.55,
        child: SafeArea(child: Column(children: [
          GameHeader(
            title: 'Tienda',
            trailing: [
              OvalGoldChip(icon: '🪙', value: '${_gs.coins}'),
              OvalGoldChip(icon: '💎', value: '${_gs.gems}'),
            ],
          ),
          const SizedBox(height: 4),
          // Tab bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF0A1F12).withOpacity(0.7),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: AppColors.amber.withOpacity(0.35), width: 1.5),
            ),
            child: TabBar(
              controller: _tabCtrl,
              indicator: BoxDecoration(
                gradient: LinearGradient(colors: [
                  AppColors.amber,
                  AppColors.amberDeep,
                ]),
                borderRadius: BorderRadius.circular(11),
                boxShadow: [
                  BoxShadow(color: AppColors.amber.withOpacity(0.4), blurRadius: 10),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelStyle: const TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  letterSpacing: 0.8),
              unselectedLabelStyle: const TextStyle(
                  fontFamily: 'Nunito', fontSize: 10, letterSpacing: 0.6),
              labelColor: const Color(0xFF221208),
              unselectedLabelColor: AppColors.parchment.withOpacity(0.65),
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
              children: _tabs.map((t) {
                if (t.cat == null) {
                  return _SellGrid(gs: _gs, onSell: _sell);
                }
                return _ShopGrid(
                  items: ShopCatalog.byCategory(t.cat!),
                  gs: _gs,
                  onBuy: _buy,
                );
              }).toList(),
            ),
          ),
        ])),
      ),
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
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: item.isFeatured
                ? [const Color(0xFF1F4A2C), const Color(0xFF0E2914)]
                : [const Color(0xFF143421), const Color(0xFF0A1F12)],
          ),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: item.isFeatured
                ? AppColors.amber.withOpacity(0.85)
                : AppColors.amber.withOpacity(0.30),
            width: item.isFeatured ? 2 : 1.2,
          ),
          boxShadow: [
            if (item.isFeatured)
              BoxShadow(color: AppColors.amber.withOpacity(0.3), blurRadius: 14),
            BoxShadow(
              color: AppColors.leafShadow.withOpacity(0.45),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
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
                Text(item.name.toUpperCase(),
                    style: const TextStyle(
                        color: AppColors.parchment,
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                        letterSpacing: 1.0),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(item.description,
                    style: TextStyle(
                        color: AppColors.parchment.withOpacity(0.55),
                        fontSize: 8.5,
                        height: 1.2),
                    textAlign: TextAlign.center,
                    maxLines: 2),
                const SizedBox(height: 6),
                // Price button
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isGems
                          ? [const Color(0xFF7BB6E8), const Color(0xFF3A6C9C)]
                          : [AppColors.amber, AppColors.amberDeep],
                    ),
                    borderRadius: BorderRadius.circular(9),
                    boxShadow: [
                      BoxShadow(
                        color: (isGems ? Colors.lightBlueAccent : AppColors.amber)
                            .withOpacity(0.4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(isGems ? '💎' : '🪙',
                        style: const TextStyle(fontSize: 10)),
                    const SizedBox(width: 3),
                    Text('${item.price}',
                        style: const TextStyle(
                            color: Color(0xFF221208),
                            fontWeight: FontWeight.w900,
                            fontSize: 11)),
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

// ─── Sell grid (Canjear inventario por monedas o XP) ─────────────────────
class _SellGrid extends StatelessWidget {
  final GameState gs;
  final void Function(ShopItem item, {required bool forXp}) onSell;
  const _SellGrid({required this.gs, required this.onSell});

  @override
  Widget build(BuildContext context) {
    final entries = gs.inventory.entries
        .where((e) => e.value > 0 && ShopCatalog.findById(e.key) != null)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (entries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1A0E04).withOpacity(0.6),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: GameTone.goldTrim, width: 1.4),
            ),
            child: const Column(mainAxisSize: MainAxisSize.min, children: [
              Text('🎒', style: TextStyle(fontSize: 38)),
              SizedBox(height: 8),
              Text('Tu mochila está vacía',
                  style: TextStyle(
                      color: GameTone.textCream,
                      fontWeight: FontWeight.w900,
                      fontSize: 16)),
              SizedBox(height: 4),
              Text('Recoge ítems en el mapa o cómpralos para canjearlos',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: GameTone.textGold,
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
            ]),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      itemCount: entries.length,
      itemBuilder: (_, i) {
        final e = entries[i];
        final item = ShopCatalog.findById(e.key)!;
        return _SellTile(
          item: item,
          qty: e.value,
          coinPrice: gs.sellPriceCoins(item),
          xpPrice: gs.sellPriceXp(item),
          onSell: onSell,
        );
      },
    );
  }
}

class _SellTile extends StatelessWidget {
  final ShopItem item;
  final int qty;
  final int coinPrice;
  final int xpPrice;
  final void Function(ShopItem item, {required bool forXp}) onSell;
  const _SellTile({
    required this.item,
    required this.qty,
    required this.coinPrice,
    required this.xpPrice,
    required this.onSell,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: PixelFrame(
        radius: 12,
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        child: Row(children: [
          // Emoji + qty badge
          Container(
            width: 54, height: 54,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Color(0xFF6B4423), Color(0xFF3A2210)],
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: GameTone.goldTrim, width: 1.4),
            ),
            child: Stack(children: [
              Center(child: Text(item.emoji, style: const TextStyle(fontSize: 28))),
              Positioned(
                bottom: 1, right: 3,
                child: Text('×$qty',
                    style: const TextStyle(
                      color: GameTone.textGold,
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                      shadows: [Shadow(color: Color(0xFF1A0E04), offset: Offset(0, 1))],
                    )),
              ),
            ]),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(item.name,
                  style: const TextStyle(
                      color: GameTone.textCream,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      shadows: [Shadow(color: Color(0xFF1A0E04), offset: Offset(0, 2))])),
              const SizedBox(height: 2),
              Text(item.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: GameTone.textCream.withOpacity(0.7),
                      fontSize: 10,
                      height: 1.3)),
            ],
          )),
          const SizedBox(width: 8),
          // Sell buttons
          Column(mainAxisSize: MainAxisSize.min, children: [
            _SellButton(
              icon: '🪙',
              value: coinPrice,
              colors: const [Color(0xFFFFE48A), Color(0xFFB07A2A)],
              textColor: const Color(0xFF221208),
              onTap: () => onSell(item, forXp: false),
            ),
            const SizedBox(height: 6),
            _SellButton(
              icon: '⭐',
              value: xpPrice,
              colors: const [Color(0xFF6BBA5B), Color(0xFF1F4E2A)],
              textColor: Colors.white,
              onTap: () => onSell(item, forXp: true),
            ),
          ]),
        ]),
      ),
    );
  }
}

class _SellButton extends StatelessWidget {
  final String icon;
  final int value;
  final List<Color> colors;
  final Color textColor;
  final VoidCallback onTap;
  const _SellButton({
    required this.icon,
    required this.value,
    required this.colors,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 78, height: 30,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: colors,
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF1A0E04), width: 1.4),
          boxShadow: [
            BoxShadow(
                color: colors.first.withOpacity(0.45),
                blurRadius: 8),
          ],
        ),
        child: Center(
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(icon, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 3),
            Text('+$value',
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 0.3,
                )),
          ]),
        ),
      ),
    );
  }
}
