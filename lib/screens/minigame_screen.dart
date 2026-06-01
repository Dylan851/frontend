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
        backgroundColor: AppColors.forestNight,
        body: MenuBackdrop(
          dim: 0.62,
          child: Stack(children: [
            Padding(
              padding: EdgeInsets.only(top: 56 * s),
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
                        horizontal: 14 * s, vertical: 9 * s),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF6B4423), Color(0xFF3A2210)],
                      ),
                      borderRadius: BorderRadius.circular(11 * s),
                      border: Border.all(
                          color: GameTone.goldTrim, width: 1.5 * s),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 6,
                            offset: const Offset(0, 3)),
                      ],
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.exit_to_app_rounded,
                          color: GameTone.textCream, size: 20 * s),
                      SizedBox(width: 6 * s),
                      Text('Salir al mapa',
                          style: TextStyle(
                              color: GameTone.textCream,
                              fontSize: 13 * s,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                              shadows: const [
                                Shadow(
                                    color: Color(0xFF1A0E04),
                                    offset: Offset(0, 2),
                                    blurRadius: 0),
                              ])),
                    ]),
                  ),
                ),
              ),
            ),
          ]),
        ),
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
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: PixelFrame(
            radius: 16,
            innerFill: GameTone.panelDark,
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('🚪', style: TextStyle(fontSize: 44)),
              const SizedBox(height: 8),
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
                child: const Text('¿Salir del minijuego?',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      letterSpacing: 0.6,
                      shadows: [
                        Shadow(
                            color: Color(0xFF1A0E04),
                            offset: Offset(0, 2),
                            blurRadius: 0),
                      ],
                    )),
              ),
              const SizedBox(height: 6),
              Text(
                'Perderás tu progreso actual y volverás al mapa.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppColors.parchment.withOpacity(0.78),
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                _choiceBtn(
                  label: 'Seguir',
                  primary: true,
                  onTap: () => Navigator.of(context).pop(false),
                ),
                const SizedBox(width: 10),
                _choiceBtn(
                  label: 'Salir',
                  primary: false,
                  danger: true,
                  onTap: () => Navigator.of(context).pop(true),
                ),
              ]),
            ]),
          ),
        ),
      ),
    );
    return res ?? false;
  }

  Widget _buildMinigame(BuildContext context) {
    void onComplete(int stars) {
      final gs = GameState();
      // Golden Pass: se juega la animación pero se fuerza 3 estrellas aquí
      // (redundante con completeMinigame, que ya lo fuerza, pero permite
      // mostrar el resultado correcto).
      final displayStars =
          gs.hasPendingEffect(ItemEffect.goldenPass) ? 3 : stars;
      // Revive: si pierde (1 estrella o menos) y tiene el pergamino activo, reintento gratis.
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
  required VoidCallback onTap,
  bool primary = false,
  bool danger = false,
}) {
  final colors = danger
      ? const [Color(0xFFD86060), Color(0xFF8A2A2A)]
      : primary
          ? const [Color(0xFF6BBA5B), Color(0xFF3A7A3A), Color(0xFF1F4E2A)]
          : const [Color(0xFF6B4423), Color(0xFF3A2210)];
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
            color: GameTone.goldTrim, width: primary ? 1.8 : 1.4),
        boxShadow: [
          if (primary)
            BoxShadow(
                color: const Color(0xFF6BE095).withOpacity(0.4),
                blurRadius: 12),
          BoxShadow(
              color: Colors.black.withOpacity(0.45),
              blurRadius: 5,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: GameTone.textCream,
          fontWeight: FontWeight.w900,
          fontSize: 13,
          letterSpacing: 0.5,
          shadows: [
            Shadow(
                color: Color(0xFF1A0E04),
                offset: Offset(0, 2),
                blurRadius: 0),
          ],
        ),
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
    final s = (MediaQuery.sizeOf(context).shortestSide / 600).clamp(0.62, 1.05);

    return WillPopScope(
      onWillPop: () async => false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding:
            EdgeInsets.symmetric(horizontal: 24 * s, vertical: 24 * s),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 420 * s),
          child: PixelFrame(
            radius: 18 * s,
            innerFill: GameTone.panelDark,
            padding:
                EdgeInsets.fromLTRB(20 * s, 16 * s, 20 * s, 18 * s),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(
                _isLoss ? '😿' : animal.emoji,
                style: TextStyle(fontSize: 56 * s),
              ),
              SizedBox(height: 8 * s),
              ShaderMask(
                shaderCallback: (b) => LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: _isLoss
                      ? const [
                          Color(0xFFFFC8C8),
                          Color(0xFFE87B7B),
                          Color(0xFFA03A3A),
                        ]
                      : const [
                          Color(0xFFFFE48A),
                          Color(0xFFE8B452),
                          Color(0xFFB07A2A),
                        ],
                ).createShader(b),
                child: Text(
                  _isLoss
                      ? '¡Sigue intentando!'
                      : stars == 3
                          ? '¡Perfecto! 🎉'
                          : '¡Muy bien! 😊',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 22 * s,
                    letterSpacing: 0.8,
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
                          offset: Offset(0, 2),
                          blurRadius: 0),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 8 * s),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (i) => Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2 * s),
                    child: Text(
                      i < stars ? '⭐' : '☆',
                      style: TextStyle(fontSize: 34 * s),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8 * s),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 12 * s, vertical: 8 * s),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3A2210), Color(0xFF1A0E04)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10 * s),
                  border: Border.all(
                      color: GameTone.goldTrim.withOpacity(0.7),
                      width: 1.3),
                ),
                child: Text(
                  _isLoss
                      ? 'Puedes volver al mapa o intentarlo de nuevo.'
                      : '+${stars * 50} puntos · +${stars * 10} 🪙',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _isLoss
                        ? AppColors.parchment.withOpacity(0.85)
                        : GameTone.textGold,
                    fontWeight: FontWeight.w800,
                    fontSize: 12 * s,
                  ),
                ),
              ),
              SizedBox(height: 16 * s),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                _choiceBtn(
                  label: 'Salir al mapa',
                  onTap: onExitToMap,
                  primary: !_isLoss,
                ),
                SizedBox(width: 10 * s),
                _choiceBtn(
                  label: _isLoss ? 'Reintentar' : 'Otra vez',
                  onTap: onRetry,
                  primary: _isLoss,
                ),
              ]),
            ]),
          ),
        ),
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
      // El Pase Dorado completa el minijuego inmediatamente con 3 estrellas.
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
