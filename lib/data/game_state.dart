// lib/data/game_state.dart
import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import 'animal_data.dart';
import 'item_data.dart';

/// Resultado de abrir un cofre: monedas y, opcionalmente, un item extra.
class ChestReward {
  final int coins;
  final int gems;
  final ShopItem? bonusItem;
  ChestReward({required this.coins, this.gems = 0, this.bonusItem});
}

class GameState {
  static final GameState _instance = GameState._internal();
  static Future<void> Function(GameState state)? autosaveSyncHook;
  factory GameState() => _instance;
  GameState._internal();

  // â”€â”€ Progreso â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  final Set<String> discoveredAnimals = {};
  final Set<String> completedMinigames = {};
  final Set<String> earnedAchievements = {
    'first_animal',
    'first_items',
    'first_minigame'
  };
  // Ãtems recogidos del mapa â€” persisten entre entradas al mismo mapa.
  final Set<String> collectedMapItems = {};
  // Cofres abiertos del mapa (persistentes).
  final Set<String> openedChests = {};
  // Tutoriales vistos (persistentes dentro de la sesiÃ³n).
  bool hasSeenAppTutorial = false;
  final Set<String> mapsIntroSeen = {};
  // Misiones reclamadas (recompensa cobrada).
  final Set<String> claimedMissions = {};
  // Acumulados para las metas de misiones.
  int coinsEarnedTotal = 0;
  int itemsBoughtTotal = 0;

  // â”€â”€ EconomÃ­a â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  int score = 0;
  int coins = 0;
  int gems = 0;

  // â”€â”€ Perfil â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  String playerName = 'Explorador';
  String selectedSkin = 'ðŸ§‘';
  int level = 7;
  int currentXp = 680;
  int maxXp = 1000;
  String currentMapId = 'jungle';

  // â”€â”€ Inventario â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  final Map<String, int> inventory = {
    'apple': 3, 'steak': 2, 'honey': 1,
    'berries': 5, 'chestnut': 6, 'carrot': 2,
    'banana': 2,
    'torch': 1, 'compass': 1, 'camera': 1,
    'gloves': 1, 'boots': 1,
    // Power-ups iniciales para que el jugador pruebe el sistema.
    'lucky_charm': 1,
    'time_hourglass': 1,
    'hint_crystal': 1,
    'revive_scroll': 1,
    'xp_potion': 2,
  };

  // Slots de equipo: head, hands, body, feet
  final Map<String, String?> equipped = {
    'head': 'skin_cowboy',
    'hands': 'gloves',
    'body': null,
    'feet': 'boots',
  };

  // â”€â”€ Buffs activos para el PRÃ“XIMO minijuego â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // Consumidos automÃ¡ticamente al entrar/finalizar el minijuego.
  final Set<ItemEffect> _pendingMinigameEffects = <ItemEffect>{};

  // â”€â”€ Mapa â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  double savedX = 0;
  double savedY = 0;
  String? savedMapId;

  // â”€â”€ Personaje seleccionado â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  String selectedCharacter = 'hero';

  // â”€â”€ Ajustes â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  bool musicOn = true;
  bool sfxOn = true;
  double musicVol = 0.7;
  bool joystickOn = true;
  bool vibrationOn = false;
  double sensitivity = 0.55;
  bool nightMode = false;
  double hudBrightness = 0.8;
  bool cloudSave = true;
  String language = 'EspaÃ±ol';

  // â”€â”€ Getters â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  bool get allAnimalsDiscovered =>
      discoveredAnimals.length >= AnimalCatalog.all.length;
  int get discoveredCount => discoveredAnimals.length;
  double get xpPercent => currentXp / maxXp;

  // â”€â”€ Animales â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  void discoverAnimal(String id) {
    if (!discoveredAnimals.contains(id)) {
      discoveredAnimals.add(id);
      score += 100;
      coins += 20;
      coinsEarnedTotal += 20;
      _checkAchievements();
      autosave();
    }
  }

  bool isAnimalDiscovered(String id) => discoveredAnimals.contains(id);
  bool isMinigameCompleted(String id) => completedMinigames.contains(id);

  void completeMinigame(String animalId, int stars) {
    // Aplicar buffs pendientes
    int finalStars = stars;
    if (_pendingMinigameEffects.contains(ItemEffect.luckyCharm)) {
      finalStars = math.min(3, finalStars + 1);
    }
    if (_pendingMinigameEffects.contains(ItemEffect.goldenPass)) {
      finalStars = 3;
    }
    int coinMult =
        _pendingMinigameEffects.contains(ItemEffect.coinDoubler) ? 2 : 1;
    int xpMult = _pendingMinigameEffects.contains(ItemEffect.xpBoost) ? 2 : 1;

    if (finalStars >= 2) {
      discoverAnimal(animalId);
      completedMinigames.add(animalId);
    }
    score += finalStars * 50;
    final cReward = finalStars * 10 * coinMult;
    coins += cReward;
    coinsEarnedTotal += cReward;
    currentXp += finalStars * 30 * xpMult;
    if (currentXp >= maxXp) {
      level++;
      currentXp -= maxXp;
      maxXp = (maxXp * 1.2).round();
    }

    // Consumir todos los buffs tras completar (revive se consume al reintentar).
    _pendingMinigameEffects.removeAll([
      ItemEffect.luckyCharm,
      ItemEffect.coinDoubler,
      ItemEffect.xpBoost,
      ItemEffect.goldenPass,
      ItemEffect.timeExtender,
      ItemEffect.hintReveal,
    ]);
    autosave();
  }

  // â”€â”€ Buffs de minijuego â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  bool hasPendingEffect(ItemEffect e) => _pendingMinigameEffects.contains(e);
  Set<ItemEffect> get pendingEffects =>
      Set.unmodifiable(_pendingMinigameEffects);

  /// Activa un power-up para el prÃ³ximo minijuego. Consume 1 del inventario.
  /// Devuelve true si se activÃ³ correctamente.
  bool activatePowerUp(String itemId) {
    final item = ShopCatalog.findById(itemId);
    if (item == null || !item.isMinigamePowerUp) return false;
    if ((inventory[itemId] ?? 0) <= 0) return false;
    if (_pendingMinigameEffects.contains(item.effect))
      return false; // ya activo
    _pendingMinigameEffects.add(item.effect);
    useItem(itemId);
    return true;
  }

  /// Consume un efecto especÃ­fico (usado por el minijuego cuando se aplica).
  void consumeEffect(ItemEffect e) {
    _pendingMinigameEffects.remove(e);
  }

  /// Limpia los buffs pendientes (al salir del minijuego sin terminar, etc.).
  void clearPendingEffects() {
    _pendingMinigameEffects.clear();
  }

  // â”€â”€ Inventario â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  int getQty(String itemId) => inventory[itemId] ?? 0;
  bool hasItem(String itemId) => (inventory[itemId] ?? 0) > 0;

  bool buyItem(ShopItem item) {
    if (item.currency == ItemCurrency.coins && coins >= item.price) {
      coins -= item.price;
      inventory[item.id] = (inventory[item.id] ?? 0) + 1;
      itemsBoughtTotal += 1;
      autosave();
      return true;
    } else if (item.currency == ItemCurrency.gems && gems >= item.price) {
      gems -= item.price;
      inventory[item.id] = (inventory[item.id] ?? 0) + 1;
      itemsBoughtTotal += 1;
      autosave();
      return true;
    }
    return false;
  }

  void useItem(String itemId) {
    if ((inventory[itemId] ?? 0) > 0) {
      inventory[itemId] = inventory[itemId]! - 1;
      if (inventory[itemId] == 0) inventory.remove(itemId);
      autosave();
    }
  }

  /// Tasa de canje (50 % del precio de compra) en monedas.
  int sellPriceCoins(ShopItem item) =>
      (item.price * (item.currency == ItemCurrency.gems ? 8 : 1) * 0.5).round();

  /// Tasa de canje (40 % del precio) en XP.
  int sellPriceXp(ShopItem item) =>
      (item.price * (item.currency == ItemCurrency.gems ? 8 : 1) * 0.4).round();

  /// Canjea 1 unidad del Ã­tem. Si [forXp] es true se otorga XP, si no monedas.
  /// Devuelve la cantidad otorgada (0 si no habÃ­a stock).
  int sellItem(String itemId, {required bool forXp}) {
    if ((inventory[itemId] ?? 0) <= 0) return 0;
    final item = ShopCatalog.findById(itemId);
    if (item == null) return 0;
    inventory[itemId] = inventory[itemId]! - 1;
    if (inventory[itemId] == 0) inventory.remove(itemId);
    int gained;
    if (forXp) {
      gained = sellPriceXp(item);
      currentXp += gained;
      while (currentXp >= maxXp) {
        level++;
        currentXp -= maxXp;
        maxXp = (maxXp * 1.2).round();
      }
    } else {
      gained = sellPriceCoins(item);
      coins += gained;
      coinsEarnedTotal += gained;
    }
    autosave();
    return gained;
  }

  void addItem(String itemId, [int qty = 1]) {
    inventory[itemId] = (inventory[itemId] ?? 0) + qty;
    autosave();
  }

  void collectMapItem(String itemId) {
    if (collectedMapItems.contains(itemId)) return;
    collectedMapItems.add(itemId);
    inventory[itemId] = (inventory[itemId] ?? 0) + 1;
    score += 25;
    coins += 5;
    coinsEarnedTotal += 5;
    autosave();
  }

  bool isMapItemCollected(String itemId) => collectedMapItems.contains(itemId);

  // â”€â”€ Cofres del mundo â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  bool isChestOpened(String chestId) => openedChests.contains(chestId);

  /// Abre un cofre. Otorga monedas (50-200), posible gema (10%) y 60% prob. de un item.
  ChestReward openChest(String chestId) {
    if (openedChests.contains(chestId)) {
      return ChestReward(coins: 0);
    }
    openedChests.add(chestId);
    final rng = math.Random();
    final gold = 50 + rng.nextInt(151); // 50..200
    final gemBonus = rng.nextDouble() < 0.10 ? 1 + rng.nextInt(3) : 0;
    ShopItem? bonus;
    if (rng.nextDouble() < 0.60) {
      final pool = ShopCatalog.lootPool;
      bonus = pool[rng.nextInt(pool.length)];
      addItem(bonus.id);
    }
    coins += gold;
    coinsEarnedTotal += gold;
    gems += gemBonus;
    score += gold;
    autosave();
    return ChestReward(coins: gold, gems: gemBonus, bonusItem: bonus);
  }

  // â”€â”€ Logros â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  bool hasAchievement(String id) => earnedAchievements.contains(id);
  void _checkAchievements() {
    if (discoveredCount >= 1) earnedAchievements.add('first_animal');
    if (discoveredCount >= 6) earnedAchievements.add('all_animals');
  }

  // â”€â”€ Misiones â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  /// Reclama la recompensa de una misiÃ³n completada (idempotente).
  /// Devuelve true si se aplicÃ³ la recompensa.
  bool claimMission(String missionId,
      {int coins = 0, int gems = 0, int xp = 0}) {
    if (claimedMissions.contains(missionId)) return false;
    claimedMissions.add(missionId);
    this.coins += coins;
    coinsEarnedTotal += coins;
    this.gems += gems;
    if (xp > 0) {
      currentXp += xp;
      while (currentXp >= maxXp) {
        level++;
        currentXp -= maxXp;
        maxXp = (maxXp * 1.2).round();
      }
    }
    autosave();
    return true;
  }

  // â”€â”€ Persistencia (SharedPreferences) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  static const _prefsKey = 'wq_state_v1';
  Timer? _saveDebounce;
  bool _loaded = false;
  bool get isLoaded => _loaded;

  Map<String, dynamic> _toJson() => {
        'discoveredAnimals': discoveredAnimals.toList(),
        'completedMinigames': completedMinigames.toList(),
        'earnedAchievements': earnedAchievements.toList(),
        'collectedMapItems': collectedMapItems.toList(),
        'openedChests': openedChests.toList(),
        'hasSeenAppTutorial': hasSeenAppTutorial,
        'mapsIntroSeen': mapsIntroSeen.toList(),
        'claimedMissions': claimedMissions.toList(),
        'coinsEarnedTotal': coinsEarnedTotal,
        'itemsBoughtTotal': itemsBoughtTotal,
        'score': score,
        'coins': coins,
        'gems': gems,
        'playerName': playerName,
        'selectedSkin': selectedSkin,
        'level': level,
        'currentXp': currentXp,
        'maxXp': maxXp,
        'currentMapId': currentMapId,
        'inventory': inventory,
        'equipped': equipped,
        'savedX': savedX,
        'savedY': savedY,
        'savedMapId': savedMapId,
        'selectedCharacter': selectedCharacter,
        'musicOn': musicOn,
        'sfxOn': sfxOn,
        'musicVol': musicVol,
        'joystickOn': joystickOn,
        'vibrationOn': vibrationOn,
        'sensitivity': sensitivity,
        'nightMode': nightMode,
        'hudBrightness': hudBrightness,
        'cloudSave': cloudSave,
        'language': language,
      };

  void _fromJson(Map<String, dynamic> j) {
    void setS(Set<String> s, String key) {
      final v = j[key];
      if (v is List) {
        s.clear();
        s.addAll(v.cast<String>());
      }
    }

    setS(discoveredAnimals, 'discoveredAnimals');
    setS(completedMinigames, 'completedMinigames');
    setS(earnedAchievements, 'earnedAchievements');
    setS(collectedMapItems, 'collectedMapItems');
    setS(openedChests, 'openedChests');
    setS(mapsIntroSeen, 'mapsIntroSeen');
    setS(claimedMissions, 'claimedMissions');
    coinsEarnedTotal = j['coinsEarnedTotal'] ?? coinsEarnedTotal;
    itemsBoughtTotal = j['itemsBoughtTotal'] ?? itemsBoughtTotal;
    hasSeenAppTutorial = j['hasSeenAppTutorial'] ?? hasSeenAppTutorial;
    score = j['score'] ?? score;
    coins = j['coins'] ?? coins;
    gems = j['gems'] ?? gems;
    playerName = j['playerName'] ?? playerName;
    selectedSkin = j['selectedSkin'] ?? selectedSkin;
    level = j['level'] ?? level;
    currentXp = j['currentXp'] ?? currentXp;
    maxXp = j['maxXp'] ?? maxXp;
    currentMapId = j['currentMapId'] ?? currentMapId;
    if (j['inventory'] is Map) {
      inventory.clear();
      (j['inventory'] as Map).forEach((k, v) {
        if (v is int) inventory[k.toString()] = v;
      });
    }
    if (j['equipped'] is Map) {
      equipped.clear();
      (j['equipped'] as Map).forEach((k, v) {
        equipped[k.toString()] = v?.toString();
      });
    }
    savedX = (j['savedX'] as num?)?.toDouble() ?? savedX;
    savedY = (j['savedY'] as num?)?.toDouble() ?? savedY;
    savedMapId = j['savedMapId'] as String?;
    selectedCharacter = j['selectedCharacter'] ?? selectedCharacter;
    musicOn = j['musicOn'] ?? musicOn;
    sfxOn = j['sfxOn'] ?? sfxOn;
    musicVol = (j['musicVol'] as num?)?.toDouble() ?? musicVol;
    joystickOn = j['joystickOn'] ?? joystickOn;
    vibrationOn = j['vibrationOn'] ?? vibrationOn;
    sensitivity = (j['sensitivity'] as num?)?.toDouble() ?? sensitivity;
    nightMode = j['nightMode'] ?? nightMode;
    hudBrightness = (j['hudBrightness'] as num?)?.toDouble() ?? hudBrightness;
    cloudSave = j['cloudSave'] ?? cloudSave;
    language = j['language'] ?? language;
  }

  /// Cargar el estado guardado (llamar al arrancar la app).
  Future<void> load() async {
    try {
      final p = await SharedPreferences.getInstance();
      final raw = p.getString(_prefsKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) _fromJson(decoded);
      }
    } catch (_) {/* corrupt save: ignore */}
    _loaded = true;
  }

  /// Guardado inmediato.
  Future<void> save() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(_prefsKey, jsonEncode(_toJson()));
    } catch (_) {/* disk error: ignore */}
  }

  /// Guardado con debounce (500 ms) â€” agrupa varias mutaciones.
  void autosave() {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 500), () async {
      await save();
      final hook = autosaveSyncHook;
      if (hook != null) {
        unawaited(hook(this));
      }
    });
  }

  // â”€â”€ Reset â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  void reset() {
    discoveredAnimals.clear();
    completedMinigames.clear();
    earnedAchievements.clear();
    inventory.clear();
    openedChests.clear();
    _pendingMinigameEffects.clear();
    hasSeenAppTutorial = false;
    mapsIntroSeen.clear();
    claimedMissions.clear();
    coinsEarnedTotal = 0;
    itemsBoughtTotal = 0;
    score = 0;
    coins = 0;
    gems = 0;
    level = 1;
    currentXp = 0;
    maxXp = 1000;
    savedX = 0;
    savedY = 0;
    selectedCharacter = 'hero';
  }
}
