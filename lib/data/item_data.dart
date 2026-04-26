// lib/data/item_data.dart
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
//  ITEM MODEL
// ─────────────────────────────────────────────
enum ItemCategory { food, gear, powerup, skin }
enum ItemCurrency { coins, gems }

/// Efecto funcional que un item aplica al usarse.
/// Los efectos de minijuego se consumen al entrar al minijuego.
enum ItemEffect {
  none,
  // Comida (mundo): restaura vitales.
  restoreHealth,
  restoreEnergy,
  // Power-ups para minijuegos (activos al entrar al minijuego):
  luckyCharm,     // +1 estrella al resultado (máx 3)
  coinDoubler,    // duplica monedas obtenidas
  xpBoost,        // +2× XP obtenido
  goldenPass,     // completa con 3★ sin jugar
  reviveScroll,   // permite reintentar sin perder nada si fallas
  timeExtender,   // +tiempo extra (minijuegos con tiempo)
  hintReveal,     // revela una pista / respuesta correcta
  // Mapa:
  radarAnimals,   // muestra animales cercanos
  speedBoost,     // +velocidad temporal en el mapa
}

class ShopItem {
  final String id;
  final String name;
  final String emoji;
  final String description;
  final ItemCategory category;
  final int price;
  final ItemCurrency currency;
  final bool isFeatured;
  final String? badgeLabel;
  final ItemEffect effect;
  final int magnitude; // depende del efecto (p. ej. salud +X, tiempo +X s)

  const ShopItem({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.category,
    required this.price,
    this.currency = ItemCurrency.coins,
    this.isFeatured = false,
    this.badgeLabel,
    this.effect = ItemEffect.none,
    this.magnitude = 0,
  });

  /// True si el item puede usarse dentro de un minijuego.
  bool get isMinigamePowerUp {
    switch (effect) {
      case ItemEffect.luckyCharm:
      case ItemEffect.coinDoubler:
      case ItemEffect.xpBoost:
      case ItemEffect.goldenPass:
      case ItemEffect.reviveScroll:
      case ItemEffect.timeExtender:
      case ItemEffect.hintReveal:
        return true;
      default:
        return false;
    }
  }

  /// True si el item puede usarse fuera del minijuego (comida, etc.).
  bool get isUsableFromBag {
    return effect == ItemEffect.restoreHealth ||
        effect == ItemEffect.restoreEnergy ||
        effect == ItemEffect.speedBoost ||
        effect == ItemEffect.radarAnimals ||
        isMinigamePowerUp;
  }
}

class InventoryItem {
  final String itemId;
  int quantity;
  InventoryItem({required this.itemId, required this.quantity});
}

// ─────────────────────────────────────────────
//  SHOP CATALOG
// ─────────────────────────────────────────────
abstract class ShopCatalog {
  // ── Food (restauración) ──────────────────────────────
  static const food = <ShopItem>[
    ShopItem(id: 'apple',     name: 'Manzana',       emoji: '🍎', description: 'Restaura 20 ❤️ de salud',       category: ItemCategory.food, price: 15, effect: ItemEffect.restoreHealth, magnitude: 20),
    ShopItem(id: 'steak',     name: 'Carne Asada',   emoji: '🥩', description: 'Restaura 50 ❤️ de salud',       category: ItemCategory.food, price: 35, effect: ItemEffect.restoreHealth, magnitude: 50),
    ShopItem(id: 'drumstick', name: 'Pierna Asada',  emoji: '🍗', description: 'Restaura 100 ❤️ al instante',   category: ItemCategory.food, price: 5,  currency: ItemCurrency.gems, isFeatured: true, badgeLabel: '💎', effect: ItemEffect.restoreHealth, magnitude: 100),
    ShopItem(id: 'honey',     name: 'Miel Silvestre',emoji: '🍯', description: 'Restaura 30 ⚡ de energía',      category: ItemCategory.food, price: 25, effect: ItemEffect.restoreEnergy, magnitude: 30),
    ShopItem(id: 'berries',   name: 'Arándanos',     emoji: '🫐', description: 'Restaura 10 ❤️ + 15 ⚡',         category: ItemCategory.food, price: 12, effect: ItemEffect.restoreEnergy, magnitude: 15),
    ShopItem(id: 'chestnut',  name: 'Castaña',       emoji: '🌰', description: 'Restaura 15 ⚡ de energía',      category: ItemCategory.food, price: 10, effect: ItemEffect.restoreEnergy, magnitude: 15),
    ShopItem(id: 'carrot',    name: 'Zanahoria',     emoji: '🥕', description: 'Restaura 25 ❤️ de salud',       category: ItemCategory.food, price: 18, effect: ItemEffect.restoreHealth, magnitude: 25),
    ShopItem(id: 'banana',    name: 'Plátano',       emoji: '🍌', description: 'Restaura 35 ⚡ de energía',      category: ItemCategory.food, price: 20, effect: ItemEffect.restoreEnergy, magnitude: 35),
  ];

  // ── Gear (equipo pasivo) ─────────────────────────────
  static const gear = <ShopItem>[
    ShopItem(id: 'backpack', name: 'Mochila Pro',  emoji: '🎒', description: '+10 slots de inventario',        category: ItemCategory.gear, price: 20, currency: ItemCurrency.gems, isFeatured: true, badgeLabel: 'NEW'),
    ShopItem(id: 'torch',    name: 'Linterna',     emoji: '🔦', description: 'Visión nocturna en el mapa',     category: ItemCategory.gear, price: 80),
    ShopItem(id: 'compass',  name: 'Brújula',      emoji: '🧭', description: 'Radar: revela animales cercanos',category: ItemCategory.gear, price: 120, effect: ItemEffect.radarAnimals),
    ShopItem(id: 'camera',   name: 'Cámara',       emoji: '📷', description: 'Foto bonus: +2× monedas al descubrir', category: ItemCategory.gear, price: 95),
    ShopItem(id: 'gloves',   name: 'Guantes',      emoji: '🧤', description: 'Recoger más rápido del mapa',    category: ItemCategory.gear, price: 55),
    ShopItem(id: 'boots',    name: 'Botas Ágiles', emoji: '👢', description: '+15% velocidad al caminar',      category: ItemCategory.gear, price: 70, effect: ItemEffect.speedBoost, magnitude: 15),
    ShopItem(id: 'trap',     name: 'Trampa Cámara',emoji: '🪤', description: 'Fotos automáticas cada minuto',  category: ItemCategory.gear, price: 15, currency: ItemCurrency.gems),
    ShopItem(id: 'scope',    name: 'Catalejo',     emoji: '🔭', description: 'Ver animales lejanos',           category: ItemCategory.gear, price: 25, currency: ItemCurrency.gems),
  ];

  // ── Power-Ups (consumibles en minijuegos) ────────────
  static const powerups = <ShopItem>[
    ShopItem(id: 'lucky_charm',   name: 'Amuleto de Suerte', emoji: '🍀', description: '+1 estrella al completar un minijuego',  category: ItemCategory.powerup, price: 40, effect: ItemEffect.luckyCharm,   magnitude: 1, isFeatured: true, badgeLabel: '⭐'),
    ShopItem(id: 'coin_doubler',  name: 'Moneda Dorada',     emoji: '🪙', description: 'Duplica las monedas del próximo minijuego', category: ItemCategory.powerup, price: 60, effect: ItemEffect.coinDoubler,  magnitude: 2),
    ShopItem(id: 'xp_potion',     name: 'Poción XP',         emoji: '🧪', description: '+2× XP del próximo minijuego',             category: ItemCategory.powerup, price: 10, currency: ItemCurrency.gems, effect: ItemEffect.xpBoost, magnitude: 2, isFeatured: true),
    ShopItem(id: 'golden_pass',   name: 'Pase Dorado',       emoji: '🎫', description: '¡3★ automáticas sin jugar!',               category: ItemCategory.powerup, price: 25, currency: ItemCurrency.gems, effect: ItemEffect.goldenPass, magnitude: 3, badgeLabel: 'OP'),
    ShopItem(id: 'revive_scroll', name: 'Pergamino Vida',    emoji: '📜', description: 'Si pierdes, reintentas gratis',            category: ItemCategory.powerup, price: 8,  currency: ItemCurrency.gems, effect: ItemEffect.reviveScroll),
    ShopItem(id: 'time_hourglass',name: 'Reloj de Arena',    emoji: '⌛', description: '+15s de tiempo extra',                     category: ItemCategory.powerup, price: 55, effect: ItemEffect.timeExtender, magnitude: 15),
    ShopItem(id: 'hint_crystal',  name: 'Cristal de Pista',  emoji: '🔮', description: 'Revela la respuesta correcta 1 vez',       category: ItemCategory.powerup, price: 35, effect: ItemEffect.hintReveal,   magnitude: 1),
    ShopItem(id: 'mystery_box',   name: 'Caja Sorpresa',     emoji: '🎁', description: 'Abre para ganar un item aleatorio',        category: ItemCategory.powerup, price: 200),
  ];

  // ── Skins ────────────────────────────────
  static const skins = <ShopItem>[
    ShopItem(id: 'skin_scientist', name: 'Científico',  emoji: '👨‍🔬', description: 'Skin exclusivo',  category: ItemCategory.skin, price: 40, currency: ItemCurrency.gems, isFeatured: true, badgeLabel: 'HOT'),
    ShopItem(id: 'skin_wizard',    name: 'Mago',        emoji: '🧙',  description: 'Skin legendario', category: ItemCategory.skin, price: 60, currency: ItemCurrency.gems),
    ShopItem(id: 'skin_builder',   name: 'Constructor', emoji: '👷',  description: 'Skin común',      category: ItemCategory.skin, price: 300),
    ShopItem(id: 'skin_ninja',     name: 'Ninja',       emoji: '🥷',  description: 'Skin raro',        category: ItemCategory.skin, price: 35, currency: ItemCurrency.gems),
    ShopItem(id: 'skin_astronaut', name: 'Astronauta',  emoji: '🧑‍🚀', description: 'Skin épico',      category: ItemCategory.skin, price: 55, currency: ItemCurrency.gems),
    ShopItem(id: 'skin_cowboy',    name: 'Vaquero',     emoji: '🤠',  description: 'Skin común',      category: ItemCategory.skin, price: 250),
    ShopItem(id: 'skin_artist',    name: 'Artista',     emoji: '🧑‍🎨', description: 'Skin raro',        category: ItemCategory.skin, price: 28, currency: ItemCurrency.gems),
    ShopItem(id: 'skin_hero',      name: 'Superhéroe',  emoji: '🦸',  description: 'Skin legendario', category: ItemCategory.skin, price: 80, currency: ItemCurrency.gems),
  ];

  static List<ShopItem> byCategory(ItemCategory cat) {
    switch (cat) {
      case ItemCategory.food:    return food;
      case ItemCategory.gear:    return gear;
      case ItemCategory.powerup: return powerups;
      case ItemCategory.skin:    return skins;
    }
  }

  static ShopItem? findById(String id) {
    for (final list in [food, gear, powerups, skins]) {
      try { return list.firstWhere((i) => i.id == id); } catch (_) {}
    }
    return null;
  }

  /// Items que pueden salir en cofres del mundo.
  static List<ShopItem> get lootPool => [
        ...food,
        ...powerups.where((p) => p.currency == ItemCurrency.coins),
      ];
}

// ─────────────────────────────────────────────
//  MAP DATA
// ─────────────────────────────────────────────
class MapWorld {
  final String id;
  final String name;
  final String emoji;
  final String description;
  final int animalsCount;
  final int itemsCount;
  final int requiredLevel;   // 0 = unlocked by default
  final Color primaryColor;
  final Color secondaryColor;
  final bool isUnlocked;

  const MapWorld({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.animalsCount,
    required this.itemsCount,
    required this.requiredLevel,
    required this.primaryColor,
    required this.secondaryColor,
    this.isUnlocked = false,
  });
}

abstract class MapCatalog {
  static const all = <MapWorld>[
    MapWorld(
      id: 'jungle', name: 'Aldea Canta', emoji: '🗺️',
      description: 'Ruta 1 de Kanto — sendero entre hierba alta.',
      animalsCount: 6, itemsCount: 10, requiredLevel: 0,
      primaryColor: Color(0xFF1A4A2E), secondaryColor: Color(0xFF2D7A3A),
      isUnlocked: true,
    ),
    MapWorld(
      id: 'savanna', name: 'Ruta del Bosque', emoji: '🌳',
      description: 'Ruta 3 de Kanto — caminos entre montañas.',
      animalsCount: 6, itemsCount: 10, requiredLevel: 3,
      primaryColor: Color(0xFF3A6A24), secondaryColor: Color(0xFF7AB53A),
    ),
    MapWorld(
      id: 'farm', name: 'Ruta Rocosa', emoji: '⛰️',
      description: 'Ruta 9 de Kanto — terreno escarpado.',
      animalsCount: 6, itemsCount: 10, requiredLevel: 5,
      primaryColor: Color(0xFF5C7A2E), secondaryColor: Color(0xFF8BB53A),
    ),
    MapWorld(
      id: 'ocean', name: 'Ruta Costera', emoji: '🌊',
      description: 'Ruta 11 de Kanto — sendero junto al mar.',
      animalsCount: 6, itemsCount: 10, requiredLevel: 7,
      primaryColor: Color(0xFF0D4A7A), secondaryColor: Color(0xFF1A7FC4),
    ),
    MapWorld(
      id: 'arctic', name: 'Bosque Helado', emoji: '❄️',
      description: 'Variante helada de la Ruta 1 — animales en pleno invierno.',
      animalsCount: 6, itemsCount: 10, requiredLevel: 10,
      primaryColor: Color(0xFF2A4A6A), secondaryColor: Color(0xFF4A7AAA),
    ),
    MapWorld(
      id: 'desert', name: 'Sendero Seco', emoji: '🌵',
      description: 'Variante árida de la Ruta 3 — dunas y criaturas adaptadas.',
      animalsCount: 6, itemsCount: 10, requiredLevel: 15,
      primaryColor: Color(0xFF7A4A1A), secondaryColor: Color(0xFFC48A3A),
    ),
    MapWorld(
      id: 'volcano', name: 'Cumbre Rocosa', emoji: '🌋',
      description: 'Variante volcánica de la Ruta 9 — rocas calientes.',
      animalsCount: 6, itemsCount: 10, requiredLevel: 20,
      primaryColor: Color(0xFF4A0D0D), secondaryColor: Color(0xFF8B1A1A),
    ),
    MapWorld(
      id: 'sky', name: 'Mirador Costero', emoji: '🌤️',
      description: 'Variante elevada de la Ruta 11 — vistas sobre el mar.',
      animalsCount: 6, itemsCount: 10, requiredLevel: 25,
      primaryColor: Color(0xFF1A3A6A), secondaryColor: Color(0xFF3A6ACC),
    ),
  ];
}
