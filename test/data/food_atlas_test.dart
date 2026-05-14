// test/data/food_atlas_test.dart
//
// Tests para el atlas de comida (`FoodAtlas`) usado para renderizar items
// recogibles del mapa con una sprite-sheet en lugar del emoji.

import 'package:flutter_test/flutter_test.dart';
import 'package:animalgo_game/data/food_atlas.dart';

void main() {
  group('FoodAtlas', () {
    test('assetPath apunta al PNG esperado', () {
      expect(FoodAtlas.assetPath, 'assets/images/items/foods.png');
    });

    test('cellSize tiene un valor razonable', () {
      expect(FoodAtlas.cellSize, greaterThan(0));
    });

    test('cellFor devuelve coordenadas para items conocidos', () {
      final apple = FoodAtlas.cellFor('apple');
      expect(apple, isNotNull);
      expect(apple!.col, isNonNegative);
      expect(apple.row, isNonNegative);
    });

    test('cellFor devuelve null para ids desconocidos', () {
      expect(FoodAtlas.cellFor('not_a_food_id'), isNull);
    });
  });
}
