// lib/game/minigames/sound_match_game.dart
// Minijuego: Empareja el animal con su descripción de sonido

import 'package:flutter/material.dart';
import '../../data/animal_data.dart';
import '../../theme/app_theme.dart';
import 'dart:math';

class SoundMatchGame extends StatefulWidget {
  final AnimalData animal;
  final void Function(int stars) onComplete;
  const SoundMatchGame({super.key, required this.animal, required this.onComplete});
  @override State<SoundMatchGame> createState() => _SoundMatchGameState();
}

class _SoundPair {
  final String emoji;
  final String name;
  final String soundDesc;
  final String soundEmoji;
  bool matched = false;
  _SoundPair(this.emoji, this.name, this.soundDesc, this.soundEmoji);
}

class _SoundMatchGameState extends State<SoundMatchGame> {
  final _pairs = [
    _SoundPair('🐸', 'Rana',       'Croa-croa en el agua',   '💧'),
    _SoundPair('🦉', 'Búho',       'Uu-uu de noche',          '🌙'),
    _SoundPair('🦊', 'Zorro',      'Chillido agudo en el bosque', '🌲'),
    _SoundPair('🐻', 'Oso',        'Gruñido grave y fuerte',  '⚡'),
    _SoundPair('🦌', 'Ciervo',     'Bramido en otoño',        '🍂'),
    _SoundPair('🦋', 'Mariposa',   'Aleteo silencioso',       '🌸'),
  ];

  String? _selectedAnimal;
  String? _selectedSound;
  final Map<String, String> _matches = {};  // animal → sound
  int _errors = 0;
  bool _completed = false;

  late List<_SoundPair> _shuffledLeft;
  late List<_SoundPair> _shuffledRight;

  @override
  void initState() {
    super.initState();
    _shuffledLeft  = List.of(_pairs)..shuffle(Random());
    _shuffledRight = List.of(_pairs)..shuffle(Random());
  }

  void _selectAnimal(String name) {
    if (_completed || _pairs.firstWhere((p) => p.name == name).matched) return;
    setState(() {
      _selectedAnimal = name;
      _tryMatch();
    });
  }

  void _selectSound(String name) {
    if (_completed || _pairs.firstWhere((p) => p.name == name).matched) return;
    setState(() {
      _selectedSound = name;
      _tryMatch();
    });
  }

  void _tryMatch() {
    if (_selectedAnimal == null || _selectedSound == null) return;

    if (_selectedAnimal == _selectedSound) {
      // Correcto
      final pair = _pairs.firstWhere((p) => p.name == _selectedAnimal);
      pair.matched = true;
      _matches[_selectedAnimal!] = _selectedSound!;
      _selectedAnimal = null;
      _selectedSound  = null;

      if (_pairs.every((p) => p.matched)) {
        _completed = true;
        final stars = _errors == 0 ? 3 : _errors <= 2 ? 2 : 1;
        Future.delayed(const Duration(milliseconds: 600), () => widget.onComplete(stars));
      }
    } else {
      // Incorrecto
      _errors++;
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) setState(() { _selectedAnimal = null; _selectedSound = null; });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(children: [
          Text(widget.animal.emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('¡Empareja el sonido!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            Text('Relaciona cada animal con la descripción de su sonido', style: TextStyle(color: Colors.white60, fontSize: 11)),
          ])),
          _stat('❌', '$_errors errores'),
          const SizedBox(width: 8),
          _stat('✅', '${_pairs.where((p) => p.matched).length}/${_pairs.length}'),
        ])),

      Expanded(child: Center(child: SizedBox(
        width: 680,
        child: Row(children: [
          // Columna de animales
          Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('ANIMALES', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11, letterSpacing: 2)),
              const SizedBox(height: 12),
              ..._shuffledLeft.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _animalCard(p),
              )),
            ])),

          // Líneas de conexión (visual simple)
          SizedBox(width: 60, child: Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pairs.length, (i) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.white.withOpacity(0.15), size: 16)))),
          )),

          // Columna de sonidos
          Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('SONIDOS', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11, letterSpacing: 2)),
              const SizedBox(height: 12),
              ..._shuffledRight.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _soundCard(p),
              )),
            ])),
        ]),
      ))),
    ]);
  }

  Widget _animalCard(_SoundPair p) {
    final sel = _selectedAnimal == p.name;
    return GestureDetector(
      onTap: () => _selectAnimal(p.name),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 50,
        decoration: BoxDecoration(
          color: p.matched ? AppColors.greenAccent.withOpacity(0.2)
               : sel ? AppColors.gold.withOpacity(0.2) : Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: p.matched ? AppColors.greenAccent : sel ? AppColors.gold : Colors.white.withOpacity(0.15),
            width: p.matched || sel ? 2 : 1)),
        child: Row(children: [
          const SizedBox(width: 14),
          Text(p.emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Text(p.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          const Spacer(),
          if (p.matched) const Text('✅', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 10),
        ]),
      ),
    );
  }

  Widget _soundCard(_SoundPair p) {
    final sel = _selectedSound == p.name;
    return GestureDetector(
      onTap: () => _selectSound(p.name),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 50,
        decoration: BoxDecoration(
          color: p.matched ? AppColors.greenAccent.withOpacity(0.2)
               : sel ? AppColors.gold.withOpacity(0.2) : Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: p.matched ? AppColors.greenAccent : sel ? AppColors.gold : Colors.white.withOpacity(0.15),
            width: p.matched || sel ? 2 : 1)),
        child: Row(children: [
          const SizedBox(width: 14),
          Text(p.soundEmoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(child: Text(p.soundDesc, style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12))),
          if (p.matched) const Text('✅', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 10),
        ]),
      ),
    );
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
