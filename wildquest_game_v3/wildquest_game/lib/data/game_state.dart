// lib/data/game_state.dart
import 'animal_data.dart';
import 'item_data.dart';

class GameState {
  static final GameState _instance = GameState._internal();
  factory GameState() => _instance;
  GameState._internal();

  // ── Progreso ──────────────────────────────
  final Set<String> discoveredAnimals   = {};
  final Set<String> completedMinigames  = {};
  final Set<String> earnedAchievements  = {'first_animal', 'first_items', 'first_minigame'};

  // ── Economía ──────────────────────────────
  int score = 2150;
  int coins = 1240;
  int gems  = 85;

  // ── Perfil ────────────────────────────────
  String playerName  = 'Explorador';
  String selectedSkin = '🧑';
  int    level        = 7;
  int    currentXp    = 680;
  int    maxXp        = 1000;
  String currentMapId = 'jungle';

  // ── Inventario ────────────────────────────
  // map itemId → quantity
  final Map<String, int> inventory = {
    'apple':    3, 'steak':   2, 'honey':   1,
    'berries':  5, 'mushroom':1, 'chestnut':6,
    'carrot':   2, 'torch':   1, 'compass': 1,
    'camera':   1, 'gloves':  1, 'boots':   1,
    'xp_potion':2, 'orb':     1,
  };

  // Slots de equipo: head, hands, body, feet
  final Map<String, String?> equipped = {
    'head':  'skin_cowboy',   // emoji 🤠 → hat slot
    'hands': 'gloves',
    'body':  null,
    'feet':  'boots',
  };

  // ── Mapa ──────────────────────────────────
  double savedX = 5;
  double savedY = 5;

  // ── Ajustes ───────────────────────────────
  bool  musicOn     = true;
  bool  sfxOn       = true;
  double musicVol   = 0.7;
  bool  joystickOn  = true;
  bool  vibrationOn = false;
  double sensitivity = 0.55;
  bool  nightMode   = false;
  double hudBrightness = 0.8;
  bool  cloudSave   = true;
  String language   = 'Español';

  // ── Getters ───────────────────────────────
  bool get allAnimalsDiscovered => discoveredAnimals.length >= AnimalCatalog.all.length;
  int  get discoveredCount      => discoveredAnimals.length;
  double get xpPercent          => currentXp / maxXp;

  // ── Animales ──────────────────────────────
  void discoverAnimal(String id) {
    if (!discoveredAnimals.contains(id)) {
      discoveredAnimals.add(id);
      score += 100;
      coins += 20;
      _checkAchievements();
    }
  }

  bool isAnimalDiscovered(String id) => discoveredAnimals.contains(id);
  bool isMinigameCompleted(String id) => completedMinigames.contains(id);

  void completeMinigame(String animalId, int stars) {
    completedMinigames.add(animalId);
    score += stars * 50;
    coins += stars * 10;
    currentXp += stars * 30;
    if (currentXp >= maxXp) { level++; currentXp -= maxXp; maxXp = (maxXp * 1.2).round(); }
  }

  // ── Inventario ────────────────────────────
  int  getQty(String itemId)  => inventory[itemId] ?? 0;
  bool hasItem(String itemId) => (inventory[itemId] ?? 0) > 0;

  bool buyItem(ShopItem item) {
    if (item.currency == ItemCurrency.coins && coins >= item.price) {
      coins -= item.price;
      inventory[item.id] = (inventory[item.id] ?? 0) + 1;
      return true;
    } else if (item.currency == ItemCurrency.gems && gems >= item.price) {
      gems -= item.price;
      inventory[item.id] = (inventory[item.id] ?? 0) + 1;
      return true;
    }
    return false;
  }

  void useItem(String itemId) {
    if ((inventory[itemId] ?? 0) > 0) {
      inventory[itemId] = inventory[itemId]! - 1;
      if (inventory[itemId] == 0) inventory.remove(itemId);
    }
  }

  void collectMapItem(String itemId) {
    inventory[itemId] = (inventory[itemId] ?? 0) + 1;
    score += 25; coins += 5;
  }

  // ── Logros ────────────────────────────────
  bool hasAchievement(String id) => earnedAchievements.contains(id);
  void _checkAchievements() {
    if (discoveredCount >= 1) earnedAchievements.add('first_animal');
    if (discoveredCount >= 6) earnedAchievements.add('all_animals');
  }

  // ── Reset ─────────────────────────────────
  void reset() {
    discoveredAnimals.clear(); completedMinigames.clear();
    earnedAchievements.clear(); inventory.clear();
    score = 0; coins = 0; gems = 0;
    level = 1; currentXp = 0; maxXp = 1000;
    savedX = 5; savedY = 5;
  }
}
