// lib/game/map/jungle_map_builder.dart
// Construye el mapa procedural de la selva usando MatrixMapGenerator de Bonfire

import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

/// Tipos de tile del mapa
class TileType {
  static const int grass      = 0;
  static const int grassDark  = 1;
  static const int water      = 2;
  static const int path       = 3;
  static const int tree       = 4;
  static const int bush       = 5;
  static const int flower     = 6;
  static const int rock       = 7;
}

/// Genera el mapa de la selva de forma procedural usando Bonfire
class JungleMapBuilder {
  static const int mapWidth  = 40;
  static const int mapHeight = 30;
  static const double tileSize = 32.0;

  /// Matriz del mapa — 0 = pasable, otros = bloqueantes según tipo
  static List<List<int>> get mapMatrix => [
    [4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4],
    [4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4],
    [4,0,6,0,0,5,0,0,0,1,0,0,0,0,0,5,0,0,0,0,0,0,0,0,6,0,0,5,0,0,0,0,0,0,0,0,0,0,0,4],
    [4,0,0,0,0,0,0,3,3,3,3,3,3,3,3,3,3,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4],
    [4,0,5,0,0,0,0,3,0,0,0,0,0,0,0,0,0,3,0,0,4,4,0,0,0,0,0,0,7,0,0,0,0,0,0,0,0,0,0,4],
    [4,0,0,0,0,0,0,3,0,1,1,0,0,6,0,1,1,3,0,0,4,4,0,0,0,0,0,0,0,0,0,5,0,0,6,0,0,0,0,4],
    [4,0,0,0,7,0,0,3,0,0,0,0,0,0,0,0,0,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4],
    [4,0,0,0,0,0,0,3,0,0,0,0,0,0,0,0,0,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4],
    [4,0,6,0,0,0,0,3,3,3,0,3,3,3,3,0,3,3,0,0,0,0,2,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,4],
    [4,0,0,0,0,0,0,0,0,3,0,3,0,0,0,0,0,0,0,0,0,0,2,0,0,2,0,0,0,0,0,0,0,0,0,0,5,0,0,4],
    [4,0,0,5,0,0,0,0,0,3,0,3,0,0,0,0,0,0,0,0,0,0,2,0,0,2,0,0,0,0,7,0,0,0,0,0,0,0,0,4],
    [4,0,0,0,0,0,0,0,0,3,3,3,0,0,0,0,0,0,0,0,0,0,2,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,4],
    [4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4],
    [4,0,0,0,4,4,0,0,0,0,0,0,0,0,0,5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4],
    [4,0,0,0,4,4,0,0,0,0,0,0,0,0,0,0,0,0,3,3,3,3,3,3,3,0,0,0,0,0,0,0,0,0,0,0,6,0,0,4],
    [4,0,0,0,0,0,0,0,7,0,0,0,0,0,0,0,0,0,3,0,0,0,0,0,3,0,0,0,0,0,0,0,5,0,0,0,0,0,0,4],
    [4,0,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,0,0,0,0,0,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4],
    [4,0,0,0,0,5,0,0,0,0,0,0,0,0,0,0,0,0,3,3,3,3,3,3,3,0,0,0,0,0,0,0,0,0,0,0,0,7,0,4],
    [4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,0,0,0,0,4],
    [4,0,0,0,0,0,0,0,0,0,0,0,0,4,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4],
    [4,0,0,7,0,0,0,0,0,0,0,0,0,4,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4],
    [4,0,0,0,0,0,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,7,0,0,0,0,0,0,0,0,0,0,4],
    [4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,0,0,4],
    [4,0,0,5,0,0,0,0,0,0,0,0,0,0,0,0,0,3,3,3,3,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4],
    [4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,0,0,0,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4],
    [4,0,6,0,0,0,0,0,0,7,0,0,0,0,0,0,0,3,0,0,0,3,0,0,0,0,0,6,0,0,0,0,0,0,0,0,0,0,0,4],
    [4,0,0,0,0,5,0,0,0,0,0,0,0,0,0,0,0,3,3,3,3,3,0,0,0,0,0,0,0,0,0,0,0,0,5,0,0,0,0,4],
    [4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4],
    [4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4],
    [4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4],
  ];

  /// Construye el mapa de Bonfire a partir de la matriz
  static WorldMap build() {
    final matrix = mapMatrix;
    final tiles = <TileModel>[];

    for (int row = 0; row < matrix.length; row++) {
      for (int col = 0; col < matrix[row].length; col++) {
        final type = matrix[row][col];
        tiles.add(_buildTile(type, col, row));
      }
    }

    return WorldMap(tiles, forceTileSize: Vector2.all(tileSize));
  }

  static TileModel _buildTile(int type, int col, int row) {
    final x = col.toDouble();
    final y = row.toDouble();

    switch (type) {
      case TileType.tree:
        return TileModel(
          x: x, y: y,
          width: 1, height: 1,
          sprite: TileModelSprite(
            path: 'tiles/tree.png',
            size: Vector2(16, 16),
          ),
          collisions: [RectangleHitbox(size: Vector2(tileSize, tileSize))],
          color: const Color(0xFF1B6B3A),
        );
      case TileType.water:
        return TileModel(
          x: x, y: y,
          width: 1, height: 1,
          sprite: TileModelSprite(
            path: 'tiles/water.png',
            size: Vector2(16, 16),
          ),
          collisions: [RectangleHitbox(size: Vector2(tileSize, tileSize))],
          color: const Color(0xFF1A6FA0),
        );
      case TileType.path:
        return TileModel(
          x: x, y: y,
          width: 1, height: 1,
          color: const Color(0xFFD4A96A),
        );
      case TileType.rock:
        return TileModel(
          x: x, y: y,
          width: 1, height: 1,
          color: const Color(0xFF7A7A7A),
          collisions: [RectangleHitbox(size: Vector2(tileSize, tileSize))],
        );
      case TileType.bush:
        return TileModel(
          x: x, y: y,
          width: 1, height: 1,
          color: const Color(0xFF2D7A3A),
          collisions: [RectangleHitbox(size: Vector2(tileSize * 0.6, tileSize * 0.6), position: Vector2(tileSize * 0.2, tileSize * 0.2))],
        );
      case TileType.flower:
        return TileModel(
          x: x, y: y,
          width: 1, height: 1,
          color: const Color(0xFF56A832),
        );
      case TileType.grassDark:
        return TileModel(
          x: x, y: y,
          width: 1, height: 1,
          color: const Color(0xFF2A7040),
        );
      default: // grass
        return TileModel(
          x: x, y: y,
          width: 1, height: 1,
          color: const Color(0xFF3A8C4E),
        );
    }
  }
}
