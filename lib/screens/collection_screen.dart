// lib/screens/collection_screen.dart
// Pantalla de colección estilo Pokédex — muestra los animales descubiertos

import 'package:flutter/material.dart';
import '../data/animal_data.dart';
import '../data/game_state.dart';
import '../data/item_data.dart';
import '../theme/app_theme.dart';
import 'animal_3d_viewer.dart';

class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = GameState();
    // Incluye tanto el catálogo clásico como el Basic Pack (Kanto).
    final animals = [...AnimalCatalog.all, ...AnimalCatalog.basicPack];

    return Scaffold(
      backgroundColor: const Color(0xFF0A1A10),
      body: MenuBackdrop(
        dim: 0.5,
        child: SafeArea(
          child: Column(children: [
            GameHeader(
              title: 'Mi Colección',
              trailing: [
                WoodChip(
                  icon: '📖',
                  label:
                      '${state.discoveredCount}/${animals.length} descubiertos',
                ),
              ],
            ),
            // Barra de progreso global
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Container(
                height: 12,
                decoration: BoxDecoration(
                  color: GameTone.woodOuter,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: GameTone.goldTrim, width: 1.2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: FractionallySizedBox(
                    widthFactor: animals.isEmpty
                        ? 0
                        : (state.discoveredCount / animals.length),
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: [
                          Color(0xFFF6C76B),
                          Color(0xFFD4A04A),
                        ]),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Grid de animales
            Expanded(
                child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: LayoutBuilder(builder: (context, constraints) {
                final cols = AppResponsive.adaptiveColumns(
                  constraints.maxWidth,
                  minColumns: 2,
                  maxColumns: 5,
                  itemWidth: constraints.maxWidth < 860 ? 180 : 240,
                );
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: constraints.maxWidth < 860 ? 1.05 : 1.4,
                  ),
                  itemCount: animals.length,
                  itemBuilder: (_, i) =>
                      _AnimalCard(animal: animals[i], state: state),
                );
              }),
            )),
            // Bottom tip bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: PixelFrame(
                radius: 12,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(children: const [
                  Text('📗', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 10),
                  Expanded(
                      child: Text(
                    'Explora los biomas para descubrir nuevas especies.',
                    style: TextStyle(
                      color: GameTone.textGold,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      letterSpacing: 0.4,
                    ),
                  )),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _AnimalCard extends StatelessWidget {
  final AnimalData animal;
  final GameState state;
  const _AnimalCard({required this.animal, required this.state});

  @override
  Widget build(BuildContext context) {
    final discovered = state.isAnimalDiscovered(animal.id);
    final minigameDone = state.isMinigameCompleted(animal.id);

    return GestureDetector(
      onTap: discovered ? () => _showDetail(context) : null,
      child: PixelFrame(
        radius: 12,
        innerFill:
            discovered ? const Color(0xFF1F3A20) : const Color(0xFF1A1A14),
        padding: const EdgeInsets.all(8),
        child: Stack(children: [
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Expanded(
              child: Center(
                child: (discovered && animal.spriteAsset != null)
                    ? ClipRect(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          widthFactor: 0.25,
                          child: Image.asset(
                            'assets/images/${animal.spriteAsset}',
                            width: 256,
                            height: 64,
                            filterQuality: FilterQuality.none,
                            fit: BoxFit.fill,
                          ),
                        ),
                      )
                    : Stack(alignment: Alignment.center, children: [
                        // Silhouette of emoji (locked) or color (discovered)
                        ColorFiltered(
                          colorFilter: discovered
                              ? const ColorFilter.mode(
                                  Colors.transparent, BlendMode.dst)
                              : const ColorFilter.mode(
                                  Color(0xFF050505), BlendMode.srcATop),
                          child: Text(
                            animal.emoji,
                            style: const TextStyle(fontSize: 48),
                          ),
                        ),
                        if (!discovered)
                          const Text('?',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFD4A04A),
                              )),
                      ]),
              ),
            ),
            const SizedBox(height: 4),
            Text(discovered ? animal.name : '???',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: discovered
                      ? GameTone.textCream
                      : GameTone.textCream.withOpacity(0.4),
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 0.4,
                  shadows: const [
                    Shadow(
                        color: Color(0xFF1A0E04),
                        offset: Offset(0, 1),
                        blurRadius: 0)
                  ],
                )),
            const SizedBox(height: 1),
            Text(discovered ? animal.habitat : 'Sin descubrir',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: discovered
                      ? GameTone.textGold.withOpacity(0.85)
                      : GameTone.textCream.withOpacity(0.3),
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  fontStyle: discovered ? FontStyle.normal : FontStyle.italic,
                )),
          ]),
          // Lock badge centered for non-discovered
          if (!discovered)
            const Positioned(
              right: 0,
              left: 0,
              bottom: 28,
              child: Center(child: Text('🔒', style: TextStyle(fontSize: 16))),
            ),
          // Star badge (minigame complete)
          if (discovered && minigameDone)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFFFFE48A), Color(0xFFB07A2A)]),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: GameTone.woodOuter, width: 1),
                ),
                child: const Text('⭐',
                    style:
                        TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
              ),
            ),
        ]),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) => _AnimalDetailDialog(animal: animal, state: state));
  }
}

class _AnimalDetailDialog extends StatefulWidget {
  final AnimalData animal;
  final GameState state;
  const _AnimalDetailDialog({required this.animal, required this.state});
  @override
  State<_AnimalDetailDialog> createState() => _AnimalDetailDialogState();
}

class _AnimalDetailDialogState extends State<_AnimalDetailDialog> {
  int _factIdx = 0;
  @override
  Widget build(BuildContext context) {
    final a = widget.animal;
    final mq = MediaQuery.sizeOf(context);
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Container(
        width: (mq.width * 0.78).clamp(280.0, 460.0).toDouble(),
        constraints: BoxConstraints(maxHeight: mq.height * 0.92),
        decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFF1B4A2E), Color(0xFF0D2B1A)]),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
                color: AppColors.greenAccent.withOpacity(0.3), width: 1.5)),
        child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Header
          Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    AppColors.greenAccent.withOpacity(0.15),
                    Colors.transparent
                  ]),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(22))),
              child: Row(children: [
                Text(a.emoji, style: const TextStyle(fontSize: 30)),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(a.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 17)),
                      const SizedBox(height: 2),
                      Wrap(spacing: 6, children: [
                        _tag('🌍 ${a.habitat}'),
                        _tag('🍽️ ${a.diet}'),
                        _tag('📏 ${a.size}'),
                      ]),
                    ])),
                GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle),
                        child: const Icon(Icons.close,
                            color: Colors.white, size: 16))),
              ])),

          // Descripción
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(a.description,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 11,
                      height: 1.35))),

          const SizedBox(height: 6),

          // Dato Wikipedia
          if (a.wikiFact.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppColors.greenAccent.withOpacity(0.25)),
                ),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('📚', style: TextStyle(fontSize: 13)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(a.wikiFact,
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.82),
                                fontSize: 10,
                                height: 1.3)),
                      ),
                    ]),
              ),
            ),

          const SizedBox(height: 6),

          // Datos curiosos (paginados)
          GestureDetector(
            onTap: () =>
                setState(() => _factIdx = (_factIdx + 1) % a.funFacts.length),
            child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.1))),
                child: Row(children: [
                  const Text('💡', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(a.funFacts[_factIdx],
                              key: ValueKey(_factIdx),
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.85),
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic)))),
                  Icon(Icons.touch_app_rounded,
                      color: Colors.white.withOpacity(0.25), size: 14),
                ])),
          ),

          const SizedBox(height: 6),

          // Indicador de puntos
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                  a.funFacts.length,
                  (i) => Container(
                      width: i == _factIdx ? 16 : 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                          color: i == _factIdx
                              ? AppColors.greenAccent
                              : Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(3))))),

          // Barra de afecto + botón alimentar
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _AffectionPanel(animal: a, state: widget.state, onChanged: () => setState(() {})),
          ),

          // Botón "Ver en 3D" (solo si hay modelo disponible)
          if (animalHas3DModel(a.id)) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => Animal3DViewer(animal: a),
                  ));
                },
                child: Container(
                  width: double.infinity,
                  height: 38,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF6BBA5B),
                        Color(0xFF3A7A3A),
                        Color(0xFF1F4E2A)
                      ],
                    ),
                    border: Border.all(color: GameTone.goldTrim, width: 1.6),
                    boxShadow: [
                      BoxShadow(
                          color: const Color(0xFF6BE095).withOpacity(0.45),
                          blurRadius: 14),
                      BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 4,
                          offset: const Offset(0, 2)),
                    ],
                  ),
                  child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.threesixty_rounded,
                            color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text('VER EN 3D',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                              letterSpacing: 1.6,
                              shadows: [
                                Shadow(
                                    color: Color(0xFF0E2C18),
                                    offset: Offset(0, 2),
                                    blurRadius: 0),
                              ],
                            )),
                      ]),
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),
        ])),
      ),
    );
  }

  Widget _tag(String text) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8)),
      child: Text(text,
          style: const TextStyle(color: Colors.white70, fontSize: 10)));
}

// ─────────────────────────────────────────────
//  AFFECTION PANEL + FOOD PICKER
// ─────────────────────────────────────────────
class _AffectionPanel extends StatelessWidget {
  final AnimalData animal;
  final GameState state;
  final VoidCallback onChanged;
  const _AffectionPanel({
    required this.animal,
    required this.state,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final pct = state.affectionPercent(animal.id);
    final value = state.getAffection(animal.id);
    final mood = state.affectionMood(animal.id);
    final isMax = value >= GameState.affectionMax;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Text('❤️', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            const Text('Afecto',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 12)),
            const Spacer(),
            Text('$value / ${GameState.affectionMax}',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.75),
                    fontSize: 11,
                    fontWeight: FontWeight.w700)),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(mood,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700)),
            ),
          ]),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(children: [
              Container(height: 10, color: Colors.white.withOpacity(0.08)),
              FractionallySizedBox(
                widthFactor: pct,
                child: Container(
                  height: 10,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [
                      Color(0xFFFF6B8A),
                      Color(0xFFFFC371),
                    ]),
                  ),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: isMax
                ? null
                : () async {
                    await showDialog(
                      context: context,
                      builder: (_) => _FoodPickerDialog(
                        animal: animal,
                        state: state,
                        onFed: onChanged,
                      ),
                    );
                    onChanged();
                  },
            child: Opacity(
              opacity: isMax ? 0.55 : 1.0,
              child: Container(
                width: double.infinity,
                height: 34,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFE3884B), Color(0xFFB05A1F)],
                  ),
                  border: Border.all(color: GameTone.goldTrim, width: 1.4),
                ),
                alignment: Alignment.center,
                child: Text(
                  isMax ? '¡Está totalmente feliz!' : '🍎  ALIMENTAR',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FoodPickerDialog extends StatefulWidget {
  final AnimalData animal;
  final GameState state;
  final VoidCallback onFed;
  const _FoodPickerDialog({
    required this.animal,
    required this.state,
    required this.onFed,
  });

  @override
  State<_FoodPickerDialog> createState() => _FoodPickerDialogState();
}

class _FoodPickerDialogState extends State<_FoodPickerDialog> {
  String? _lastFeedback;

  List<ShopItem> _availableFoods() {
    return ShopCatalog.food
        .where((f) => widget.state.getQty(f.id) > 0)
        .toList();
  }

  void _feed(ShopItem food) {
    final gain = widget.state.feedAnimal(widget.animal.id, food.id);
    setState(() {
      _lastFeedback = gain > 0
          ? '${widget.animal.name} ganó +$gain de afecto con ${food.name}'
          : 'No pudiste alimentar a ${widget.animal.name}';
    });
    widget.onFed();
  }

  @override
  Widget build(BuildContext context) {
    final foods = _availableFoods();
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF1B4A2E), Color(0xFF0D2B1A)]),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: AppColors.greenAccent.withOpacity(0.3), width: 1.4),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            Text('🍽️ Alimentar a ${widget.animal.name}',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14)),
            const Spacer(),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.close, color: Colors.white70, size: 18),
            ),
          ]),
          const SizedBox(height: 10),
          if (foods.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Text(
                'No tienes comida. Compra alimentos en la tienda.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.75), fontSize: 12),
              ),
            )
          else
            ConstrainedBox(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.5),
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: foods.map((f) {
                    final qty = widget.state.getQty(f.id);
                    return GestureDetector(
                      onTap: () => _feed(f),
                      child: Container(
                        width: 88,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.15)),
                        ),
                        child: Column(children: [
                          Text(f.emoji,
                              style: const TextStyle(fontSize: 26)),
                          const SizedBox(height: 4),
                          Text(f.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11)),
                          const SizedBox(height: 2),
                          Text('x$qty',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700)),
                        ]),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          if (_lastFeedback != null) ...[
            const SizedBox(height: 10),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.greenAccent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(_lastFeedback!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
            ),
          ],
        ]),
      ),
    );
  }
}
