// lib/screens/loading_screen.dart
//
// Pantalla de carga al estilo del resto del juego:
//   · Fondo pixel-art forest (mismo asset que las otras pantallas)
//   · Logo "AnimalGO!" idéntico al del menú principal (degradado dorado,
//     borde negro grueso, hojita)
//   · Marco PixelFrame con barra de progreso pixel-art (oro sobre madera)
//   · Tip rotativo dentro de un WoodChip
//   · Luciérnagas doradas para mantener vida
//
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../router/app_router.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});
  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoCtrl,
      _progressCtrl,
      _particleCtrl,
      _bobCtrl;
  late final Animation<double> _logoScale, _logoFade, _progress, _bob;
  int _tipIndex = 0;

  static const _tips = [
    ' Los zorros pueden escuchar un ratón bajo la nieve',
    ' Los búhos pueden girar la cabeza 270 grados',
    ' Las mariposas prueban la comida con los pies',
    ' Las ranas respiran por la piel',
    ' El olfato del oso es 7 veces más potente que el de un perro',
    ' Las astas del ciervo crecen 3 cm por día',
  ];

  @override
  void initState() {
    super.initState();
    _logoCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000))
      ..forward();
    _particleCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..repeat();
    _progressCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3000));
    _bobCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);

    _logoScale = Tween<double>(begin: 0.2, end: 1.0)
        .animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _logoCtrl, curve: const Interval(0, 0.3)));
    _progress = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _progressCtrl, curve: Curves.easeInOut));
    _bob = Tween<double>(begin: 0.0, end: -10.0)
        .animate(CurvedAnimation(parent: _bobCtrl, curve: Curves.easeInOut));

    _progressCtrl.addListener(() {
      final idx = (_progressCtrl.value * (_tips.length - 1)).round();
      if (idx != _tipIndex && mounted) setState(() => _tipIndex = idx);
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _progressCtrl.forward().then((_) {
          Future.delayed(const Duration(milliseconds: 200), () {
            if (mounted) {
              _finishLoadingAndRoute();
            }
          });
        });
      }
    });
  }

  Future<void> _finishLoadingAndRoute() async {
    final session = await AuthService.restoreSession();
    if (session != null) {
      AuthService.applySessionToGameState(session);
      await AuthService.refreshSessionFromServer(session);
    }
    if (!mounted) return;
    final route = session == null ? AppRouter.login : AppRouter.mainMenu;
    Navigator.of(context).pushReplacementNamed(route);
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _progressCtrl.dispose();
    _particleCtrl.dispose();
    _bobCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1A10),
      body: MenuBackdrop(
        dim: 0.45,
        child: Stack(children: [
          // Luciérnagas doradas
          AnimatedBuilder(
            animation: _particleCtrl,
            builder: (_, __) => CustomPaint(
              painter: _GoldFireflyPainter(_particleCtrl.value),
              size: Size.infinite,
            ),
          ),
          // Logo + tagline
          Center(
            child: FadeTransition(
              opacity: _logoFade,
              child: ScaleTransition(
                scale: _logoScale,
                child: AnimatedBuilder(
                  animation: _bob,
                  builder: (_, child) => Transform.translate(
                    offset: Offset(0, _bob.value),
                    child: child,
                  ),
                  child: const _LogoBlock(),
                ),
              ),
            ),
          ),
          // Bottom: progress + tip
          Positioned(
            left: 40,
            right: 40,
            bottom: 30,
            child: AnimatedBuilder(
              animation: _progress,
              builder: (_, __) => Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Tip
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: WoodChip(
                      key: ValueKey(_tipIndex),
                      label: _tips[_tipIndex],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Progress bar (pixel art) - borde madera + interior dorado
                  Container(
                    height: 24,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF4A2D14), Color(0xFF2A1A0C)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: GameTone.goldTrim, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 8,
                            offset: const Offset(0, 3)),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Stack(children: [
                        // Inner well (darker wood)
                        Container(color: const Color(0xFF1A0E04)),
                        // Filled gold gradient
                        FractionallySizedBox(
                          widthFactor: _progress.value,
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(colors: [
                                Color(0xFFFFE48A),
                                Color(0xFFE8B452),
                                Color(0xFFB07A2A),
                              ]),
                            ),
                          ),
                        ),
                        // Top highlight stroke
                        Positioned(
                          left: 0,
                          right: 0,
                          top: 1,
                          height: 2,
                          child: FractionallySizedBox(
                            widthFactor: _progress.value,
                            child: Container(
                                color: Colors.white.withOpacity(0.35)),
                          ),
                        ),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cargando...  ${(_progress.value * 100).toInt()}%',
                    style: const TextStyle(
                      color: GameTone.textGold,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 1.2,
                      shadows: [
                        Shadow(
                            color: Color(0xFF1A0E04),
                            offset: Offset(0, 2),
                            blurRadius: 0),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

/// Bloque de logo idéntico al del menú principal - usa el GameLogo con el
/// nombre AnimalGO! para mantener consistencia.
class _LogoBlock extends StatelessWidget {
  const _LogoBlock();
  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: const [
      GameLogo(
        title: 'AnimalGO!',
        subtitle: '  Descubre el mundo animal  ',
        fontSize: 64,
      ),
    ]);
  }
}

/// Luciérnagas en tonos amarillos/dorados.
class _GoldFireflyPainter extends CustomPainter {
  final double p;
  static final _ff = List.generate(
      20,
      (i) => {
            'x': (i * 137.5) % 1.0,
            'y': (i * 97.3) % 1.0,
            'spd': 0.25 + (i % 5) * 0.07,
            'ph': (i * 0.7) % 1.0,
            'sz': 1.6 + (i % 3) * 0.8,
          });
  const _GoldFireflyPainter(this.p);

  @override
  void paint(Canvas c, Size s) {
    for (final f in _ff) {
      final ph = (f['ph']! + p * f['spd']!) % 1.0;
      final a = math.sin(ph * math.pi * 2) * 0.5 + 0.5;
      final dx = f['x']! * s.width;
      final dy = (f['y']! + math.sin(ph * math.pi) * 0.04) * s.height;
      // soft halo
      c.drawCircle(
        Offset(dx, dy),
        f['sz']! * 2.6,
        Paint()
          ..color = const Color(0xFFFFE48A).withOpacity(a * 0.18)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
      // bright core
      c.drawCircle(
        Offset(dx, dy),
        f['sz']!,
        Paint()
          ..color = const Color(0xFFFFE48A).withOpacity(a * 0.85)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
      );
    }
  }

  @override
  bool shouldRepaint(_GoldFireflyPainter o) => o.p != p;
}
