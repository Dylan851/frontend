// lib/screens/game_screen.dart
import 'dart:math' as math;
import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import '../game/actors/player_character.dart';
import '../game/actors/animal_npc.dart';
import '../game/objects/collectible_item.dart';
import '../game/overlays/hud_overlay.dart';
import '../game/overlays/encounter_overlay.dart';
import '../data/animal_data.dart';
import '../data/item_data.dart';
import '../data/game_state.dart';
import '../data/map_walkable.dart';
import '../game/map/maps_reader.dart';
import '../game/overlays/tutorial_overlay.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  AnimalData? currentAnimal;
  static const double _tile = 32.0;
  bool _showMapIntro = false;

  late final AnimationController _fadeInCtrl;
  late final AnimationController _ambientCtrl;
  late final Animation<double> _fadeIn;

  // Animales e items ahora se spawnean aleatoriamente en runtime por mapa.

  @override
  void initState() {
    super.initState();
    _fadeInCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 550))
      ..forward();
    _fadeIn = CurvedAnimation(parent: _fadeInCtrl, curve: Curves.easeOut);
    _ambientCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 6))
          ..repeat();
    // Intro de mapa la primera vez que se entra a este mapa.
    final gs = GameState();
    if (!gs.mapsIntroSeen.contains(gs.currentMapId)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _showMapIntro = true);
      });
    }
  }

  @override
  void dispose() {
    _fadeInCtrl.dispose();
    _ambientCtrl.dispose();
    super.dispose();
  }

  // ─── Mapa Kanto activo por id ──────────────────────────────────────────
  //  jungle  → Ruta 1 (Aldea Canta) · 44×40
  //  savanna → Ruta 3 (Bosque)      · 90×26
  //  farm    → Ruta 9 (Rocosa)      · 72×81
  //  ocean   → Ruta 11 (Costera)    · 72×69
  static const _mapSpec = <String, ({String file, int w, int h, int sx, int sy})>{
    'jungle':  (file: 'assets/maps/kanto1.json',  w: 44, h: 40, sx: 23, sy: 22),
    'savanna': (file: 'assets/maps/kanto3.json',  w: 90, h: 26, sx: 45, sy: 14),
    'farm':    (file: 'assets/maps/kanto9.json',  w: 72, h: 81, sx: 34, sy: 18),
    'ocean':   (file: 'assets/maps/kanto11.json', w: 72, h: 69, sx: 37, sy: 35),
    // Los 4 siguientes reutilizan las mismas rutas (el tileset Outside1
    // Spring no deja añadir más sin pasarse del límite WebGL 8192 px).
    'arctic':  (file: 'assets/maps/kanto1.json',  w: 44, h: 40, sx: 23, sy: 22),
    'desert':  (file: 'assets/maps/kanto3.json',  w: 90, h: 26, sx: 45, sy: 14),
    'volcano': (file: 'assets/maps/kanto9.json',  w: 72, h: 81, sx: 34, sy: 18),
    'sky':     (file: 'assets/maps/kanto11.json', w: 72, h: 69, sx: 37, sy: 35),
  };

  ({String file, int w, int h, int sx, int sy}) get _spec =>
      _mapSpec[GameState().currentMapId] ?? _mapSpec['jungle']!;

  String get _mapFile => _spec.file;

  Color get _mapBg {
    switch (GameState().currentMapId) {
      case 'savanna': return const Color(0xFF2A4A1A);
      case 'farm':    return const Color(0xFF3A4A2A);
      case 'ocean':   return const Color(0xFF0D2A3A);
      case 'jungle':
      default:
        return const Color(0xFF1A3010);
    }
  }

  Color get _mapTint {
    switch (GameState().currentMapId) {
      case 'savanna': return const Color(0x14A0E070);
      case 'farm':    return const Color(0x14C4A040);
      case 'ocean':   return const Color(0x1470C0FF);
      case 'jungle':
      default:
        return const Color(0x14004020);
    }
  }

  // Player start según mapa — siempre en zona abierta verificada.
  Vector2 get _playerStart {
    final gs = GameState();
    // Si la posición guardada pertenece a ESTE mapa y es válida, úsala.
    if (gs.savedMapId == gs.currentMapId && (gs.savedX > 0 || gs.savedY > 0)) {
      return Vector2(gs.savedX * _tile, gs.savedY * _tile);
    }
    final s = _spec;
    return Vector2(s.sx * _tile, s.sy * _tile);
  }

  @override
  Widget build(BuildContext context) {
    final gs = GameState();
    // Context usado por los cofres para abrir el diálogo de botín.
    CollectibleItem.uiContext = context;

    return Scaffold(
      body: Stack(children: [
        // ── Juego ────────────────────────────────────────────────────────
        FadeTransition(
          opacity: _fadeIn,
          child: BonfireWidget(
            map: WorldMapByTiled(MapsAssetReader(_mapFile)),
            player: AnimalGoPlayer(
              position: _playerStart,
              characterId: gs.selectedCharacter,
            ),
            components: [..._buildAnimals(), ..._buildItems(), ..._buildBorders()],
            cameraConfig: CameraConfig(
              speed: 4.0, // más bajo = cámara más suave; infinito = instantáneo
              zoom: 2.6, // algo menos de zoom para mejor visibilidad
              moveOnlyMapArea: true,
            ),
            playerControllers: [
              Joystick(
                directional: JoystickDirectional(
                  size: 96,
                  color: Colors.white.withOpacity(0.32),
                  margin: const EdgeInsets.only(left: 24, bottom: 28),
                  isFixed: true,
                ),
                actions: [
                  JoystickAction(
                    actionId: AnimalGoPlayer.kActionInteract,
                    size: 56,
                    color: const Color(0xFF56E39F).withOpacity(0.6),
                    margin: const EdgeInsets.only(right: 26, bottom: 28),
                  ),
                ],
              ),
              Keyboard(
                config: KeyboardConfig(
                  enableDiagonalInput: true,
                  directionalKeys: [
                    KeyboardDirectionalKeys.wasd(),
                    KeyboardDirectionalKeys.arrows(),
                  ],
                ),
              ),
            ],
            overlayBuilderMap: {
              HudOverlay.id: (ctx, game) => HudOverlay(
                    onCollection: () =>
                        Navigator.of(ctx).pushNamed('/collection'),
                    onMenu: () {
                      final p = game.player;
                      if (p != null) {
                        gs.savedX = p.position.x / _tile;
                        gs.savedY = p.position.y / _tile;
                        gs.savedMapId = gs.currentMapId;
                      }
                      Navigator.of(ctx).pushReplacementNamed('/menu');
                    },
                  ),
              EncounterOverlay.id: (ctx, game) {
                if (currentAnimal == null) return const SizedBox.shrink();
                return EncounterOverlay(
                  animal: currentAnimal!,
                  onClose: () => game.overlays.remove(EncounterOverlay.id),
                );
              },
            },
            initialActiveOverlays: const [HudOverlay.id],
            backgroundColor: _mapBg,
            lightingColorGame: const Color(0x22000000),
          ),
        ),

        // ── Tinte ambiental (capa sobre el juego, bajo el HUD) ────────────
        IgnorePointer(
          child: Container(color: _mapTint),
        ),

        // ── Viñeta suave para dar profundidad al mapa ────────────────────
        IgnorePointer(
          child: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                radius: 1.1,
                colors: [Colors.transparent, Color(0x66000000)],
                stops: [0.65, 1.0],
              ),
            ),
          ),
        ),

        // ── Partículas ambientales (motas de polen / luciérnagas) ─────────
        IgnorePointer(
          child: AnimatedBuilder(
            animation: _ambientCtrl,
            builder: (_, __) => CustomPaint(
              painter: _AmbientMotesPainter(
                _ambientCtrl.value,
                GameState().currentMapId,
              ),
              size: Size.infinite,
            ),
          ),
        ),

        // ── Fade in al entrar al mapa ─────────────────────────────────────
        IgnorePointer(
          child: AnimatedBuilder(
            animation: _fadeIn,
            builder: (_, __) => Container(
              color: Colors.black.withOpacity(1 - _fadeIn.value),
            ),
          ),
        ),

        // ── Intro de mapa (primera vez) ──────────────────────────────────
        if (_showMapIntro)
          MapIntroOverlay(
            mapId: gs.currentMapId,
            onClose: () {
              gs.mapsIntroSeen.add(gs.currentMapId);
              setState(() => _showMapIntro = false);
            },
          ),
      ]),
    );
  }

  // Clave del mapa usada por MapWalkable (kanto1/3/9/11) — varios id de
  // MapCatalog comparten la misma ruta subyacente.
  String get _walkKey {
    final f = _spec.file; // 'assets/maps/kantoN.json'
    return f.split('/').last.replaceFirst('.json', '');
  }

  List<AnimalNpc> _buildAnimals() {
    // 6 animales aleatorios por sesión, spawneados SOLO sobre tiles
    // caminables (Ground/Paths/Grass), nunca sobre montañas/árboles.
    final rng = math.Random(DateTime.now().millisecondsSinceEpoch);
    final walk = MapWalkable.byMap[_walkKey] ?? const <(int, int)>[];
    if (walk.isEmpty) return const [];
    final gs = GameState();
    // Excluir animales ya descubiertos para que no reaparezcan en el mapa.
    final pool = AnimalCatalog.basicPack
        .where((a) => !gs.discoveredAnimals.contains(a.id))
        .toList()
      ..shuffle(rng);
    if (pool.isEmpty) return const [];
    final animals = pool.take(6).toList();
    final used = <(int, int)>{};
    final list = <AnimalNpc>[];
    for (final a in animals) {
      (int, int) p;
      int tries = 0;
      do {
        p = walk[rng.nextInt(walk.length)];
        tries++;
      } while (used.contains(p) && tries < 30);
      used.add(p);
      list.add(AnimalNpc(
        position: Vector2(p.$1 * _tile, p.$2 * _tile),
        animalData: a,
        onEncounter: (ani) => currentAnimal = ani,
      ));
    }
    return list;
  }

  List<CollectibleItem> _buildItems() {
    final gs = GameState();
    // 10 ítems por mapa, SOLO en tiles caminables. Semilla estable por mapa
    // para que los ítems recogidos no reaparezcan (collectedMapItems compara por id).
    final rng = math.Random(gs.currentMapId.hashCode);
    final walk = MapWalkable.byMap[_walkKey] ?? const <(int, int)>[];
    if (walk.isEmpty) return const [];
    // Ítems sueltos (no cofres): dan recursos pequeños.
    const lootTypes = [
      ItemType.mushroom, ItemType.gem, ItemType.star,
      ItemType.leaf, ItemType.berry,
    ];
    final items = <CollectibleItem>[];
    final used = <(int, int)>{};
    for (int i = 0; i < 10; i++) {
      (int, int) p;
      int tries = 0;
      do {
        p = walk[rng.nextInt(walk.length)];
        tries++;
      } while (used.contains(p) && tries < 30);
      used.add(p);
      final id = '${gs.currentMapId}_item_$i';
      if (gs.isMapItemCollected(id)) continue;
      items.add(CollectibleItem(
        position: Vector2(p.$1 * _tile, p.$2 * _tile),
        itemType: lootTypes[rng.nextInt(lootTypes.length)],
        itemId: id,
      ));
    }
    // Cofres: 3 normales + 1 grande por mapa. Siempre en tiles BORDE de la
    // zona caminable (un tile caminable con al menos 1 vecino no caminable).
    final walkSet = walk.toSet();
    final edgeTiles = walk.where((t) {
      final (x, y) = t;
      return !walkSet.contains((x + 1, y)) ||
             !walkSet.contains((x - 1, y)) ||
             !walkSet.contains((x, y + 1)) ||
             !walkSet.contains((x, y - 1));
    }).toList()..shuffle(rng);
    final chestPool = edgeTiles.isNotEmpty ? edgeTiles : walk;
    for (int i = 0; i < 4; i++) {
      (int, int) p;
      int tries = 0;
      do {
        p = chestPool[rng.nextInt(chestPool.length)];
        tries++;
      } while (used.contains(p) && tries < 40);
      used.add(p);
      final chestId = '${gs.currentMapId}_chest_$i';
      if (gs.isChestOpened(chestId)) continue;
      items.add(CollectibleItem(
        position: Vector2(p.$1 * _tile, p.$2 * _tile),
        itemType: i == 0 ? ItemType.treasureChest : ItemType.chest,
        itemId: chestId,
      ));
    }
    return items;
  }

  /// Muros invisibles en los 4 bordes del mapa para que el jugador no
  /// se salga por arriba/abajo/izq/der.
  List<GameComponent> _buildBorders() {
    final s = _spec;
    final w = s.w * _tile;
    final h = s.h * _tile;
    const thick = 32.0;
    return [
      _MapBorder(position: Vector2(-thick, -thick), size: Vector2(w + thick * 2, thick)),            // top
      _MapBorder(position: Vector2(-thick, h),       size: Vector2(w + thick * 2, thick)),            // bottom
      _MapBorder(position: Vector2(-thick, 0),       size: Vector2(thick, h)),                        // left
      _MapBorder(position: Vector2(w, 0),            size: Vector2(thick, h)),                        // right
    ];
  }
}

/// Muro invisible sólido usado para encerrar al jugador dentro del mapa.
class _MapBorder extends GameDecoration {
  _MapBorder({required Vector2 position, required Vector2 size})
      : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox(
      size: size,
      collisionType: CollisionType.passive,
      isSolid: true,
    ));
  }

  @override
  void render(Canvas canvas) {
    // invisible
  }
}

// ─── Ambient motes overlay ───────────────────────────────────────────────────
class _AmbientMotesPainter extends CustomPainter {
  final double t;
  final String biome;
  _AmbientMotesPainter(this.t, this.biome);

  static final _motes = List.generate(
      30,
      (i) => {
            'x': (i * 137.5) % 1.0,
            'y': (i * 73.1) % 1.0,
            'spd': 0.08 + (i % 7) * 0.015,
            'ph': (i * 0.5) % 1.0,
            'sz': 1.3 + (i % 3) * 0.8,
            'drift': (i % 5) * 0.015,
          });

  @override
  void paint(Canvas c, Size s) {
    final color = switch (biome) {
      'savanna' => const Color(0xFFFFE5A0),
      'jungle' => const Color(0xFFB4F0D0),
      _ => const Color(0xFFCFFFE3),
    };
    for (final m in _motes) {
      final ph = (m['ph']! + t * m['spd']!) % 1.0;
      final alpha = math.sin(ph * math.pi * 2) * 0.35 + 0.45;
      final x = (m['x']! + math.sin(ph * math.pi * 2) * m['drift']!) * s.width;
      final y = ((m['y']! + ph * 0.15) % 1.0) * s.height;
      c.drawCircle(
        Offset(x, y),
        m['sz']!,
        Paint()
          ..color = color.withOpacity(alpha * 0.55)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
      );
    }
  }

  @override
  bool shouldRepaint(_AmbientMotesPainter old) => old.t != t;
}
