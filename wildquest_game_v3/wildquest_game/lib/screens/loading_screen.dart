// lib/screens/loading_screen.dart
import 'package:flutter/material.dart';
import '../router/app_router.dart';
import '../theme/app_theme.dart';
import 'dart:math' as math;

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});
  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoCtrl, _progressCtrl, _particleCtrl, _bobCtrl;
  late Animation<double> _logoScale, _logoFade, _progress, _bob;
  int _tipIndex = 0;

  static const _tips = [
    '🦊 Los zorros pueden escuchar un ratón bajo la nieve',
    '🦉 Los búhos pueden girar la cabeza 270 grados',
    '🦋 Las mariposas prueban la comida con los pies',
    '🐸 Las ranas respiran por la piel',
    '🐻 El olfato del oso es 7 veces más potente que el de un perro',
    '🦌 Las astas del ciervo crecen 3 cm por día',
  ];

  @override
  void initState() {
    super.initState();
    _logoCtrl    = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..forward();
    _particleCtrl= AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
    _progressCtrl= AnimationController(vsync: this, duration: const Duration(milliseconds: 3000));
    _bobCtrl     = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat(reverse: true);

    _logoScale = Tween<double>(begin: 0.2, end: 1.0).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));
    _logoFade  = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _logoCtrl, curve: const Interval(0, 0.3)));
    _progress  = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _progressCtrl, curve: Curves.easeInOut));
    _bob       = Tween<double>(begin: 0.0, end: -8.0).animate(CurvedAnimation(parent: _bobCtrl, curve: Curves.easeInOut));

    _progressCtrl.addListener(() {
      final idx = (_progressCtrl.value * (_tips.length - 1)).round();
      if (idx != _tipIndex && mounted) setState(() => _tipIndex = idx);
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _progressCtrl.forward().then((_) {
          Future.delayed(const Duration(milliseconds: 200), () {
            if (mounted) Navigator.of(context).pushReplacementNamed(AppRouter.mainMenu);
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _logoCtrl.dispose(); _progressCtrl.dispose();
    _particleCtrl.dispose(); _bobCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Container(decoration: const BoxDecoration(gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [AppColors.greenDark, AppColors.greenMid, AppColors.greenDark],
        ))),
        AnimatedBuilder(animation: _particleCtrl, builder: (_, __) =>
            CustomPaint(painter: _FireflyPainter(_particleCtrl.value), size: Size.infinite)),
        _vignette(),
        Center(child: FadeTransition(opacity: _logoFade, child: ScaleTransition(scale: _logoScale,
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            AnimatedBuilder(animation: _bob, builder: (_, __) => Transform.translate(
              offset: Offset(0, _bob.value),
              child: Container(width: 110, height: 110,
                decoration: BoxDecoration(shape: BoxShape.circle,
                  gradient: const LinearGradient(colors: [AppColors.greenAccent, AppColors.greenDeep]),
                  boxShadow: [BoxShadow(color: AppColors.greenAccent.withOpacity(0.5), blurRadius: 35, spreadRadius: 6)],
                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 3)),
                child: const Center(child: Text('🌿', style: TextStyle(fontSize: 55)))),
            )),
            const SizedBox(width: 40),
            Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              ShaderMask(shaderCallback: (b) => const LinearGradient(colors: [AppColors.gold, AppColors.goldDark]).createShader(b),
                child: const Text('WILDQUEST', style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 4))),
              Text('Descubre el mundo animal', style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.6), fontStyle: FontStyle.italic, letterSpacing: 1.5)),
            ]),
          ]),
        ))),
        Positioned(bottom: 20, left: 60, right: 60, child: AnimatedBuilder(animation: _progress, builder: (_, __) =>
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            AnimatedSwitcher(duration: const Duration(milliseconds: 400),
              child: Text(_tips[_tipIndex], key: ValueKey(_tipIndex),
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11))),
            const SizedBox(height: 8),
            ClipRRect(borderRadius: BorderRadius.circular(10), child: Stack(children: [
              Container(height: 10, color: Colors.black.withOpacity(0.4)),
              FractionallySizedBox(widthFactor: _progress.value, child: Container(height: 10,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(colors: [AppColors.greenAccent, AppColors.gold]),
                  boxShadow: [BoxShadow(color: AppColors.greenAccent.withOpacity(0.6), blurRadius: 8)]))),
            ])),
            const SizedBox(height: 4),
            Text('${(_progress.value * 100).toInt()}%', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10)),
          ]),
        )),
      ]),
    );
  }

  Widget _vignette() => Stack(children: [
    _vig(Alignment.centerLeft, Alignment.centerRight, left: 0, width: 70, isH: true),
    _vig(Alignment.centerRight, Alignment.centerLeft, right: 0, width: 70, isH: true),
    _vig(Alignment.topCenter, Alignment.bottomCenter, top: 0, height: 45, isH: false),
    _vig(Alignment.bottomCenter, Alignment.topCenter, bottom: 0, height: 45, isH: false),
  ]);

  Widget _vig(AlignmentGeometry b, AlignmentGeometry e, {double? left, double? right, double? top, double? bottom, double? width, double? height, required bool isH}) =>
    Positioned(left: left, right: right, top: top, bottom: bottom, width: width, height: height,
      child: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: b, end: e,
        colors: [const Color(0xFF0A2214), Colors.transparent]))));
}

class _FireflyPainter extends CustomPainter {
  final double p;
  static final _ff = List.generate(18, (i) => {'x': (i * 137.5) % 1.0, 'y': (i * 97.3) % 1.0, 'spd': 0.3 + (i % 5) * 0.08, 'ph': (i * 0.7) % 1.0, 'sz': 2.0 + (i % 3).toDouble()});
  const _FireflyPainter(this.p);
  @override
  void paint(Canvas c, Size s) {
    for (final f in _ff) {
      final ph = (f['ph']! + p * f['spd']!) % 1.0;
      final a  = math.sin(ph * math.pi * 2) * 0.5 + 0.5;
      c.drawCircle(Offset(f['x']! * s.width, (f['y']! + math.sin(ph * math.pi) * 0.04) * s.height), f['sz']!,
        Paint()..color = const Color(0xFF56E39F).withOpacity(a * 0.7)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
    }
  }
  @override bool shouldRepaint(_FireflyPainter o) => o.p != p;
}
