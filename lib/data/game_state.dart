// lib/data/game_state.dart
// Estado global del juego: animales descubiertos, objetos, puntuación

import 'animal_data.dart';

class GameState {
  static final GameState _instance = GameState._internal();
  factory GameState() => _instance;
  GameState._internal();

  // Animales descubiertos (ids)
  final Set<String> discoveredAnimals = {};

  // Objetos recogidos
  final List<String> collectedItems = [];

  // Puntuación total
  int score = 0;

  // Monedas
  int coins = 0;

  // Minijuegos completados
  final Set<String> completedMinigames = {};

  // Posición del jugador guardada
  double savedX = 5;
  double savedY = 5;

  bool get allAnimalsDiscovered =>
      discoveredAnimals.length >= AnimalCatalog.all.length;

  int get discoveredCount => discoveredAnimals.length;

  void discoverAnimal(String animalId) {
    if (!discoveredAnimals.contains(animalId)) {
      discoveredAnimals.add(animalId);
      score += 100;
      coins += 20;
    }
  }

  void collectItem(String itemId) {
    collectedItems.add(itemId);
    score += 25;
    coins += 5;
  }

  void completeMinigame(String animalId, int starsEarned) {
    completedMinigames.add(animalId);
    score += starsEarned * 50;
    coins += starsEarned * 10;
  }

  bool isAnimalDiscovered(String id) => discoveredAnimals.contains(id);
  bool isMinigameCompleted(String id) => completedMinigames.contains(id);

  void reset() {
    discoveredAnimals.clear();
    collectedItems.clear();
    completedMinigames.clear();
    score = 0;
    coins = 0;
    savedX = 5;
    savedY = 5;
  }
}
