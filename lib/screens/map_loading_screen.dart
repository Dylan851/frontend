// lib/screens/map_loading_screen.dart
// Pantalla de carga temática al entrar al mapa: muestra el bioma seleccionado,
// precarga los JSON/tilesets y transiciona a GameScreen con fade.

import 'dart:math' as math;
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../data/item_data.dart';
import '../data/game_state.dart';
import '../theme/app_theme.dart';
import 'game_screen.dart';

class MapLoadingScreen extends StatefulWidget {
  const MapLoadingScreen({super.key});
  @override
  State<MapLoadingScreen> createState() => _MapLoadingScreenState();
}

class _MapLoadingScreenState extends State<MapLoadingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _progressCtrl;
  late final AnimationController _bobCtrl;
  late final AnimationController _fadeOutCtrl;
  late final AnimationController _particleCtrl;
  late final Animation<double> _progress;
  late final Animation<double> _bob;
  late final Animation<double> _fadeOut;

  int _tipIndex = 0;
  bool _assetsReady = false;

  static const _tips = [
    '🌿 Usa las flechas o WASD para moverte',
    '🎯 El botón verde interactúa con animales y objetos',
    '🐾 Encuentra los 6 animales del bioma',
    '📖 Revisa tu colección desde el HUD',
    '⭐ Completa minijuegos para ganar estrellas',
    '🪙 Las monedas te permiten comprar mejoras',
  ];

  MapWorld get _map {
    try {
      return MapCatalog.all
          .firstWhere((m) => m.id == GameState().currentMapId);
    } catch (_) {
      return MapCatalog.all.first;
    }
  }

  @override
  void initState() {
    super.initState();
    _progressCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800));
    _bobCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    _fadeOutCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
    _particleCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 4))
      ..repeat();

    _progress = CurvedAnimation(parent: _progressCtrl, curve: Curves.easeInOut);
    _bob = Tween<double>(begin: 0, end: -10)
        .animate(CurvedAnimation(parent: _bobCtrl, curve: Curves.easeInOut));
    _fadeOut = CurvedAnimation(parent: _fadeOutCtrl, curve: Curves.easeOut);

    _progressCtrl.addListener(() {
      final idx = (_progressCtrl.value * (_tips.length - 1)).round();
      if (idx != _tipIndex && mounted) setState(() => _tipIndex = idx);
    });

    _progressCtrl.forward();
    _preloadAndGo();
  }

  Future<void> _preloadAndGo() async {
    try {
      final id = GameState().currentMapId;
      final mapFile = switch (id) {
        'savanna' || 'desert'  => 'assets/maps/kanto3.json',
        'farm'    || 'volcano' => 'assets/maps/kanto9.json',
        'ocean'   || 'sky'     => 'assets/maps/kanto11.json',
        'jungle'  || 'arctic'  => 'assets/maps/kanto1.json',
        _                      => 'assets/maps/kanto1.json',
      };
      // Precarga el JSON del mapa para que GameScreen no espere a leerlo.
      await rootBundle.loadString(mapFile);
      // Precarga las texturas más pesadas del tileset.
      try {
        await Flame.images.loadAll([
          'tiles/tileset_terrain.png',
          'tiles/tileset_objects.png',
          'tiles/fields_tileset.png',
        ]);
      } on Exception {
        // Si alguna textura no existe, seguimos: Bonfire la cargará bajo demanda.
      }
      _assetsReady = true;
    } catch (_) {
      _assetsReady = true;
    }
    // Asegura una duración mínima agradable (la barra tarda ~1.8s).
    try {
      await _progressCtrl.forward().orCancel;
    } catch (_) {
      // animación cancelada (el widget se desmontó)
      return;
    }
    if (!mounted) return;
    try {
      await _fadeOutCtrl.forward().orCancel;
    } catch (_) {
      return;
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const GameScreen(),
        transitionsBuilder: (_, a, __, child) =>
            FadeTransition(opacity: a, child: child),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    _bobCtrl.dispose();
    _fadeOutCtrl.dispose();
    _particleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final map = _map;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _fadeOut,
        builder: (_, child) => Opacity(
          opacity: 1 - _fadeOut.value,
          child: child,
        ),
        child: Stack(children: [
          // Fondo degradado del bioma
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: _biomeGradient(map.id),
              ),
            ),
          ),
          // Partículas (luciérnagas / hojas)
          AnimatedBuilder(
            animation: _particleCtrl,
            builder: (_, __) => CustomPaint(
              painter: _AmbientPainter(_particleCtrl.value, map.id),
              size: Size.infinite,
            ),
          ),
          _vignette(),

          // Tarjeta central con el bioma
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _bob,
                  builder: (_, __) => Transform.translate(
                    offset: Offset(0, _bob.value),
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withOpacity(0.15),
                            Colors.transparent,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.greenAccent.withOpacity(0.35),
                            blurRadius: 60,
                            spreadRadius: 10,
                          ),
                        ],
                        border: Border.all(
                            color: Colors.white.withOpacity(0.25), width: 3),
                      ),
                      child: Center(
                        child: Text(map.emoji,
                            style: const TextStyle(fontSize: 80)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Entrando a',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.65),
                    fontSize: 13,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 6),
                ShaderMask(
                  shaderCallback: (b) => const LinearGradient(
                          colors: [AppColors.gold, AppColors.goldDark])
                      .createShader(b),
                  child: Text(
                    map.name.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 3,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.greenAccent.withOpacity(0.3)),
                  ),
                  child: Text(
                    map.description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Barra de progreso abajo
          Positioned(
            bottom: 40,
            left: 60,
            right: 60,
            child: AnimatedBuilder(
              animation: _progress,
              builder: (_, __) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    child: Text(
                      _tips[_tipIndex],
                      key: ValueKey(_tipIndex),
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 12,
                          fontStyle: FontStyle.italic),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(children: [
                      Container(
                          height: 10, color: Colors.black.withOpacity(0.45)),
                      FractionallySizedBox(
                        widthFactor: _progress.value,
                        child: Container(
                          height: 10,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.greenAccent,
                                AppColors.gold,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                  color: AppColors.greenAccent
                                      .withOpacity(0.55),
                                  blurRadius: 10),
                            ],
                          ),
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _assetsReady
                            ? 'Preparando aventura…'
                            : 'Cargando tiles y texturas…',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.55),
                            fontSize: 10),
                      ),
                      Text(
                        '${(_progress.value * 100).toInt()}%',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.55),
                            fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Volver atrás (por si el usuario se arrepiente antes de entrar)
          Positioned(
            top: 12,
            left: 12,
            child: SafeArea(
              child: GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.45),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.2), width: 1),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 16),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  List<Color> _biomeGradient(String id) {
    switch (id) {
      case 'savanna':
        return const [
          Color(0xFF6B4F1D),
          Color(0xFF8A6A2A),
          Color(0xFF4E3A13),
        ];
      case 'jungle':
        return const [
          Color(0xFF0A2E1A),
          Color(0xFF1E6B3A),
          Color(0xFF06200F),
        ];
      default:
        return const [
          AppColors.greenDark,
          AppColors.greenMid,
          AppColors.greenDark,
        ];
    }
  }

  Widget _vignette() => IgnorePointer(
        child: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              radius: 1.1,
              colors: [Colors.transparent, Color(0xAA000000)],
              stops: [0.55, 1.0],
            ),
          ),
        ),
      );
}

class _AmbientPainter extends CustomPainter {
  final double t;
  final String biome;
  _AmbientPainter(this.t, this.biome);

  static final _particles = List.generate(24, (i) {
    return {
      'x': (i * 137.5) % 1.0,
      'y': (i * 97.3) % 1.0,
      'spd': 0.25 + (i % 5) * 0.07,
      'ph': (i * 0.7) % 1.0,
      'sz': 2.0 + (i % 3).toDouble(),
    };
  });

  @override
  void paint(Canvas c, Size s) {
    final color = switch (biome) {
      'savanna' => const Color(0xFFFFD27A),
      'jungle' => const Color(0xFF8CF0B8),
      _ => const Color(0xFF56E39F),
    };
    for (final f in _particles) {
      final ph = (f['ph']! + t * f['spd']!) % 1.0;
      final a = math.sin(ph * math.pi * 2) * 0.5 + 0.5;
      c.drawCircle(
        Offset(
          f['x']! * s.width,
          (f['y']! + math.sin(ph * math.pi) * 0.05) * s.height,
        ),
        f['sz']!,
        Paint()
          ..color = color.withOpacity(a * 0.7)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
    }
  }

  @override
  bool shouldRepaint(_AmbientPainter old) => old.t != t;
}

