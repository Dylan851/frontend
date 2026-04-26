// lib/data/mission_data.dart
//
// Catálogo de misiones de AnimalGO! Cada misión tiene un ID estable, una
// meta numérica y una recompensa (monedas/gemas/XP). El progreso se calcula
// dinámicamente leyendo el GameState (animales descubiertos, ítems
// recogidos, minijuegos completados, nivel, monedas acumuladas, etc.).
//
import 'game_state.dart';
import 'animal_data.dart';

enum MissionGoal {
  discoverAnimals,
  completeMinigames,
  collectItems,
  reachLevel,
  earnCoins,
  openChests,
  buyItems,
  visitMaps,
}

class Mission {
  final String id;
  final String emoji;
  final String title;
  final String description;
  final MissionGoal goal;
  final int target;
  final int rewardCoins;
  final int rewardGems;
  final int rewardXp;

  const Mission({
    required this.id,
    required this.emoji,
    required this.title,
    required this.description,
    required this.goal,
    required this.target,
    this.rewardCoins = 0,
    this.rewardGems = 0,
    this.rewardXp = 0,
  });

  /// Progreso actual (0..target) leyendo el GameState.
  int progress(GameState gs) {
    switch (goal) {
      case MissionGoal.discoverAnimals:   return gs.discoveredAnimals.length;
      case MissionGoal.completeMinigames: return gs.completedMinigames.length;
      case MissionGoal.collectItems:      return gs.collectedMapItems.length;
      case MissionGoal.reachLevel:        return gs.level;
      case MissionGoal.earnCoins:         return gs.coinsEarnedTotal;
      case MissionGoal.openChests:        return gs.openedChests.length;
      case MissionGoal.buyItems:          return gs.itemsBoughtTotal;
      case MissionGoal.visitMaps:         return gs.mapsIntroSeen.length;
    }
  }

  bool isComplete(GameState gs) => progress(gs) >= target;
  bool isClaimed(GameState gs)  => gs.claimedMissions.contains(id);
  bool isClaimable(GameState gs) => isComplete(gs) && !isClaimed(gs);

  double pct(GameState gs) {
    if (target <= 0) return 0;
    return (progress(gs) / target).clamp(0.0, 1.0);
  }
}

abstract class MissionCatalog {
  static final List<Mission> all = [
    const Mission(
      id: 'm_first_animal',
      emoji: '🐾',
      title: 'Primer encuentro',
      description: 'Descubre tu primer animal en el bosque.',
      goal: MissionGoal.discoverAnimals,
      target: 1,
      rewardCoins: 30,
      rewardXp: 50,
    ),
    const Mission(
      id: 'm_explorer3',
      emoji: '🦊',
      title: 'Aprendiz de explorador',
      description: 'Descubre 3 animales diferentes.',
      goal: MissionGoal.discoverAnimals,
      target: 3,
      rewardCoins: 80,
      rewardXp: 120,
    ),
    Mission(
      id: 'm_naturalist',
      emoji: '📖',
      title: 'Naturalista',
      description: 'Descubre la mitad de los animales del catálogo.',
      goal: MissionGoal.discoverAnimals,
      target: (AnimalCatalog.all.length / 2).ceil().clamp(1, 999),
      rewardCoins: 200,
      rewardGems: 1,
      rewardXp: 300,
    ),
    const Mission(
      id: 'm_mini1',
      emoji: '🎮',
      title: 'Primer minijuego',
      description: 'Completa tu primer minijuego con un animal.',
      goal: MissionGoal.completeMinigames,
      target: 1,
      rewardCoins: 50,
      rewardXp: 80,
    ),
    const Mission(
      id: 'm_mini5',
      emoji: '🏆',
      title: 'Maestro del juego',
      description: 'Completa 5 minijuegos.',
      goal: MissionGoal.completeMinigames,
      target: 5,
      rewardCoins: 150,
      rewardGems: 2,
      rewardXp: 250,
    ),
    const Mission(
      id: 'm_collect5',
      emoji: '🍎',
      title: 'Recolector novato',
      description: 'Recoge 5 ítems del mapa.',
      goal: MissionGoal.collectItems,
      target: 5,
      rewardCoins: 60,
      rewardXp: 80,
    ),
    const Mission(
      id: 'm_chest3',
      emoji: '🎁',
      title: 'Cazador de tesoros',
      description: 'Abre 3 cofres escondidos en el bosque.',
      goal: MissionGoal.openChests,
      target: 3,
      rewardCoins: 100,
      rewardGems: 1,
      rewardXp: 120,
    ),
    const Mission(
      id: 'm_lvl5',
      emoji: '⭐',
      title: 'Suben las estrellas',
      description: 'Alcanza el nivel 5.',
      goal: MissionGoal.reachLevel,
      target: 5,
      rewardCoins: 120,
      rewardXp: 150,
    ),
    const Mission(
      id: 'm_lvl10',
      emoji: '🌟',
      title: 'Ranger del bosque',
      description: 'Alcanza el nivel 10.',
      goal: MissionGoal.reachLevel,
      target: 10,
      rewardCoins: 250,
      rewardGems: 3,
      rewardXp: 400,
    ),
    const Mission(
      id: 'm_coins500',
      emoji: '🪙',
      title: 'Pequeño ahorrador',
      description: 'Acumula 500 monedas en total.',
      goal: MissionGoal.earnCoins,
      target: 500,
      rewardCoins: 100,
      rewardXp: 100,
    ),
    const Mission(
      id: 'm_buy3',
      emoji: '🛒',
      title: 'Cliente fiel',
      description: 'Compra 3 ítems en la tienda.',
      goal: MissionGoal.buyItems,
      target: 3,
      rewardCoins: 80,
      rewardXp: 80,
    ),
    const Mission(
      id: 'm_maps3',
      emoji: '🗺️',
      title: 'Viajero',
      description: 'Visita 3 mundos diferentes.',
      goal: MissionGoal.visitMaps,
      target: 3,
      rewardCoins: 150,
      rewardGems: 1,
      rewardXp: 200,
    ),
  ];

  static Mission? byId(String id) {
    for (final m in all) {
      if (m.id == id) return m;
    }
    return null;
  }
}
