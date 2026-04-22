// lib/game/overlays/encounter_overlay.dart
// Panel que aparece cuando el jugador se acerca a un animal

import 'package:flutter/material.dart';
import '../../data/animal_data.dart';
import '../../data/game_state.dart';
import '../../router/app_router.dart';
import '../../theme/app_theme.dart';

class EncounterOverlay extends StatefulWidget {
  static const String id = 'EncounterOverlay';
  final AnimalData animal;
  final VoidCallback onClose;

  const EncounterOverlay({
    super.key,
    required this.animal,
    required this.onClose,
  });

  @override
  State<EncounterOverlay> createState() => _EncounterOverlayState();
}

class _EncounterOverlayState extends State<EncounterOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale, _fade;
  int _currentFact = 0;
  bool _alreadyDiscovered = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _scale = Tween<double>(begin: 0.7, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _fade  = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0, 0.4)));
    _ctrl.forward();

    // Solo informamos si ya estaba descubierto; NO lo descubrimos aquí.
    // El animal se desbloquea únicamente al ganar el minijuego.
    _alreadyDiscovered = GameState().isAnimalDiscovered(widget.animal.id);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.65),
      child: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Container(
              width: 520,
              constraints: const BoxConstraints(maxHeight: 340),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1A4A2E), Color(0xFF0D2B1A)],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.greenAccent.withOpacity(0.4), width: 2),
                boxShadow: [BoxShadow(color: AppColors.greenAccent.withOpacity(0.15), blurRadius: 30, spreadRadius: 5)],
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                // Header
                _buildHeader(),
                // Body
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Column(children: [
                    _buildInfo(),
                    const SizedBox(height: 10),
                    if (widget.animal.sound.isNotEmpty) _buildSoundBubble(),
                    if (widget.animal.sound.isNotEmpty)
                      const SizedBox(height: 10),
                    _buildFact(),
                    const SizedBox(height: 16),
                    _buildButtons(),
                  ]),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: [AppColors.greenAccent.withOpacity(0.2), Colors.transparent]),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
    ),
    child: Row(children: [
      Text(widget.animal.emoji, style: const TextStyle(fontSize: 42)),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(widget.animal.name,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)),
          const SizedBox(width: 8),
          if (!_alreadyDiscovered)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.greenAccent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('¡NUEVO! +100⭐', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
            ),
        ]),
        const SizedBox(height: 2),
        Row(children: [
          _tag('🌍 ${widget.animal.habitat}'),
          const SizedBox(width: 6),
          _tag('🍽️ ${widget.animal.diet}'),
          const SizedBox(width: 6),
          _tag('📏 ${widget.animal.size}'),
        ]),
      ])),
      GestureDetector(
        onTap: widget.onClose,
        child: Container(width: 30, height: 30,
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
          child: const Icon(Icons.close, color: Colors.white, size: 16)),
      ),
    ]),
  );

  Widget _buildSoundBubble() => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: [
        AppColors.greenAccent.withOpacity(0.18),
        AppColors.greenAccent.withOpacity(0.05),
      ]),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.greenAccent.withOpacity(0.35)),
    ),
    child: Row(children: [
      const Text('🔊', style: TextStyle(fontSize: 18)),
      const SizedBox(width: 10),
      Expanded(
        child: Text(
          widget.animal.sound,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ]),
  );

  Widget _buildInfo() => Text(
    widget.animal.description,
    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12, height: 1.4),
    maxLines: 2, overflow: TextOverflow.ellipsis,
  );

  Widget _buildFact() => GestureDetector(
    onTap: () => setState(() => _currentFact = (_currentFact + 1) % widget.animal.funFacts.length),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Row(children: [
        const Text('💡', style: TextStyle(fontSize: 16)),
        const SizedBox(width: 10),
        Expanded(child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            widget.animal.funFacts[_currentFact],
            key: ValueKey(_currentFact),
            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 11, fontStyle: FontStyle.italic),
          ),
        )),
        Icon(Icons.touch_app_rounded, color: Colors.white.withOpacity(0.3), size: 14),
      ]),
    ),
  );

  Widget _buildButtons() => Row(mainAxisAlignment: MainAxisAlignment.end, children: [
    _outlineBtn('Luego', widget.onClose),
    const SizedBox(width: 10),
    _mainBtn('¡Jugar minijuego! 🎮', () {
      widget.onClose();
      Navigator.of(context).pushNamed(AppRouter.minigame, arguments: widget.animal);
    }),
  ]);

  Widget _tag(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 9)),
  );

  Widget _outlineBtn(String label, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
    ),
  );

  Widget _mainBtn(String label, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.greenAccent, AppColors.greenDeep]),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppColors.greenAccent.withOpacity(0.4), blurRadius: 12)],
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
    ),
  );
}
