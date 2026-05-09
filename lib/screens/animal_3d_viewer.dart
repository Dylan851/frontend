// lib/screens/animal_3d_viewer.dart
//
// Visor 3D a pantalla completa para los modelos de animales.
// Controles: arrastrar (rotar 360º), pellizcar (zoom), doble toque (reset).
//
// Los modelos GLB viven en assets/models/{animalId}.glb

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import '../data/animal_data.dart';
import '../services/model_cache_service.dart';
import '../theme/app_theme.dart';

/// IDs de animales que tienen modelo 3D disponible.
const Set<String> kAnimalsWith3DModel = {
  'fox', 'deer', 'owl', 'butterfly', 'bear', 'frog',
  'chicken', 'crab', 'toad', 'pig', 'goose', 'green_frog',
  'boar', 'cat', 'sheep', 'turtle', 'snow_fox', 'porcupine', 'wolf',
};

bool animalHas3DModel(String id) => kAnimalsWith3DModel.contains(id);

class Animal3DViewer extends StatefulWidget {
  final AnimalData animal;
  const Animal3DViewer({super.key, required this.animal});

  @override
  State<Animal3DViewer> createState() => _Animal3DViewerState();
}

class _Animal3DViewerState extends State<Animal3DViewer>
    with TickerProviderStateMixin {
  final Flutter3DController _controller = Flutter3DController();
  late final AnimationController _hintCtrl;
  late final Animation<double> _hintAnim;
  bool _loading = true;
  double _prefetchProgress = 0.0;
  // Progreso simulado mientras el visor parsea el modelo (post-prefetch).
  double _viewerProgress = 0.0;
  Timer? _viewerTicker;
  Timer? _safetyTimer;
  String? _resolvedSrc;
  String? _loadError;
  List<String> _animations = const [];
  String? _currentAnim;

  @override
  void initState() {
    super.initState();
    _hintCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _hintAnim = CurvedAnimation(parent: _hintCtrl, curve: Curves.easeInOut);
    // Visor 3D deshabilitado: no precargamos modelos.
  }

  Future<void> _startPrefetch() async {
    final assetPath = 'assets/models/${widget.animal.id}.glb';
    try {
      final localPath = await ModelCacheService.prefetch(
        assetPath,
        onProgress: (p) {
          if (!mounted) return;
          setState(() => _prefetchProgress = p);
        },
      );
      if (!mounted) return;
      setState(() => _resolvedSrc = localPath);
      _startViewerProgress();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.toString();
        _resolvedSrc = assetPath; // fallback al asset directo
      });
      _startViewerProgress();
    }
  }

  /// Animación + safety net mientras el visor parsea el modelo. Sin esto la
  /// barra se queda atascada al 85 % si el visor no emite `onLoad`.
  void _startViewerProgress() {
    _viewerTicker?.cancel();
    _viewerProgress = 0.0;
    _viewerTicker = Timer.periodic(const Duration(milliseconds: 120), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _viewerProgress = _viewerProgress + (0.99 - _viewerProgress) * 0.05;
      });
      if (_viewerProgress > 0.985) t.cancel();
    });
    _safetyTimer?.cancel();
    _safetyTimer = Timer(const Duration(seconds: 8), () {
      if (!mounted || !_loading) return;
      setState(() => _loading = false);
    });
  }

  @override
  void dispose() {
    _hintCtrl.dispose();
    _viewerTicker?.cancel();
    _safetyTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadAnimations() async {
    try {
      final list = await _controller.getAvailableAnimations();
      if (!mounted) return;
      setState(() {
        _animations = list;
        if (list.isNotEmpty) {
          _currentAnim = list.first;
          _controller.playAnimation(animationName: list.first);
        }
      });
    } catch (_) {}
  }

  void _resetCamera() {
    _controller.resetCameraOrbit();
    _controller.resetCameraTarget();
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.animal;
    // Placeholder "Próximamente" — el visor 3D real está deshabilitado
    // porque los modelos GLB son demasiado pesados para móvil sin optimizar.
    return Scaffold(
      backgroundColor: const Color(0xFF050E08),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            radius: 1.0,
            colors: [Color(0xFF1A3A22), Color(0xFF071A0F), Color(0xFF030906)],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(a.emoji, style: const TextStyle(fontSize: 96)),
                const SizedBox(height: 16),
                Text(a.name.toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 24,
                        letterSpacing: 2)),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1C94D).withOpacity(0.18),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFF1C94D), width: 1.4),
                  ),
                  child: const Text('VISOR 3D · PRÓXIMAMENTE',
                      style: TextStyle(
                          color: Color(0xFFF1C94D),
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          letterSpacing: 1.6)),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Estamos optimizando los modelos 3D para que funcionen en móviles.\nVuelve pronto.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _unusedOriginalBuild(BuildContext context) {
    final a = widget.animal;
    final double overallProgress = _resolvedSrc == null
        ? (_prefetchProgress * 0.70).clamp(0.0, 0.70)
        : (_loading
            ? (0.70 + _viewerProgress * 0.29).clamp(0.70, 0.99)
            : 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFF050E08),
      body: Stack(children: [
        // ── Fondo degradado verde-bosque ──────────────────────────────
        Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              radius: 1.0,
              colors: [Color(0xFF1A3A22), Color(0xFF071A0F), Color(0xFF030906)],
            ),
          ),
        ),

        // ── Visor 3D ──────────────────────────────────────────────────
        if (_resolvedSrc != null)
          Positioned.fill(
            child: Flutter3DViewer(
              controller: _controller,
              src: _resolvedSrc!,
              progressBarColor: GameTone.goldTrim,
              enableTouch: true,
              activeGestureInterceptor: true,
              onLoad: (_) {
                if (mounted) setState(() => _loading = false);
                _loadAnimations();
              },
              onError: (e) {
                if (mounted) {
                  setState(() {
                    _loading = false;
                    _loadError = e.toString();
                  });
                }
              },
            ),
          ),

        // ── Overlay de carga con barra real de progreso ──────────────
        if (_loading)
          Positioned.fill(
            child: Container(
              color: const Color(0xCC050E08),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.view_in_ar_rounded,
                            color: GameTone.goldTrim, size: 48),
                        const SizedBox(height: 14),
                        Text(
                          (_loadError != null)
                              ? 'No se pudo cargar el modelo'
                              : 'Cargando modelo 3D…',
                          style: const TextStyle(
                            color: GameTone.textCream,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 14),
                        // Barra de progreso real (0 → 1).
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            height: 12,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0A0500),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: GameTone.goldTrim.withOpacity(0.6),
                                  width: 1),
                            ),
                            child: Stack(children: [
                              FractionallySizedBox(
                                widthFactor: overallProgress
                                    .clamp(0.0, 1.0)
                                    .toDouble(),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Color(0xFFFFE48A),
                                        Color(0xFFE8B452),
                                        Color(0xFFB07A2A),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ]),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${(overallProgress * 100).toStringAsFixed(0)} %',
                          style: TextStyle(
                            color: GameTone.textGold.withOpacity(0.9),
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

        // ── Cabecera con back + título ────────────────────────────────
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              _woodBack(),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      colors: [Color(0xFF6B4423), Color(0xFF3A2210)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: GameTone.goldTrim, width: 1.5),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 6, offset: const Offset(0, 3)),
                    ],
                  ),
                  child: Row(children: [
                    Text(a.emoji, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 10),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(a.name.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: GameTone.textCream,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              letterSpacing: 1.2,
                              height: 1.0,
                              shadows: [Shadow(color: Color(0xFF1A0E04), offset: Offset(0, 2), blurRadius: 0)],
                            )),
                        const SizedBox(height: 2),
                        Text('Modelo 3D · ${a.habitat}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: GameTone.textGold.withOpacity(0.9),
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                              letterSpacing: 0.5,
                            )),
                      ],
                    )),
                  ]),
                ),
              ),
              const SizedBox(width: 8),
              _circleBtn(Icons.refresh_rounded, _resetCamera, tooltip: 'Centrar'),
            ]),
          ),
        ),

        // ── Hint de gesto en el centro inferior ───────────────────────
        if (!_loading)
          Positioned(
            left: 0, right: 0, bottom: _animations.isEmpty ? 24 : 88,
            child: Center(
              child: FadeTransition(
                opacity: _hintAnim,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xCC1A0E04),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: GameTone.goldTrim.withOpacity(0.5), width: 1),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: const [
                    Icon(Icons.touch_app_rounded, color: GameTone.textGold, size: 16),
                    SizedBox(width: 8),
                    Text('Arrastra para rotar  ·  Pellizca para zoom',
                        style: TextStyle(
                          color: GameTone.textCream,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        )),
                  ]),
                ),
              ),
            ),
          ),

        // ── Selector de animaciones (si las hay) ──────────────────────
        if (!_loading && _animations.length > 1)
          Positioned(
            left: 0, right: 0, bottom: 18,
            child: Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  for (final anim in _animations) ...[
                    _animChip(anim, anim == _currentAnim),
                    const SizedBox(width: 8),
                  ],
                ]),
              ),
            ),
          ),
      ]),
    );
  }

  Widget _woodBack() => GestureDetector(
    onTap: () => Navigator.of(context).pop(),
    child: Container(
      width: 46, height: 42,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color(0xFF6B4423), Color(0xFF3A2210)],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: GameTone.goldTrim, width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 6, offset: const Offset(0, 3)),
        ],
      ),
      child: const Icon(Icons.arrow_back_rounded, color: GameTone.textCream, size: 22),
    ),
  );

  Widget _circleBtn(IconData icon, VoidCallback onTap, {String? tooltip}) {
    final btn = GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42, height: 42,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFF6B4423), Color(0xFF3A2210)],
          ),
          shape: BoxShape.circle,
          border: Border.all(color: GameTone.goldTrim, width: 1.5),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 6, offset: const Offset(0, 3)),
          ],
        ),
        child: Icon(icon, color: GameTone.textCream, size: 20),
      ),
    );
    return tooltip != null ? Tooltip(message: tooltip, child: btn) : btn;
  }

  Widget _animChip(String name, bool active) => GestureDetector(
    onTap: () {
      _controller.playAnimation(animationName: name);
      setState(() => _currentAnim = name);
    },
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: active
              ? const [Color(0xFF6BBA5B), Color(0xFF1F4E2A)]
              : const [Color(0xFF6B4423), Color(0xFF3A2210)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: GameTone.goldTrim, width: active ? 1.8 : 1.2),
        boxShadow: [
          if (active) BoxShadow(color: const Color(0xFF6BE095).withOpacity(0.45), blurRadius: 10),
          BoxShadow(color: Colors.black.withOpacity(0.45), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Text(
        name,
        style: const TextStyle(
          color: GameTone.textCream,
          fontWeight: FontWeight.w800,
          fontSize: 11,
          letterSpacing: 0.4,
          shadows: [Shadow(color: Color(0xFF1A0E04), offset: Offset(0, 1), blurRadius: 0)],
        ),
      ),
    ),
  );
}
