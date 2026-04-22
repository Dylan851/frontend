// lib/game/overlays/hud_overlay.dart
import 'package:flutter/material.dart';
import '../../data/game_state.dart';
import '../../data/animal_data.dart';
import '../../theme/app_theme.dart';

class HudOverlay extends StatefulWidget {
  static const String id = 'HudOverlay';

  final VoidCallback? onMenu;
  final VoidCallback? onCollection;

  const HudOverlay({
    super.key,
    this.onMenu,
    this.onCollection,
  });

  @override
  State<HudOverlay> createState() => _HudOverlayState();
}

class _HudOverlayState extends State<HudOverlay> {
  final _gs = GameState();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(children: [
        // ── Top bar ─────────────────────────────────────────────────────────
        Positioned(
          top: 8, left: 10, right: 10,
          child: Row(children: [
            // Back to menu
            _iconBtn(
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 14),
              onTap: widget.onMenu,
            ),
            const SizedBox(width: 8),
            // Animal count
            _chip('🐾', '${_gs.discoveredCount}/${AnimalCatalog.all.length}'),
            const Spacer(),
            // Coins
            _chip('🪙', '${_gs.coins}'),
            const SizedBox(width: 6),
            // Score
            _chip('⭐', '${_gs.score}'),
            const SizedBox(width: 8),
            // Collection
            _iconBtn(
              child: const Text('📖', style: TextStyle(fontSize: 16)),
              onTap: widget.onCollection,
            ),
          ]),
        ),

        // ── Hint bar (bottom center) ─────────────────────────────────────
        Positioned(
          bottom: 82, left: 0, right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.greenAccent.withOpacity(0.35), width: 1),
              ),
              child: Text(
                '¡Explora y busca animales! 🦊 🦌 🦉 🦋 🐻 🐸',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.75), fontSize: 10),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _iconBtn({required Widget child, VoidCallback? onTap}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.52),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
                color: Colors.white.withOpacity(0.2), width: 1),
          ),
          child: Center(child: child),
        ),
      );

  Widget _chip(String icon, String val) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.52),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: Colors.white.withOpacity(0.18), width: 1),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(val,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11)),
        ]),
      );
}
