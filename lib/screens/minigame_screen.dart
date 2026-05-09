// lib/screens/minigame_screen.dart
import 'package:flutter/material.dart';
import '../data/animal_data.dart';
import '../data/game_state.dart';
import '../data/item_data.dart';
import '../router/app_router.dart';
import '../theme/app_theme.dart';
import '../game/minigames/memory_card_game.dart';
import '../game/minigames/silhouette_game.dart';
import '../game/minigames/trivia_game.dart';
import '../game/minigames/color_match_game.dart';
import '../game/minigames/puzzle_game.dart';
import '../game/minigames/sound_match_game.dart';
import '../game/minigames/taming_game.dart';

class MinigameScreen extends StatefulWidget {
  final AnimalData animal;
  const MinigameScreen({super.key, required this.animal});

  @override
  State<MinigameScreen> createState() => _MinigameScreenState();
}

class _MinigameScreenState extends State<MinigameScreen> {
  // Clave que forzamos a cambiar para remontar el minijuego al reintentar.
  Key _gameKey = UniqueKey();
  // Evita doble-pop si el usuario toca el botón rápido.
  bool _exiting = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final s = (size.shortestSide / 600).clamp(0.62, 1.05);
    return WillPopScope(
      onWillPop: () async {
        // Si ya estamos saliendo, ignora pulsaciones repetidas para no
        // hacer dos pops y cerrar la app sin querer.
        if (_exiting) return false;
        return await _confirmExit();
      },
      child: Scaffold(
        backgroundColor: AppColors.greenDark,
        body: Stack(children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0D2B1A), Color(0xFF1A4A2E)],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 50 * s),
            child: _buildMinigame(context),
          ),

          // ── Back / Exit to map ───────────────────────────────────────────
          Positioned(
            top: 8,
            left: 8,
            child: SafeArea(
              child: GestureDetector(
                onTap: () async {
                  if (_exiting) return;
                  if (await _confirmExit()) {
                    _safeBackToMap();
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 14 * s, vertical: 10 * s),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.65),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.badgeRed.withOpacity(0.7),
                        width: 1.4),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.exit_to_app_rounded,
                        color: Colors.white, size: 22 * s),
                    SizedBox(width: 6 * s),
                    Text('Salir al mapa',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14 * s,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.4)),
                  ]),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  /// Vuelve al mapa de forma segura: si hay rutas anteriores hace `pop()`,
  /// si no hay (minijuego abierto como root), navega al menú principal —
  /// **nunca** deja que el sistema cierre la app.
  void _safeBackToMap() {
    if (!mounted || _exiting) return;
    _exiting = true;
    final nav = Navigator.of(context);
    if (nav.canPop()) {
      nav.pop();
    } else {
      // Si por cualquier motivo el minijuego es la ruta raíz, recolocamos
      // la pila completa al menú principal (NO pop, eso cerraría la app).
      nav.pushNamedAndRemoveUntil(AppRouter.mainMenu, (_) => false);
    }
  }

  Future<bool> _confirmExit() async {
    final res = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFF1A4A2E), Color(0xFF0D2B1A)]),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: AppColors.badgeRed.withOpacity(0.4), width: 2),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('🚪', style: TextStyle(fontSize: 44)),
            const SizedBox(height: 10),
            const Text('¿Salir del minijuego?',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 17)),
            const SizedBox(height: 6),
            Text(
              'Perderás tu progreso actual y volverás al mapa.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.7), fontSize: 12),
            ),
            const SizedBox(height: 18),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _choiceBtn(
                label: 'Seguir jugando',
                color: AppColors.greenAccent,
                onTap: () => Navigator.of(context).pop(false),
              ),
              const SizedBox(width: 12),
              _choiceBtn(
                label: 'Salir al mapa',
                color: AppColors.badgeRed,
                onTap: () => Navigator.of(context).pop(true),
              ),
            ]),
          ]),
        ),
      ),
    );
    return res ?? false;
  }

  Widget _buildMinigame(BuildContext context) {
    void onComplete(int stars) {
      final gs = GameState();
      // Golden Pass: se juega la animación pero se fuerza 3★ aquí también
      // (redundante con completeMinigame, que ya lo fuerza, pero permite
      // mostrar el resultado correcto).
      final displayStars =
          gs.hasPendingEffect(ItemEffect.goldenPass) ? 3 : stars;
      // Revive: si pierde (≤1★) y tiene el pergamino activo, reintento gratis.
      if (displayStars <= 1 && gs.hasPendingEffect(ItemEffect.reviveScroll)) {
        gs.consumeEffect(ItemEffect.reviveScroll);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('📜 ¡Pergamino de Vida usado! Reintento gratis.',
              style: TextStyle(fontWeight: FontWeight.w800)),
          backgroundColor: AppColors.greenDeep,
          duration: Duration(milliseconds: 1400),
        ));
        setState(() => _gameKey = UniqueKey());
        return;
      }
      gs.completeMinigame(widget.animal.id, displayStars);
      _showResult(displayStars);
    }

    final animal = widget.animal;
    switch (animal.minigame) {
      case MinigameType.memoryCards:
        return MemoryCardGame(
            key: _gameKey, animal: animal, onComplete: onComplete);
      case MinigameType.silhouette:
        return SilhouetteGame(
            key: _gameKey, animal: animal, onComplete: onComplete);
      case MinigameType.trivia:
        return TriviaGame(
            key: _gameKey, animal: animal, onComplete: onComplete);
      case MinigameType.colorMatch:
        return ColorMatchGame(
            key: _gameKey, animal: animal, onComplete: onComplete);
      case MinigameType.puzzle:
        return PuzzleGame(
            key: _gameKey, animal: animal, onComplete: onComplete);
      case MinigameType.soundMatch:
        return SoundMatchGame(
            key: _gameKey, animal: animal, onComplete: onComplete);
      case MinigameType.taming:
        return TamingGame(
            key: _gameKey, animal: animal, onComplete: onComplete);
    }
  }

  void _showResult(int stars) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ResultDialog(
        animal: widget.animal,
        stars: stars,
        onRetry: () {
          Navigator.of(context).pop(); // cierra el diálogo
          setState(() => _gameKey = UniqueKey()); // remonta el minijuego
        },
        onExitToMap: () {
          Navigator.of(context).pop(); // cierra el diálogo
          _safeBackToMap();              // vuelve al mapa o al menú
        },
      ),
    );
  }
}

Widget _choiceBtn({
  required String label,
  required Color color,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.7), width: 1.5),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    ),
  );
}

// ─── Result dialog ────────────────────────────────────────────────────────────
class _ResultDialog extends StatelessWidget {
  final AnimalData animal;
  final int stars;
  final VoidCallback onRetry;
  final VoidCallback onExitToMap;

  const _ResultDialog({
    required this.animal,
    required this.stars,
    required this.onRetry,
    required this.onExitToMap,
  });

  bool get _isLoss => stars <= 1;

  @override
  Widget build(BuildContext context) {
    final accent = _isLoss ? AppColors.badgeRed : AppColors.greenAccent;
    final s = (MediaQuery.sizeOf(context).shortestSide / 600).clamp(0.62, 1.05);

    return WillPopScope(
      onWillPop: () async => false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 24 * s, vertical: 24 * s),
        child: Container(
          padding: EdgeInsets.all(18 * s),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFF1A4A2E), Color(0xFF0D2B1A)]),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: accent.withOpacity(0.45), width: 2),
            boxShadow: [
              BoxShadow(color: accent.withOpacity(0.15), blurRadius: 30),
            ],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(
              _isLoss ? '😿' : animal.emoji,
              style: const TextStyle(fontSize: 60),
            ),
            const SizedBox(height: 12),
            Text(
              _isLoss
                  ? '¡Sigue intentando!'
                  : stars == 3
                      ? '¡Perfecto! 🎉'
                      : '¡Muy bien! 😊',
              style: TextStyle(
                color: accent,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (i) => Text(
                  i < stars ? '⭐' : '☆',
                  style: const TextStyle(fontSize: 34),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isLoss
                  ? 'Puedes volver al mapa o intentarlo de nuevo.'
                  : '+${stars * 50} puntos · +${stars * 10} 🪙',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _isLoss
                    ? Colors.white.withOpacity(0.75)
                    : AppColors.greenAccent,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 18),
            // Botonera: siempre deja salir al mapa, y ofrece reintentar.
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _dialogBtn(
                icon: Icons.map_rounded,
                label: 'Salir al mapa',
                color: _isLoss
                    ? AppColors.greenAccent
                    : AppColors.greenAccent,
                onTap: onExitToMap,
                primary: !_isLoss,
              ),
              const SizedBox(width: 10),
              _dialogBtn(
                icon: Icons.refresh_rounded,
                label: _isLoss ? 'Reintentar' : 'Jugar otra vez',
                color: _isLoss ? AppColors.badgeRed : AppColors.gold,
                onTap: onRetry,
                primary: _isLoss,
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _dialogBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required bool primary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: primary ? color.withOpacity(0.3) : color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.7), width: 1.5),
          boxShadow: primary
              ? [BoxShadow(color: color.withOpacity(0.35), blurRadius: 10)]
              : null,
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ]),
      ),
    );
  }
}

// ─── Power-Up Bar ─────────────────────────────────────────────────────────
/// Barra flotante que muestra los power-ups disponibles en la mochila.
/// Al pulsarlos se activan para ESTE minijuego.
class _PowerUpBar extends StatefulWidget {
  final VoidCallback onUsed;
  final VoidCallback onGoldenPass;
  const _PowerUpBar({required this.onUsed, required this.onGoldenPass});
  @override
  State<_PowerUpBar> createState() => _PowerUpBarState();
}

class _PowerUpBarState extends State<_PowerUpBar> {
  @override
  Widget build(BuildContext context) {
    final gs = GameState();
    final available = gs.inventory.entries
        .where((e) {
          final it = ShopCatalog.findById(e.key);
          return it != null && it.isMinigamePowerUp && e.value > 0;
        })
        .map((e) => ShopCatalog.findById(e.key)!)
        .toList();

    if (available.isEmpty && gs.pendingEffects.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gold.withOpacity(0.5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(mainAxisSize: MainAxisSize.min, children: const [
            Icon(Icons.auto_awesome, color: AppColors.gold, size: 13),
            SizedBox(width: 4),
            Text('Power-Ups',
                style: TextStyle(
                    color: AppColors.gold,
                    fontSize: 10,
                    fontWeight: FontWeight.w900)),
          ]),
          const SizedBox(height: 4),
          // Activos
          if (gs.pendingEffects.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Wrap(spacing: 4, children: [
                for (final eff in gs.pendingEffects)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.greenAccent.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: AppColors.greenAccent.withOpacity(0.7),
                          width: 1),
                    ),
                    child: Text(_effectEmoji(eff),
                        style: const TextStyle(fontSize: 12)),
                  ),
              ]),
            ),
          // Disponibles
          Wrap(spacing: 4, runSpacing: 4, children: [
            for (final it in available)
              GestureDetector(
                onTap: () => _tryActivate(it),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.2), width: 1),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(it.emoji, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 3),
                    Text('×${gs.getQty(it.id)}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800)),
                  ]),
                ),
              ),
          ]),
        ],
      ),
    );
  }

  void _tryActivate(ShopItem item) {
    final ok = GameState().activatePowerUp(item.id);
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        ok
            ? '${item.emoji} ¡${item.name} activado!'
            : '${item.emoji} ya está activo o no queda ninguno',
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      backgroundColor: ok ? AppColors.greenDeep : Colors.black87,
      duration: const Duration(milliseconds: 1200),
      behavior: SnackBarBehavior.floating,
    ));
    if (ok) {
      setState(() {});
      widget.onUsed();
      // El Pase Dorado completa el minijuego inmediatamente con 3★.
      if (item.effect == ItemEffect.goldenPass) {
        Future.delayed(const Duration(milliseconds: 600), widget.onGoldenPass);
      }
    }
  }

  static String _effectEmoji(ItemEffect e) {
    switch (e) {
      case ItemEffect.luckyCharm:    return '🍀';
      case ItemEffect.coinDoubler:   return '🪙';
      case ItemEffect.xpBoost:       return '🧪';
      case ItemEffect.goldenPass:    return '🎫';
      case ItemEffect.reviveScroll:  return '📜';
      case ItemEffect.timeExtender:  return '⌛';
      case ItemEffect.hintReveal:    return '🔮';
      default: return '✨';
    }
  }
}
