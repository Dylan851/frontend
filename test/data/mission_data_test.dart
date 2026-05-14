// test/data/mission_data_test.dart
//
// Tests para `Mission` y `MissionCatalog`. Verifican el cálculo del progreso
// frente a un `GameState` controlado, los flags `isComplete` / `isClaimable` /
// `isClaimed` y la búsqueda por id.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animalgo_game/data/mission_data.dart';
import 'package:animalgo_game/data/game_state.dart';

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    GameState().reset();
  });

  group('Mission.progress', () {
    test('discoverAnimals lee el set discoveredAnimals', () {
      final gs = GameState();
      gs.discoveredAnimals.addAll(['fox', 'bear', 'owl']);
      final m = MissionCatalog.byId('m_explorer3')!;
      expect(m.progress(gs), 3);
    });

    test('completeMinigames lee el set completedMinigames', () {
      final gs = GameState();
      gs.completedMinigames.addAll(['fox', 'bear']);
      final m = MissionCatalog.byId('m_mini1')!;
      expect(m.progress(gs), 2);
    });

    test('reachLevel devuelve el nivel actual del jugador', () {
      final gs = GameState();
      gs.level = 8;
      final m = MissionCatalog.byId('m_lvl5')!;
      expect(m.progress(gs), 8);
    });

    test('earnCoins lee coinsEarnedTotal (no las monedas actuales)', () {
      final gs = GameState();
      gs.coinsEarnedTotal = 700;
      gs.coins = 5; // las gastadas no afectan
      final m = MissionCatalog.byId('m_coins500')!;
      expect(m.progress(gs), 700);
    });
  });

  group('Mission.isComplete / isClaimable / isClaimed', () {
    test('isComplete es true cuando se alcanza el target', () {
      final gs = GameState();
      gs.level = 10;
      final m = MissionCatalog.byId('m_lvl10')!;
      expect(m.isComplete(gs), isTrue);
    });

    test('isClaimable solo si está completa y no reclamada', () {
      final gs = GameState();
      gs.level = 10;
      final m = MissionCatalog.byId('m_lvl10')!;
      expect(m.isClaimable(gs), isTrue);

      gs.claimedMissions.add(m.id);
      expect(m.isClaimable(gs), isFalse);
      expect(m.isClaimed(gs), isTrue);
    });
  });

  group('Mission.pct', () {
    test('está acotado entre 0.0 y 1.0', () {
      final gs = GameState();
      gs.coinsEarnedTotal = 99999;
      final m = MissionCatalog.byId('m_coins500')!;
      expect(m.pct(gs), 1.0);
    });

    test('progreso a la mitad da 0.5', () {
      final gs = GameState();
      gs.coinsEarnedTotal = 250;
      final m = MissionCatalog.byId('m_coins500')!;
      expect(m.pct(gs), closeTo(0.5, 1e-9));
    });

    test('target 0 devuelve 0', () {
      final gs = GameState();
      const m = Mission(
        id: 'tmp', emoji: '?', title: 't', description: 'd',
        goal: MissionGoal.discoverAnimals, target: 0,
      );
      expect(m.pct(gs), 0.0);
    });
  });

  group('MissionCatalog', () {
    test('byId devuelve la misión correcta', () {
      expect(MissionCatalog.byId('m_first_animal')?.target, 1);
    });

    test('byId devuelve null para id desconocido', () {
      expect(MissionCatalog.byId('nope'), isNull);
    });

    test('todos los ids son únicos', () {
      final ids = MissionCatalog.all.map((m) => m.id).toList();
      expect(ids.toSet().length, ids.length);
    });
  });
}
