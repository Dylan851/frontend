// lib/game/minigames/memory_card_game.dart
// Minijuego: Voltea las cartas y encuentra las parejas de animales

import 'package:flutter/material.dart';
import 'dart:math';
import '../../data/animal_data.dart';
import '../../theme/app_theme.dart';

class MemoryCardGame extends StatefulWidget {
  final AnimalData animal;
  final void Function(int stars) onComplete;
  const MemoryCardGame({super.key, required this.animal, required this.onComplete});
  @override State<MemoryCardGame> createState() => _MemoryCardGameState();
}

class _MemoryCardGameState extends State<MemoryCardGame> {
  static const _emojis = ['🦉','🦊','🐻','🦌','🦋','🐸'];
  late List<String> _cards;
  final List<bool> _flipped = List.filled(12, false);
  final List<bool> _matched = List.filled(12, false);
  int? _firstIdx;
  bool _canFlip = true;
  int _moves = 0;
  int _pairs = 0;
  int _seconds = 0;
  late final Ticker _ticker;
  double _elapsed = 0;

  @override
  void initState() {
    super.initState();
    final doubled = [..._emojis, ..._emojis]..shuffle(Random());
    _cards = doubled;
    _ticker = Ticker(_onTick)..start();
  }

  void _onTick(Duration d) {
    setState(() {
      _elapsed = d.inMilliseconds / 1000;
      _seconds = d.inSeconds;
    });
  }

  @override void dispose() { _ticker.dispose(); super.dispose(); }

  void _flip(int idx) {
    if (!_canFlip || _flipped[idx] || _matched[idx]) return;
    setState(() => _flipped[idx] = true);

    if (_firstIdx == null) {
      _firstIdx = idx;
      return;
    }

    _moves++;
    final first = _firstIdx!;
    _firstIdx = null;
    _canFlip = false;

    if (_cards[first] == _cards[idx]) {
      setState(() { _matched[first] = true; _matched[idx] = true; _pairs++; _canFlip = true; });
      if (_pairs == 6) _finish();
    } else {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) setState(() { _flipped[first] = false; _flipped[idx] = false; _canFlip = true; });
      });
    }
  }

  void _finish() {
    _ticker.stop();
    final stars = _moves <= 8 ? 3 : _moves <= 12 ? 2 : 1;
    Future.delayed(const Duration(milliseconds: 400), () => widget.onComplete(stars));
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _buildHeader(),
      const SizedBox(height: 8),
      Expanded(child: Center(child: _buildGrid())),
    ]);
  }

  Widget _buildHeader() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    child: Row(children: [
      Text(widget.animal.emoji, style: const TextStyle(fontSize: 32)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('¡Encuentra las parejas!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        Text('Voltea las cartas y empareja los animales', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11)),
      ])),
      _stat('🎯', '$_moves movimientos'),
      const SizedBox(width: 12),
      _stat('⏱', '${_seconds}s'),
      const SizedBox(width: 12),
      _stat('✅', '$_pairs/6 parejas'),
    ]));

  Widget _stat(String icon, String val) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withOpacity(0.15))),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Text(icon, style: const TextStyle(fontSize: 13)),
      const SizedBox(width: 4),
      Text(val, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
    ]));

  Widget _buildGrid() => SizedBox(
    width: 560,
    child: GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6, crossAxisSpacing: 8, mainAxisSpacing: 8),
      itemCount: 12,
      itemBuilder: (_, i) => _buildCard(i),
    ));

  Widget _buildCard(int i) {
    final isFlipped = _flipped[i] || _matched[i];
    return GestureDetector(
      onTap: () => _flip(i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: isFlipped
            ? LinearGradient(colors: _matched[i]
                ? [AppColors.greenAccent, AppColors.greenDeep]
                : [const Color(0xFF2D7A5A), const Color(0xFF1A4A2E)])
            : const LinearGradient(colors: [Color(0xFF1B4332), Color(0xFF0D2B1A)]),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _matched[i] ? AppColors.greenAccent : Colors.white.withOpacity(0.15),
            width: _matched[i] ? 2 : 1),
          boxShadow: _matched[i] ? [BoxShadow(color: AppColors.greenAccent.withOpacity(0.3), blurRadius: 8)] : [],
        ),
        child: Center(child: isFlipped
          ? Text(_cards[i], style: const TextStyle(fontSize: 28))
          : const Text('❓', style: TextStyle(fontSize: 24, color: Colors.white30))),
      ),
    );
  }
}
