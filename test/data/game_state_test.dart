// test/data/game_state_test.dart
//
// Tests para `GameState` — singleton que gestiona progreso, economía,
// inventario, buffs de minijuegos y persistencia.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animalgo_game/data/game_state.dart';
import 'package:animalgo_game/data/item_data.dart';

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    GameState().reset();
    GameState().clearPendingEffects();
  });

  group('GameState — animales', () {
    test('discoverAnimal otorga puntos y monedas la primera vez', () {
      final gs = GameState();
      gs.discoverAnimal('fox');
      expect(gs.isAnimalDiscovered('fox'), isTrue);
      expect(gs.score, 100);
      expect(gs.coins, 5);
      expect(gs.coinsEarnedTotal, 5);
    });

    test('discoverAnimal es idempotente (no duplica recompensa)', () {
      final gs = GameState();
      gs.discoverAnimal('fox');
      gs.discoverAnimal('fox');
      expect(gs.coins, 5);
      expect(gs.discoveredAnimals.length, 1);
    });

    test('discoveredCount nunca supera el total del catálogo', () {
      final gs = GameState();
      gs.discoveredAnimals.addAll(['fox', 'bear', 'owl', 'frog', 'butterfly', 'deer', 'unknown_id']);
      expect(gs.discoveredCount, 6);
    });
  });

  group('GameState — minijuegos', () {
    test('completeMinigame con 3 estrellas otorga monedas y XP', () {
      final gs = GameState();
      gs.completeMinigame('fox', 3);
      // 3*3 = 9 monedas, 3*30 = 90 xp, score += 150 + 100 (descubrir)
      expect(gs.coins, 9 + 5);
      expect(gs.completedMinigames.contains('fox'), isTrue);
      expect(gs.discoveredAnimals.contains('fox'), isTrue);
    });

    test('completeMinigame con 1 estrella NO descubre el animal', () {
      final gs = GameState();
      gs.completeMinigame('fox', 1);
      expect(gs.completedMinigames.contains('fox'), isFalse);
      expect(gs.discoveredAnimals.contains('fox'), isFalse);
    });

    test('luckyCharm añade +1 estrella al resultado', () {
      final gs = GameState();
      gs.activatePowerUp('lucky_charm');
      gs.completeMinigame('fox', 1); // 1+1 = 2 → descubre
      expect(gs.completedMinigames.contains('fox'), isTrue);
    });

    test('coinDoubler duplica las monedas obtenidas', () {
      final gs = GameState();
      gs.activatePowerUp('coin_doubler');
      final before = gs.coins;
      gs.completeMinigame('fox', 2); // 2*3*2 = 12 monedas + 5 (descubrir)
      expect(gs.coins - before, 12 + 5);
    });
  });

  group('GameState — buffs de minijuego', () {
    test('activatePowerUp consume del inventario y marca pendiente', () {
      final gs = GameState();
      final qtyAntes = gs.getQty('lucky_charm');
      final ok = gs.activatePowerUp('lucky_charm');
      expect(ok, isTrue);
      expect(gs.getQty('lucky_charm'), qtyAntes - 1);
      expect(gs.hasPendingEffect(ItemEffect.luckyCharm), isTrue);
    });

    test('activatePowerUp falla si no hay stock', () {
      final gs = GameState();
      gs.inventory.remove('lucky_charm');
      expect(gs.activatePowerUp('lucky_charm'), isFalse);
    });

    test('activatePowerUp falla si el item no es power-up de minijuego', () {
      final gs = GameState();
      expect(gs.activatePowerUp('apple'), isFalse);
    });

    test('clearPendingEffects vacía los buffs', () {
      final gs = GameState();
      gs.activatePowerUp('lucky_charm');
      gs.clearPendingEffects();
      expect(gs.pendingEffects, isEmpty);
    });
  });

  group('GameState — inventario y tienda', () {
    test('buyItem con monedas suficientes reduce coins y suma stock', () {
      final gs = GameState();
      gs.coins = 100;
      final apple = ShopCatalog.findById('apple')!;
      final qty0 = gs.getQty('apple');
      final ok = gs.buyItem(apple);
      expect(ok, isTrue);
      expect(gs.coins, 100 - apple.price);
      expect(gs.getQty('apple'), qty0 + 1);
      expect(gs.itemsBoughtTotal, 1);
    });

    test('buyItem falla si no hay monedas', () {
      final gs = GameState();
      gs.coins = 0;
      final apple = ShopCatalog.findById('apple')!;
      expect(gs.buyItem(apple), isFalse);
    });

    test('useItem decrementa el stock y elimina cuando llega a 0', () {
      final gs = GameState();
      gs.inventory['test_item'] = 1;
      gs.useItem('test_item');
      expect(gs.inventory.containsKey('test_item'), isFalse);
    });

    test('addItem incrementa cantidades acumulando', () {
      final gs = GameState();
      gs.addItem('berries', 3);
      gs.addItem('berries', 2);
      expect(gs.getQty('berries'), greaterThanOrEqualTo(5));
    });

    test('sellItem por monedas devuelve el 50% del precio', () {
      final gs = GameState();
      gs.inventory['apple'] = 2;
      gs.coins = 0;
      final apple = ShopCatalog.findById('apple')!;
      final gained = gs.sellItem('apple', forXp: false);
      expect(gained, (apple.price * 0.5).round());
      expect(gs.coins, gained);
    });

    test('collectMapItem es idempotente por id', () {
      final gs = GameState();
      gs.collectMapItem('mushroom');
      final qty1 = gs.getQty('mushroom');
      gs.collectMapItem('mushroom');
      expect(gs.getQty('mushroom'), qty1, reason: 'no debe duplicarse');
    });
  });

  group('GameState — misiones', () {
    test('claimMission aplica recompensa una sola vez', () {
      final gs = GameState();
      gs.coins = 0;
      final ok = gs.claimMission('m_first_animal', coins: 10, xp: 50);
      expect(ok, isTrue);
      expect(gs.coins, 10);

      final repeat = gs.claimMission('m_first_animal', coins: 10, xp: 50);
      expect(repeat, isFalse);
      expect(gs.coins, 10);
    });
  });

  group('GameState — cofres', () {
    test('isChestOpened es false para cofres no abiertos', () {
      final gs = GameState();
      expect(gs.isChestOpened('chest_a'), isFalse);
    });

    test('openChest dos veces no otorga recompensa la segunda', () {
      final gs = GameState();
      final first = gs.openChest('chest_a');
      final second = gs.openChest('chest_a');
      expect(first.coins, greaterThan(0));
      expect(second.coins, 0);
      expect(gs.isChestOpened('chest_a'), isTrue);
    });
  });

  group('GameState — reset', () {
    test('reset limpia progreso y deja el estado en valores iniciales', () {
      final gs = GameState();
      gs.discoverAnimal('fox');
      gs.coins = 999;
      gs.level = 10;
      gs.reset();
      expect(gs.coins, 0);
      expect(gs.level, 1);
      expect(gs.discoveredAnimals, isEmpty);
      expect(gs.openedChests, isEmpty);
    });
  });
}
