// lib/screens/collection_screen.dart
// Pantalla de colección estilo Pokédex — muestra los animales descubiertos

import 'package:flutter/material.dart';
import '../data/animal_data.dart';
import '../data/game_state.dart';
import '../theme/app_theme.dart';

class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = GameState();
    // Incluye tanto el catálogo clásico como el Basic Pack (Kanto).
    final animals = [...AnimalCatalog.all, ...AnimalCatalog.basicPack];

    return Scaffold(
      body: Stack(children: [
        // Fondo
        Container(decoration: const BoxDecoration(gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [AppColors.greenDark, AppColors.greenMid]))),

        Column(children: [
          // Header
          SafeArea(child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(width: 38, height: 38,
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withOpacity(0.2))),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16)),
              ),
              const SizedBox(width: 14),
              const Text('📖  Mi Colección', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: 1)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.greenAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.greenAccent.withOpacity(0.4))),
                child: Text('${state.discoveredCount}/${animals.length} descubiertos',
                  style: const TextStyle(color: AppColors.greenAccent, fontWeight: FontWeight.bold, fontSize: 13))),
            ]),
          )),

          // Barra de progreso global
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: state.discoveredCount / animals.length,
                minHeight: 8,
                backgroundColor: Colors.white.withOpacity(0.1),
                valueColor: const AlwaysStoppedAnimation(AppColors.greenAccent)))),

          const SizedBox(height: 16),

          // Grid de animales
          Expanded(child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.6),
              itemCount: animals.length,
              itemBuilder: (_, i) => _AnimalCard(animal: animals[i], state: state),
            ),
          )),
        ]),
      ]),
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: discovered
            ? const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [Color(0xFF1B4A2E), Color(0xFF0D2B1A)])
            : LinearGradient(colors: [Colors.black.withOpacity(0.4), Colors.black.withOpacity(0.3)]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: discovered ? AppColors.greenAccent.withOpacity(0.4) : Colors.white.withOpacity(0.08),
            width: discovered ? 1.5 : 1),
        ),
        child: Stack(children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              // Sprite (primer frame) si está disponible y descubierto,
              // si no → emoji o interrogante.
              SizedBox(
                width: 44, height: 44,
                child: (discovered && animal.spriteAsset != null)
                    ? ClipRect(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          widthFactor: 0.25, // mostrar solo el 1er frame (1/4)
                          child: Image.asset(
                            'assets/images/${animal.spriteAsset}',
                            width: 176, height: 44,
                            filterQuality: FilterQuality.none,
                            fit: BoxFit.fill,
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          discovered ? animal.emoji : '❓',
                          style: TextStyle(
                            fontSize: 36,
                            color: discovered
                                ? null
                                : Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(discovered ? animal.name : '???',
                  style: TextStyle(
                    color: discovered ? Colors.white : Colors.white.withOpacity(0.25),
                    fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 3),
                if (discovered) ...[
                  Text(animal.habitat, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10)),
                  Text(animal.diet,    style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 9)),
                ] else
                  Text('Sin descubrir', style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 10)),
              ])),
            ]),
          ),

          // Insignia minijuego completado
          if (discovered && minigameDone)
            Positioned(top: 8, right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.gold.withOpacity(0.4))),
                child: const Text('⭐ Completado', style: TextStyle(color: AppColors.gold, fontSize: 8, fontWeight: FontWeight.bold)))),

          // Candado si no descubierto
          if (!discovered)
            Positioned.fill(child: Center(
              child: Text('🔒', style: TextStyle(fontSize: 28, color: Colors.white.withOpacity(0.15))))),
        ]),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showDialog(context: context, builder: (_) => _AnimalDetailDialog(animal: animal, state: state));
  }
}

class _AnimalDetailDialog extends StatefulWidget {
  final AnimalData animal;
  final GameState state;
  const _AnimalDetailDialog({required this.animal, required this.state});
  @override State<_AnimalDetailDialog> createState() => _AnimalDetailDialogState();
}

class _AnimalDetailDialogState extends State<_AnimalDetailDialog> {
  int _factIdx = 0;
  @override
  Widget build(BuildContext context) {
    final a = widget.animal;
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 460,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF1B4A2E), Color(0xFF0D2B1A)]),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.greenAccent.withOpacity(0.3), width: 1.5)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.greenAccent.withOpacity(0.15), Colors.transparent]),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(22))),
            child: Row(children: [
              Text(a.emoji, style: const TextStyle(fontSize: 52)),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(a.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
                const SizedBox(height: 4),
                Wrap(spacing: 6, children: [
                  _tag('🌍 ${a.habitat}'),
                  _tag('🍽️ ${a.diet}'),
                  _tag('📏 ${a.size}'),
                ]),
              ])),
              GestureDetector(onTap: () => Navigator.pop(context),
                child: Container(width: 30, height: 30,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.close, color: Colors.white, size: 16))),
            ])),

          // Descripción
          Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(a.description, style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 13, height: 1.5))),

          const SizedBox(height: 12),

          // Dato Wikipedia
          if (a.wikiFact.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.greenAccent.withOpacity(0.25)),
                ),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('📚', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(a.wikiFact,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.82),
                        fontSize: 11, height: 1.45)),
                  ),
                ]),
              ),
            ),

          const SizedBox(height: 14),

          // Datos curiosos (paginados)
          GestureDetector(
            onTap: () => setState(() => _factIdx = (_factIdx + 1) % a.funFacts.length),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.1))),
              child: Row(children: [
                const Text('💡', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 10),
                Expanded(child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(a.funFacts[_factIdx], key: ValueKey(_factIdx),
                    style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12, fontStyle: FontStyle.italic)))),
                Icon(Icons.touch_app_rounded, color: Colors.white.withOpacity(0.25), size: 14),
              ])),
          ),

          const SizedBox(height: 14),

          // Indicador de puntos
          Row(mainAxisAlignment: MainAxisAlignment.center, children:
            List.generate(a.funFacts.length, (i) => Container(
              width: i == _factIdx ? 16 : 6, height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: i == _factIdx ? AppColors.greenAccent : Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(3))))),

          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  Widget _tag(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
    child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 10)));
}
