// lib/game/minigames/puzzle_game.dart
// Minijuego: Ordena las piezas del puzzle del Oso Pardo

import 'package:flutter/material.dart';
import '../../data/animal_data.dart';
import '../../theme/app_theme.dart';
import 'dart:math';

class PuzzleGame extends StatefulWidget {
  final AnimalData animal;
  final void Function(int stars) onComplete;
  const PuzzleGame({super.key, required this.animal, required this.onComplete});
  @override State<PuzzleGame> createState() => _PuzzleGameState();
}

class _PuzzlePiece {
  final int correctIndex;
  int currentIndex;
  final String emoji;
  final String label;

  _PuzzlePiece({
    required this.correctIndex,
    required this.currentIndex,
    required this.emoji,
    required this.label,
  });

  bool get isInPlace => correctIndex == currentIndex;
}

class _PuzzleGameState extends State<PuzzleGame> {
  // 6 datos sobre el oso en orden correcto
  static const _facts = [
    ('🐻', 'El oso'),
    ('👃', 'tiene gran olfato'),
    ('🍯', 'come miel'),
    ('❄️', 'hiberna en invierno'),
    ('🐾', 'tiene 5 dedos'),
    ('🌲', 'vive en el bosque'),
  ];

  late List<_PuzzlePiece> _pieces;
  int? _selected;
  int _moves = 0;
  bool _completed = false;
  double _startTime = 0;

  @override
  void initState() {
    super.initState();
    final shuffled = List.generate(6, (i) => i)..shuffle(Random());
    _pieces = List.generate(6, (i) => _PuzzlePiece(
      correctIndex: i,
      currentIndex: shuffled[i],
      emoji: _facts[i].$1,
      label: _facts[i].$2,
    ));
    _startTime = DateTime.now().millisecondsSinceEpoch.toDouble();
  }

  void _tap(int pieceIdx) {
    if (_completed) return;

    if (_selected == null) {
      setState(() => _selected = pieceIdx);
      return;
    }

    if (_selected == pieceIdx) {
      setState(() => _selected = null);
      return;
    }

    // Intercambiar posiciones
    final a = _pieces[_selected!].currentIndex;
    final b = _pieces[pieceIdx].currentIndex;
    setState(() {
      _pieces[_selected!].currentIndex = b;
      _pieces[pieceIdx].currentIndex = a;
      _selected = null;
      _moves++;
    });

    if (_pieces.every((p) => p.isInPlace)) {
      _completed = true;
      final elapsed = (DateTime.now().millisecondsSinceEpoch - _startTime) / 1000;
      final stars = _moves <= 6 ? 3 : _moves <= 10 ? 2 : 1;
      Future.delayed(const Duration(milliseconds: 600), () => widget.onComplete(stars));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ordenar piezas por posición actual
    final sorted = List.of(_pieces)..sort((a, b) => a.currentIndex.compareTo(b.currentIndex));

    return Column(children: [
      Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(children: [
          Text(widget.animal.emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('¡Ordena la historia del Oso!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            Text('Toca dos piezas para intercambiarlas y ordénalas correctamente', style: TextStyle(color: Colors.white60, fontSize: 11)),
          ])),
          _stat('🔄', '$_moves movimientos'),
        ])),

      Expanded(child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        // Grid 3x2
        SizedBox(
          width: 500,
          child: Wrap(spacing: 10, runSpacing: 10, children: sorted.asMap().entries.map((e) {
            final slotIdx = e.key;
            final piece = e.value;
            final selected = _selected != null && _pieces.indexOf(piece) == _selected;
            final inPlace = piece.isInPlace;

            return GestureDetector(
              onTap: () => _tap(_pieces.indexOf(piece)),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 150, height: 80,
                decoration: BoxDecoration(
                  gradient: inPlace
                    ? const LinearGradient(colors: [AppColors.greenAccent, AppColors.greenDeep])
                    : selected
                      ? LinearGradient(colors: [AppColors.gold.withOpacity(0.3), AppColors.goldDark.withOpacity(0.2)])
                      : LinearGradient(colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)]),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: inPlace ? AppColors.greenAccent : selected ? AppColors.gold : Colors.white.withOpacity(0.2),
                    width: inPlace || selected ? 2 : 1),
                  boxShadow: [if (selected) BoxShadow(color: AppColors.gold.withOpacity(0.3), blurRadius: 12)],
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(piece.emoji, style: const TextStyle(fontSize: 24)),
                  const SizedBox(height: 4),
                  Text(piece.label, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 11, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  if (inPlace) const Text('✅', style: TextStyle(fontSize: 10)),
                ]),
              ),
            );
          }).toList()),
        ),

        const SizedBox(height: 16),
        Text('Orden correcto: La frase completa de izquierda a derecha →',
          style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
      ]))),
    ]);
  }

  Widget _stat(String icon, String val) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), borderRadius: BorderRadius.circular(20)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Text(icon, style: const TextStyle(fontSize: 13)),
      const SizedBox(width: 4),
      Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
    ]));
}
