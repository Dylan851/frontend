// lib/game/minigames/silhouette_game.dart
// Minijuego: Adivina el animal por su silueta

import 'package:flutter/material.dart';
import '../../data/animal_data.dart';
import '../../theme/app_theme.dart';
import 'dart:math';

class SilhouetteGame extends StatefulWidget {
  final AnimalData animal;
  final void Function(int stars) onComplete;
  const SilhouetteGame({super.key, required this.animal, required this.onComplete});
  @override State<SilhouetteGame> createState() => _SilhouetteGameState();
}

class _SilhouetteGameState extends State<SilhouetteGame>
    with SingleTickerProviderStateMixin {
  late AnimationController _revealCtrl;
  late Animation<double> _blur;
  int _attempts = 0;
  String? _selected;
  bool _revealed = false;
  late List<AnimalData> _options;

  @override
  void initState() {
    super.initState();
    _revealCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _blur = Tween<double>(begin: 20.0, end: 0.0).animate(
        CurvedAnimation(parent: _revealCtrl, curve: Curves.easeOut));

    // Mezclar opciones
    final others = AnimalCatalog.all.where((a) => a.id != widget.animal.id).toList()..shuffle(Random());
    _options = [widget.animal, ...others.take(3)]..shuffle(Random());
  }

  @override void dispose() { _revealCtrl.dispose(); super.dispose(); }

  void _guess(AnimalData animal) {
    if (_revealed) return;
    setState(() { _selected = animal.id; _attempts++; });

    if (animal.id == widget.animal.id) {
      _revealed = true;
      _revealCtrl.forward().then((_) {
        Future.delayed(const Duration(milliseconds: 600), () {
          final stars = _attempts == 1 ? 3 : _attempts == 2 ? 2 : 1;
          widget.onComplete(stars);
        });
      });
    } else {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) setState(() => _selected = null);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _buildHeader(),
      Expanded(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        // Silueta / imagen
        AnimatedBuilder(
          animation: _blur,
          builder: (_, child) => ImageFiltered(
            imageFilter: _revealed
              ? ColorFilter.matrix(const [1,0,0,0,0, 0,1,0,0,0, 0,0,1,0,0, 0,0,0,1,0])
              : ColorFilter.matrix([-1,-1,-1,0,255, -1,-1,-1,0,255, -1,-1,-1,0,255, 0,0,0,1,0]),
            child: Container(
              width: 200, height: 200,
              decoration: BoxDecoration(
                color: _revealed ? Colors.transparent : Colors.black,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20)],
              ),
              child: Center(child: Text(
                widget.animal.emoji,
                style: TextStyle(
                  fontSize: 120,
                  color: _revealed ? null : Colors.black,
                  shadows: _revealed ? null : [const Shadow(color: Colors.black, offset: Offset(0,0), blurRadius: 0)],
                ),
              )),
            ),
          ),
        ),
        const SizedBox(width: 40),
        // Opciones
        SizedBox(
          width: 260,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('¿Qué animal es?', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Intentos: $_attempts', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
              const SizedBox(height: 20),
              ..._options.map((opt) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _OptionBtn(
                  animal: opt,
                  isSelected: _selected == opt.id,
                  isCorrect: _selected == opt.id && opt.id == widget.animal.id,
                  isWrong: _selected == opt.id && opt.id != widget.animal.id,
                  onTap: () => _guess(opt),
                ),
              )),
            ],
          ),
        ),
      ])),
    ]);
  }

  Widget _buildHeader() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    child: Row(children: [
      const Text('🕵️', style: TextStyle(fontSize: 28)),
      const SizedBox(width: 12),
      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('¡Adivina la silueta!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        Text('Observa bien la forma del animal y elige el correcto', style: TextStyle(color: Colors.white60, fontSize: 11)),
      ])),
    ]),
  );
}

class _OptionBtn extends StatelessWidget {
  final AnimalData animal;
  final bool isSelected, isCorrect, isWrong;
  final VoidCallback onTap;
  const _OptionBtn({required this.animal, required this.isSelected, required this.isCorrect, required this.isWrong, required this.onTap});

  @override
  Widget build(BuildContext context) {
    Color borderColor = Colors.white.withOpacity(0.2);
    if (isCorrect) borderColor = AppColors.greenAccent;
    if (isWrong)   borderColor = AppColors.badgeRed;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity, height: 52,
        decoration: BoxDecoration(
          color: isCorrect ? AppColors.greenAccent.withOpacity(0.2)
               : isWrong   ? AppColors.badgeRed.withOpacity(0.15)
               : Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
        ),
        child: Row(children: [
          const SizedBox(width: 16),
          Text(animal.emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Text(animal.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          const Spacer(),
          if (isCorrect) const Text('✅', style: TextStyle(fontSize: 18)),
          if (isWrong)   const Text('❌', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 14),
        ]),
      ),
    );
  }
}
