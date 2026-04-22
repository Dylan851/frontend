// lib/screens/minigame_screen.dart
import 'package:flutter/material.dart';
import '../data/animal_data.dart';
import '../data/game_state.dart';
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _confirmExit,
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
          _buildMinigame(context),

          // ── Back / Exit to map ───────────────────────────────────────────
          Positioned(
            top: 10,
            left: 10,
            child: SafeArea(
              child: GestureDetector(
                onTap: () async {
                  if (await _confirmExit()) {
                    if (mounted) Navigator.of(context).pop();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.badgeRed.withOpacity(0.45),
                        width: 1),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: const [
                    Icon(Icons.exit_to_app_rounded,
                        color: Colors.white, size: 16),
                    SizedBox(width: 5),
                    Text('Salir al mapa',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ]),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
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
      GameState().completeMinigame(widget.animal.id, stars);
      _showResult(stars);
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
          Navigator.of(context).pop(); // cierra el minijuego → mapa
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

    return WillPopScope(
      onWillPop: () async => false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
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
