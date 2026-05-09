// lib/data/food_atlas.dart
//
// Atlas de comidas pixel-art usado para reemplazar los emojis de los items
// recogibles del mapa y de la tienda.
//
// Imagen: assets/images/items/foods.png
//   - Pega aquí el PNG con cuadrícula uniforme (cellSize × cellSize px).
//   - Por defecto asumimos celdas de 64×64 (ajusta `cellSize` si difiere).
//
// Cómo usar:
//   final cell = FoodAtlas.cellFor('apple');     // → (col, row) o null si no
//   final src  = FoodAtlas.assetPath;            // path del PNG.
//
// Si la imagen aún no está colocada, los renderers caen al emoji original.

class FoodCell {
  final int col;
  final int row;
  const FoodCell(this.col, this.row);
}

abstract class FoodAtlas {
  static const String assetPath = 'assets/images/items/foods.png';

  /// Tamaño de cada celda en el PNG (en píxeles).
  /// Cambia este valor si tu spritesheet usa otra resolución (32, 48, 96…).
  static const int cellSize = 64;

  /// Mapeo `id de item / tipo recogible` → posición en el atlas.
  ///
  /// Las coordenadas (col, row) son 0-indexadas desde la esquina superior
  /// izquierda. Ajusta los valores para que coincidan con tu PNG.
  ///
  /// Si un id no aparece en el mapa, el sistema renderiza el emoji original.
  static const Map<String, FoodCell> _cells = {
    // ── Items recogibles del mundo (CollectibleItem.itemType) ──────────
    'mushroom':   FoodCell(2, 5), // pumpkin/seta-like
    'berry':      FoodCell(0, 4), // jam jar / arándano
    'leaf':       FoodCell(7, 5), // brócoli / hoja
    'gem':        FoodCell(8, 0), // donut iluminado (placeholder visual)
    'star':       FoodCell(8, 4), // pieza dorada
    // ── Comidas (catálogo de tienda) ─────────────────────────────────
    'apple':      FoodCell(0, 0),
    'peach':      FoodCell(1, 0),
    'green_apple':FoodCell(2, 0),
    'avocado':    FoodCell(3, 0),
    'donut':      FoodCell(4, 0),
    'beer':       FoodCell(5, 0),
    'milk':       FoodCell(6, 0),
    'bread':      FoodCell(7, 0),
    'pumpkin':    FoodCell(8, 0),
    'burger':     FoodCell(0, 1),
    'cake':       FoodCell(1, 1),
    'cheesecake': FoodCell(2, 1),
    'jam':        FoodCell(3, 1),
    'eggplant':   FoodCell(5, 1),
    'peppers':    FoodCell(6, 1),
    'drumstick':  FoodCell(7, 1),
    'sushi':      FoodCell(8, 1),
    'cinnamon':   FoodCell(0, 2),
    'corn_dog':   FoodCell(4, 2),
    'croissant':  FoodCell(7, 2),
    'butter':     FoodCell(8, 2),
    'fries':      FoodCell(1, 3),
    'green_tea':  FoodCell(2, 3),
    'coffee':     FoodCell(3, 3),
    'hotdog':     FoodCell(4, 3),
    'soup':       FoodCell(5, 3),
    'kebab':      FoodCell(1, 4),
    'melon':      FoodCell(3, 4),
    'pancakes':   FoodCell(4, 4),
    'pie':        FoodCell(0, 5),
    'pizza':      FoodCell(4, 5),
    'pretzel':    FoodCell(5, 5),
    'salad':      FoodCell(4, 6),
    'sandwich':   FoodCell(1, 7),
    'sausage':    FoodCell(3, 7),
    'smoothie':   FoodCell(4, 7),
    'watermelon': FoodCell(5, 7),
    'honey':      FoodCell(6, 0),
    'berries':    FoodCell(0, 4),
    'chestnut':   FoodCell(8, 0),
    'carrot':     FoodCell(7, 5),
    'banana':     FoodCell(1, 0),
    'steak':      FoodCell(0, 1),
  };

  static FoodCell? cellFor(String id) => _cells[id];
}
