// lib/data/item_data.dart
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
//  ITEM MODEL
// ─────────────────────────────────────────────
enum ItemCategory { food, gear, special, skin }
enum ItemCurrency { coins, gems }

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
  final Map<String, int> effects; // e.g. {'health': 20, 'energy': 10}

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
    this.effects = const {},
  });
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
  // ── Food ──────────────────────────────────
  static const food = <ShopItem>[
    ShopItem(id: 'apple',    name: 'Manzana',      emoji: '🍎', description: '+20 ❤️ salud',         category: ItemCategory.food,  price: 15,  isFeatured: true,  badgeLabel: '¡HOT!', effects: {'health': 20}),
    ShopItem(id: 'steak',    name: 'Carne Asada',  emoji: '🥩', description: '+50 ❤️ salud',         category: ItemCategory.food,  price: 35,  effects: {'health': 50}),
    ShopItem(id: 'honey',    name: 'Miel Silvestre',emoji: '🍯', description: '+30 ⚡ energía',       category: ItemCategory.food,  price: 25,  effects: {'energy': 30}),
    ShopItem(id: 'mushroom', name: 'Seta Mágica',  emoji: '🍄', description: '+2× velocidad 30s',   category: ItemCategory.food,  price: 40,  effects: {'speed': 2}),
    ShopItem(id: 'berries',  name: 'Arándanos',    emoji: '🫐', description: '+10 ❤️ +5 ⚡',         category: ItemCategory.food,  price: 12,  effects: {'health': 10, 'energy': 5}),
    ShopItem(id: 'chestnut', name: 'Castaña',      emoji: '🌰', description: '+15 ⚡ energía',       category: ItemCategory.food,  price: 10,  effects: {'energy': 15}),
    ShopItem(id: 'drumstick',name: 'Pierna Asada', emoji: '🍖', description: '+100 ❤️ salud',        category: ItemCategory.food,  price: 5,   currency: ItemCurrency.gems, isFeatured: true, badgeLabel: '💎'),
    ShopItem(id: 'carrot',   name: 'Zanahoria',    emoji: '🥕', description: '+25 ❤️ salud',         category: ItemCategory.food,  price: 18,  effects: {'health': 25}),
  ];

  // ── Gear ──────────────────────────────────
  static const gear = <ShopItem>[
    ShopItem(id: 'backpack', name: 'Mochila Pro',  emoji: '🎒', description: '+10 slots inventario', category: ItemCategory.gear,    price: 20, currency: ItemCurrency.gems, isFeatured: true, badgeLabel: 'NEW'),
    ShopItem(id: 'torch',    name: 'Linterna',     emoji: '🔦', description: '+Visión nocturna',      category: ItemCategory.gear,    price: 80),
    ShopItem(id: 'compass',  name: 'Brújula',      emoji: '🧭', description: 'Radar de animales',     category: ItemCategory.gear,    price: 120),
    ShopItem(id: 'camera',   name: 'Cámara',       emoji: '📷', description: 'Foto bonus x2',         category: ItemCategory.gear,    price: 95),
    ShopItem(id: 'gloves',   name: 'Guantes',      emoji: '🧤', description: 'Recoger más rápido',    category: ItemCategory.gear,    price: 55),
    ShopItem(id: 'boots',    name: 'Botas',        emoji: '👢', description: '+15% velocidad',        category: ItemCategory.gear,    price: 70),
    ShopItem(id: 'trap',     name: 'Trampa Cámara',emoji: '🪤', description: 'Fotos automáticas',     category: ItemCategory.gear,    price: 15, currency: ItemCurrency.gems),
    ShopItem(id: 'scope',    name: 'Catalejo',     emoji: '🔭', description: 'Ver animales lejanos',  category: ItemCategory.gear,    price: 25, currency: ItemCurrency.gems),
  ];

  // ── Special ──────────────────────────────
  static const special = <ShopItem>[
    ShopItem(id: 'xp_potion',  name: 'Poción XP',     emoji: '🧪', description: '+2× XP durante 10 min', category: ItemCategory.special, price: 10, currency: ItemCurrency.gems, isFeatured: true, badgeLabel: '⭐'),
    ShopItem(id: 'aura',       name: 'Aura Brillante', emoji: '🌟', description: 'Atrae animales',         category: ItemCategory.special, price: 30, currency: ItemCurrency.gems, isFeatured: true),
    ShopItem(id: 'map_key',    name: 'Llave de Mapa',  emoji: '🗝️', description: 'Desbloquea 1 mapa',      category: ItemCategory.special, price: 50, currency: ItemCurrency.gems),
    ShopItem(id: 'mystery_box',name: 'Caja Sorpresa',  emoji: '🎁', description: 'Ítem aleatorio',         category: ItemCategory.special, price: 200),
    ShopItem(id: 'turbo',      name: 'Turbo Sprint',   emoji: '⚡', description: '+3× velocidad 15s',      category: ItemCategory.special, price: 60),
    ShopItem(id: 'shield',     name: 'Escudo',         emoji: '🛡️', description: 'Invulnerable 20s',       category: ItemCategory.special, price: 8,  currency: ItemCurrency.gems),
    ShopItem(id: 'orb',        name: 'Orbe Animal',    emoji: '🔮', description: 'Revela un animal',       category: ItemCategory.special, price: 12, currency: ItemCurrency.gems),
    ShopItem(id: 'coins_pack', name: 'Pack Monedas',   emoji: '💫', description: '500 monedas de golpe',   category: ItemCategory.special, price: 3,  currency: ItemCurrency.gems),
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
      case ItemCategory.special: return special;
      case ItemCategory.skin:    return skins;
    }
  }

  static ShopItem? findById(String id) {
    for (final list in [food, gear, special, skins]) {
      try { return list.firstWhere((i) => i.id == id); } catch (_) {}
    }
    return null;
  }
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
