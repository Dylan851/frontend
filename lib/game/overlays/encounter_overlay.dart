// lib/game/overlays/encounter_overlay.dart
// Panel que aparece cuando el jugador se acerca a un animal.
// Estilo "Cozy Pixel Adventure": marco de madera + acentos dorados, igual
// que la tienda y el menú principal.

import 'package:audioplayers/audioplayers.dart';
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
  final AudioPlayer _audio = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _scale = Tween<double>(begin: 0.7, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: const Interval(0, 0.4)));
    _ctrl.forward();

    _alreadyDiscovered = GameState().isAnimalDiscovered(widget.animal.id);

    // Reproduce el sonido real del animal cuando aparece la ficha.
    _playSound();
  }

  Future<void> _playSound() async {
    try {
      await _audio.stop();
      await _audio.setReleaseMode(ReleaseMode.release);
      await _audio.setVolume(1.0);
      // Pequeño delay para que la animación no pise el inicio del audio.
      await Future.delayed(const Duration(milliseconds: 200));
      if (!mounted) return;
      await _audio.play(AssetSource('audio/animals/${widget.animal.id}.mp3'));
    } catch (_) {/* fichero no disponible — silencio */}
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _audio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = (MediaQuery.sizeOf(context).shortestSide / 600).clamp(0.95, 1.55);
    return Material(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12 * s),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 720 * s,
                  maxHeight: MediaQuery.sizeOf(context).height * 0.95,
                ),
                child: PixelFrame(
                  radius: 18 * s,
                  innerFill: GameTone.panelDark,
                  padding: EdgeInsets.fromLTRB(
                      14 * s, 12 * s, 14 * s, 12 * s),
                  child: SingleChildScrollView(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      _buildHeader(s),
                      SizedBox(height: 10 * s),
                      _buildInfo(s),
                      SizedBox(height: 10 * s),
                      if (widget.animal.sound.isNotEmpty) ...[
                        _buildSoundBubble(s),
                        SizedBox(height: 8 * s),
                      ],
                      _buildFact(s),
                      SizedBox(height: 14 * s),
                      _buildButtons(s),
                    ]),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(double s) => Row(children: [
        // Wood plaque containing the animal emoji.
        Container(
          width: 64 * s,
          height: 64 * s,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF6B4423), Color(0xFF3A2210)],
            ),
            borderRadius: BorderRadius.circular(12 * s),
            border: Border.all(color: GameTone.goldTrim, width: 1.5 * s),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.45),
                  blurRadius: 6,
                  offset: const Offset(0, 3)),
            ],
          ),
          child: Center(
            child: Text(widget.animal.emoji,
                style: TextStyle(fontSize: 38 * s)),
          ),
        ),
        SizedBox(width: 12 * s),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title with gold gradient + dark outline (like shop/main).
            ShaderMask(
              shaderCallback: (b) => const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFFE48A),
                  Color(0xFFE8B452),
                  Color(0xFFB07A2A),
                ],
              ).createShader(b),
              child: Text(
                widget.animal.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 22 * s,
                  letterSpacing: 1.0,
                  height: 1.0,
                  shadows: const [
                    Shadow(
                        color: Color(0xFF1A0E04),
                        offset: Offset(-2, 0),
                        blurRadius: 0),
                    Shadow(
                        color: Color(0xFF1A0E04),
                        offset: Offset(2, 0),
                        blurRadius: 0),
                    Shadow(
                        color: Color(0xFF1A0E04),
                        offset: Offset(0, -2),
                        blurRadius: 0),
                    Shadow(
                        color: Color(0xFF1A0E04),
                        offset: Offset(0, 2),
                        blurRadius: 0),
                  ],
                ),
              ),
            ),
            if (!_alreadyDiscovered) ...[
              SizedBox(height: 4 * s),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 8 * s, vertical: 2 * s),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [
                    Color(0xFF6BBA5B),
                    Color(0xFF1F4E2A),
                  ]),
                  borderRadius: BorderRadius.circular(8 * s),
                  border:
                      Border.all(color: GameTone.goldTrim, width: 1.2 * s),
                ),
                child: Text('¡NUEVO! +100⭐',
                    style: TextStyle(
                      color: GameTone.textCream,
                      fontSize: 10 * s,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.6,
                    )),
              ),
            ],
            SizedBox(height: 6 * s),
            Wrap(spacing: 5 * s, runSpacing: 4 * s, children: [
              _tag('🌍 ${widget.animal.habitat}', s),
              _tag('🍽️ ${widget.animal.diet}', s),
              _tag('📏 ${widget.animal.size}', s),
            ]),
          ],
        )),
        // Close button (small wooden plaque).
        GestureDetector(
          onTap: widget.onClose,
          child: Container(
            width: 32 * s,
            height: 32 * s,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF6B4423), Color(0xFF3A2210)],
              ),
              borderRadius: BorderRadius.circular(8 * s),
              border:
                  Border.all(color: GameTone.goldTrim, width: 1.3 * s),
            ),
            child: Icon(Icons.close,
                color: GameTone.textCream, size: 16 * s),
          ),
        ),
      ]);

  Widget _buildSoundBubble(double s) => GestureDetector(
        onTap: _playSound,
        child: Container(
          width: double.infinity,
          padding:
              EdgeInsets.symmetric(horizontal: 12 * s, vertical: 10 * s),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1F4A2C), Color(0xFF0E2914)],
            ),
            borderRadius: BorderRadius.circular(12 * s),
            border: Border.all(
                color: AppColors.amber.withOpacity(0.55), width: 1.4),
            boxShadow: [
              BoxShadow(
                  color: AppColors.amber.withOpacity(0.18), blurRadius: 8),
            ],
          ),
          child: Row(children: [
            Text('🔊', style: TextStyle(fontSize: 18 * s)),
            SizedBox(width: 10 * s),
            Expanded(
              child: Text(
                widget.animal.sound,
                style: TextStyle(
                  color: GameTone.textCream,
                  fontSize: 14 * s,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Icon(Icons.play_arrow_rounded,
                color: GameTone.textCream.withOpacity(0.7), size: 20 * s),
          ]),
        ),
      );

  Widget _buildInfo(double s) => Text(
        widget.animal.description,
        style: TextStyle(
            color: AppColors.parchment.withOpacity(0.85),
            fontSize: 12 * s,
            height: 1.4),
        textAlign: TextAlign.center,
      );

  Widget _buildFact(double s) => GestureDetector(
        onTap: () => setState(() =>
            _currentFact = (_currentFact + 1) % widget.animal.funFacts.length),
        child: Container(
          width: double.infinity,
          padding:
              EdgeInsets.symmetric(horizontal: 12 * s, vertical: 10 * s),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3A2210), Color(0xFF1A0E04)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12 * s),
            border: Border.all(
                color: GameTone.goldTrim.withOpacity(0.7), width: 1.3),
          ),
          child: Row(children: [
            Text('💡', style: TextStyle(fontSize: 16 * s)),
            SizedBox(width: 10 * s),
            Expanded(
                child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                widget.animal.funFacts[_currentFact],
                key: ValueKey(_currentFact),
                style: TextStyle(
                    color: GameTone.textGold,
                    fontSize: 11 * s,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w700),
              ),
            )),
            Icon(Icons.touch_app_rounded,
                color: GameTone.textGold.withOpacity(0.5), size: 14 * s),
          ]),
        ),
      );

  Widget _buildButtons(double s) =>
      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        _woodBtn(
          label: 'Luego',
          isPrimary: false,
          onTap: widget.onClose,
          s: s,
        ),
        SizedBox(width: 10 * s),
        _woodBtn(
          label: '¡Jugar minijuego! 🎮',
          isPrimary: true,
          onTap: () {
            widget.onClose();
            Navigator.of(context)
                .pushNamed(AppRouter.minigame, arguments: widget.animal);
          },
          s: s,
        ),
      ]);

  Widget _tag(String text, double s) => Container(
        padding:
            EdgeInsets.symmetric(horizontal: 8 * s, vertical: 3 * s),
        decoration: BoxDecoration(
          color: const Color(0xFF0A1F12).withOpacity(0.85),
          borderRadius: BorderRadius.circular(8 * s),
          border: Border.all(
              color: AppColors.amber.withOpacity(0.45), width: 1),
        ),
        child: Text(text,
            style: TextStyle(
                color: AppColors.parchment.withOpacity(0.9),
                fontSize: 10 * s,
                fontWeight: FontWeight.w700)),
      );

  Widget _woodBtn({
    required String label,
    required bool isPrimary,
    required VoidCallback onTap,
    required double s,
  }) {
    final colors = isPrimary
        ? const [Color(0xFF6BBA5B), Color(0xFF3A7A3A), Color(0xFF1F4E2A)]
        : const [Color(0xFF6B4423), Color(0xFF3A2210)];
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            EdgeInsets.symmetric(horizontal: 18 * s, vertical: 10 * s),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: colors,
          ),
          borderRadius: BorderRadius.circular(10 * s),
          border: Border.all(
              color: GameTone.goldTrim, width: isPrimary ? 1.8 : 1.4),
          boxShadow: [
            if (isPrimary)
              BoxShadow(
                  color: const Color(0xFF6BE095).withOpacity(0.4),
                  blurRadius: 12),
            BoxShadow(
                color: Colors.black.withOpacity(0.45),
                blurRadius: 5,
                offset: const Offset(0, 3)),
          ],
        ),
        child: Text(label,
            style: TextStyle(
              color: GameTone.textCream,
              fontWeight: FontWeight.w900,
              fontSize: 13 * s,
              letterSpacing: 0.5,
              shadows: const [
                Shadow(
                    color: Color(0xFF1A0E04),
                    offset: Offset(0, 2),
                    blurRadius: 0),
              ],
            )),
      ),
    );
  }
}
