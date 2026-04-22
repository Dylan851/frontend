// lib/game/map/maps_reader.dart
// Lector de mapas Tiled desde assets/maps/ (en lugar de assets/images/)
import 'package:bonfire/bonfire.dart';
import 'package:tiledjsonreader/map/tiled_map.dart';
import 'package:tiledjsonreader/tiledjsonreader.dart';

class MapsAssetReader extends WorldMapReader<TiledMap> {
  final String asset; // ej: 'assets/maps/forest.json'
  late final TiledJsonReader _reader;

  @override
  late final String basePath;

  MapsAssetReader(this.asset) {
    // basePath vacío: Flame.images.load() ya añade 'assets/images/' internamente,
    // así que el path de imagen en el tileset JSON debe ser relativo a assets/images/
    basePath = '';
    _reader = TiledJsonReader(asset);
  }

  @override
  Future<TiledMap> readMap() => _reader.read();
}
