// test/data/item_data_test.dart
//
// Tests para el catálogo de la tienda (`ShopCatalog`) y el modelo `ShopItem`.
// Cubren las helpers de filtrado por categoría, búsqueda por id, los flags
// computados (`isMinigamePowerUp`, `isUsableFromBag`) y el pool de loot.

import 'package:flutter_test/flutter_test.dart';
import 'package:animalgo_game/data/item_data.dart';

void main() {
  group('ShopItem flags', () {
    test('isMinigamePowerUp cubre todos los efectos de minijuego', () {
      const powerUpEffects = [
        ItemEffect.luckyCharm,
        ItemEffect.coinDoubler,
        ItemEffect.xpBoost,
        ItemEffect.goldenPass,
        ItemEffect.reviveScroll,
        ItemEffect.timeExtender,
        ItemEffect.hintReveal,
      ];
      for (final e in powerUpEffects) {
        final i = ShopItem(
          id: 'x', name: 'x', emoji: '?', description: 'x',
          category: ItemCategory.powerup, price: 0, effect: e,
        );
        expect(i.isMinigamePowerUp, isTrue, reason: 'efecto $e');
      }
    });

    test('isMinigamePowerUp es false para comida y none', () {
      final apple = ShopCatalog.findById('apple')!;
      expect(apple.isMinigamePowerUp, isFalse);

      const noEffect = ShopItem(
        id: 'x', name: 'x', emoji: '?', description: 'x',
        category: ItemCategory.gear, price: 0,
      );
      expect(noEffect.isMinigamePowerUp, isFalse);
    });

    test('isUsableFromBag cubre comida, mapa y power-ups', () {
      final apple = ShopCatalog.findById('apple')!;
      final boots = ShopCatalog.findById('boots')!;
      final compass = ShopCatalog.findById('compass')!;
      final lucky = ShopCatalog.findById('lucky_charm')!;
      expect(apple.isUsableFromBag, isTrue);
      expect(boots.isUsableFromBag, isTrue);
      expect(compass.isUsableFromBag, isTrue);
      expect(lucky.isUsableFromBag, isTrue);
    });

    test('isUsableFromBag es false para skins', () {
      final ninja = ShopCatalog.findById('skin_ninja')!;
      expect(ninja.isUsableFromBag, isFalse);
    });
  });

  group('ShopCatalog.byCategory', () {
    test('devuelve la lista correcta para cada categoría', () {
      expect(ShopCatalog.byCategory(ItemCategory.food), ShopCatalog.food);
      expect(ShopCatalog.byCategory(ItemCategory.gear), ShopCatalog.gear);
      expect(ShopCatalog.byCategory(ItemCategory.powerup), ShopCatalog.powerups);
      expect(ShopCatalog.byCategory(ItemCategory.skin), ShopCatalog.skins);
    });

    test('todos los items de cada categoría usan esa categoría', () {
      for (final cat in ItemCategory.values) {
        for (final item in ShopCatalog.byCategory(cat)) {
          expect(item.category, cat);
        }
      }
    });
  });

  group('ShopCatalog.findById', () {
    test('encuentra items en cualquier categoría', () {
      expect(ShopCatalog.findById('apple')?.category, ItemCategory.food);
      expect(ShopCatalog.findById('torch')?.category, ItemCategory.gear);
      expect(ShopCatalog.findById('lucky_charm')?.category, ItemCategory.powerup);
      expect(ShopCatalog.findById('skin_ninja')?.category, ItemCategory.skin);
    });

    test('devuelve null para ids inexistentes', () {
      expect(ShopCatalog.findById('nope'), isNull);
    });
  });

  group('ShopCatalog integrity', () {
    test('todos los precios son positivos', () {
      final all = [
        ...ShopCatalog.food,
        ...ShopCatalog.gear,
        ...ShopCatalog.powerups,
        ...ShopCatalog.skins,
      ];
      for (final i in all) {
        expect(i.price, greaterThan(0), reason: '${i.id} con precio inválido');
      }
    });

    test('los ids globales son únicos en todo el catálogo', () {
      final ids = <String>[
        ...ShopCatalog.food.map((i) => i.id),
        ...ShopCatalog.gear.map((i) => i.id),
        ...ShopCatalog.powerups.map((i) => i.id),
        ...ShopCatalog.skins.map((i) => i.id),
      ];
      expect(ids.toSet().length, ids.length);
    });
  });

  group('ShopCatalog.lootPool', () {
    test('contiene toda la comida y excluye power-ups en gemas', () {
      final pool = ShopCatalog.lootPool;
      for (final f in ShopCatalog.food) {
        expect(pool.contains(f), isTrue, reason: '${f.id} no está en lootPool');
      }
      // Ningún elemento del lootPool debe pagarse en gemas (configurable: comida puede usar gemas como drumstick).
      // Pero los powerups en gemas SÍ deben quedar fuera.
      final gemPowerUps = ShopCatalog.powerups
          .where((p) => p.currency == ItemCurrency.gems)
          .toList();
      for (final g in gemPowerUps) {
        expect(pool.contains(g), isFalse,
            reason: '${g.id} (gemas) no debería estar en lootPool');
      }
    });
  });
}
