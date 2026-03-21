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

class MinigameScreen extends StatelessWidget {
  final AnimalData animal;
  const MinigameScreen({super.key, required this.animal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greenDark,
      body: Stack(children: [
        Container(decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D2B1A), Color(0xFF1A4A2E)],
          ),
        )),
        _buildMinigame(context),
        // Back button
        Positioned(
          top: 10, left: 10,
          child: SafeArea(child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: Colors.white.withOpacity(0.2), width: 1),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 16),
            ),
          )),
        ),
      ]),
    );
  }

  Widget _buildMinigame(BuildContext context) {
    void onComplete(int stars) {
      GameState().completeMinigame(animal.id, stars);
      Navigator.of(context).pop();
      showDialog(
        context: context,
        builder: (_) => _ResultDialog(animal: animal, stars: stars),
      );
    }

    switch (animal.minigame) {
      case MinigameType.memoryCards:
        return MemoryCardGame(animal: animal, onComplete: onComplete);
      case MinigameType.silhouette:
        return SilhouetteGame(animal: animal, onComplete: onComplete);
      case MinigameType.trivia:
        return TriviaGame(animal: animal, onComplete: onComplete);
      case MinigameType.colorMatch:
        return ColorMatchGame(animal: animal, onComplete: onComplete);
      case MinigameType.puzzle:
        return PuzzleGame(animal: animal, onComplete: onComplete);
      case MinigameType.soundMatch:
        return SoundMatchGame(animal: animal, onComplete: onComplete);
      case MinigameType.taming:
        return TamingGame(animal: animal, onComplete: onComplete);
    }
  }
}

// ─── Result dialog ────────────────────────────────────────────────────────────
class _ResultDialog extends StatelessWidget {
  final AnimalData animal;
  final int stars;
  const _ResultDialog({required this.animal, required this.stars});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF1A4A2E), Color(0xFF0D2B1A)]),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: AppColors.greenAccent.withOpacity(0.4), width: 2),
          boxShadow: [
            BoxShadow(
                color: AppColors.greenAccent.withOpacity(0.12),
                blurRadius: 30),
          ],
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(animal.emoji, style: const TextStyle(fontSize: 60)),
          const SizedBox(height: 12),
          Text(
            stars == 3
                ? '¡Perfecto! 🎉'
                : stars == 2
                    ? '¡Muy bien! 😊'
                    : '¡Completado! 👏',
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (i) => Text(
              i < stars ? '⭐' : '☆',
              style: const TextStyle(fontSize: 34),
            )),
          ),
          const SizedBox(height: 8),
          Text(
            '+${stars * 50} puntos · +${stars * 10} 🪙',
            style: const TextStyle(
                color: AppColors.greenAccent,
                fontWeight: FontWeight.bold,
                fontSize: 14),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('¡Continuar explorando!'),
          ),
        ]),
      ),
    );
  }
}
