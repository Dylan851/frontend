// test/data/animal_data_test.dart
//
// Tests unitarios para el catálogo de animales (`AnimalCatalog`) y el modelo
// `AnimalData`. Verifican integridad del catálogo, búsqueda por id y la
// inmutabilidad/copia mediante `copyWith`.

import 'package:flutter_test/flutter_test.dart';
import 'package:animalgo_game/data/animal_data.dart';

void main() {
  group('AnimalData', () {
    test('copyWith mantiene los campos originales y solo cambia isDiscovered', () {
      final fox = AnimalCatalog.findById('fox')!;
      final discovered = fox.copyWith(isDiscovered: true);

      expect(discovered.id, fox.id);
      expect(discovered.name, fox.name);
      expect(discovered.minigame, fox.minigame);
      expect(discovered.isDiscovered, isTrue);
      expect(fox.isDiscovered, isFalse, reason: 'el original no debe mutarse');
    });

    test('copyWith sin argumentos preserva isDiscovered', () {
      final owl = AnimalCatalog.findById('owl')!;
      final cp = owl.copyWith();
      expect(cp.isDiscovered, owl.isDiscovered);
    });
  });

  group('AnimalCatalog.all (catálogo legacy)', () {
    test('contiene exactamente 6 animales', () {
      expect(AnimalCatalog.all.length, 6);
    });

    test('todos los ids son únicos', () {
      final ids = AnimalCatalog.all.map((a) => a.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('cada animal tiene al menos un dato curioso', () {
      for (final a in AnimalCatalog.all) {
        expect(a.funFacts, isNotEmpty, reason: 'animal ${a.id} sin funFacts');
      }
    });

    test('todos los animales tienen nombre, hábitat y descripción no vacíos', () {
      for (final a in AnimalCatalog.all) {
        expect(a.name.trim(), isNotEmpty);
        expect(a.habitat.trim(), isNotEmpty);
        expect(a.description.trim(), isNotEmpty);
      }
    });
  });

  group('AnimalCatalog.basicPack', () {
    test('contiene 15 animales del asset pack básico', () {
      expect(AnimalCatalog.basicPack.length, 15);
    });

    test('todos los ids del basicPack son únicos', () {
      final ids = AnimalCatalog.basicPack.map((a) => a.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('todos los animales del basicPack tienen spriteAsset definido', () {
      for (final a in AnimalCatalog.basicPack) {
        expect(a.spriteAsset, isNotNull, reason: '${a.id} sin spriteAsset');
        expect(a.spriteAsset!.endsWith('.png'), isTrue);
      }
    });

    test('todos los animales del basicPack tienen sound y wikiFact', () {
      for (final a in AnimalCatalog.basicPack) {
        expect(a.sound, isNotEmpty, reason: '${a.id} sin sound');
        expect(a.wikiFact, isNotEmpty, reason: '${a.id} sin wikiFact');
      }
    });
  });

  group('AnimalCatalog.findById', () {
    test('encuentra animales del catálogo legacy', () {
      expect(AnimalCatalog.findById('fox')?.name, 'Zorro Rojo');
      expect(AnimalCatalog.findById('bear')?.name, 'Oso Pardo');
    });

    test('encuentra animales del basicPack', () {
      expect(AnimalCatalog.findById('chicken')?.name, 'Gallina');
      expect(AnimalCatalog.findById('wolf')?.name, 'Lobo');
    });

    test('devuelve null cuando el id no existe', () {
      expect(AnimalCatalog.findById('unicorn'), isNull);
      expect(AnimalCatalog.findById(''), isNull);
    });
  });
}
