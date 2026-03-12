// lib/game/overlays/hud_overlay.dart
import 'package:flutter/material.dart';
import '../../data/game_state.dart';
import '../../data/animal_data.dart';
import '../../router/app_router.dart';
import '../../theme/app_theme.dart';

class HudOverlay extends StatefulWidget {
  static const String id = 'HudOverlay';
  const HudOverlay({super.key});
  @override
  State<HudOverlay> createState() => _HudOverlayState();
}

class _HudOverlayState extends State<HudOverlay> {
  final _state = GameState();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          // ── TOP BAR ──
          Positioned(
            top: 8, left: 10, right: 10,
            child: Row(children: [
              // Botón volver
              _hudBtn(
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                onTap: () => Navigator.of(context).pushReplacementNamed(AppRouter.mainMenu),
              ),
              const SizedBox(width: 8),
              // Conteo animales
              _chip('🦊', '${_state.discoveredCount}/${AnimalCatalog.all.length}'),
              const Spacer(),
              // Monedas
              _chip('🪙', '${_state.coins}'),
              const SizedBox(width: 8),
              // Score
              _chip('⭐', '${_state.score}'),
              const SizedBox(width: 8),
              // Colección
              _hudBtn(
                child: const Text('📖', style: TextStyle(fontSize: 18)),
                onTap: () => Navigator.of(context).pushNamed(AppRouter.collection),
              ),
            ]),
          ),

          // ── MINI-MAPA (abajo derecha) ──
          Positioned(
            bottom: 70, right: 10,
            child: _MiniMap(),
          ),

          // ── Indicador animales cercanos (abajo izq) ──
          Positioned(
            bottom: 70, left: 10,
            child: _NearbyIndicator(),
          ),
        ],
      ),
    );
  }

  Widget _hudBtn({required Widget child, required VoidCallback onTap}) =>
    GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        ),
        child: Center(child: child),
      ),
    );

  Widget _chip(String icon, String val) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.5),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Text(icon, style: const TextStyle(fontSize: 13)),
      const SizedBox(width: 4),
      Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
    ]),
  );
}

class _MiniMap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80, height: 80,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Stack(children: [
        Padding(
          padding: const EdgeInsets.all(4),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: Container(color: const Color(0xFF2D7A3A),
              child: const Center(child: Text('🗺️', style: TextStyle(fontSize: 30)))),
          ),
        ),
        // Punto jugador
        Positioned(
          left: 36, top: 36,
          child: Container(
            width: 8, height: 8,
            decoration: BoxDecoration(
              color: AppColors.greenAccent,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: AppColors.greenAccent.withOpacity(0.8), blurRadius: 4)],
            ),
          ),
        ),
      ]),
    );
  }
}

class _NearbyIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.greenAccent.withOpacity(0.4), width: 1),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 8, height: 8,
          decoration: BoxDecoration(
            color: AppColors.greenAccent,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: AppColors.greenAccent.withOpacity(0.8), blurRadius: 5)],
          ),
        ),
        const SizedBox(width: 6),
        Text('Explora el mapa', style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 11)),
      ]),
    );
  }
}
