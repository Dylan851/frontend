// lib/game/overlays/tutorial_overlay.dart
// Overlays de tutorial:
//  · [TutorialOverlay]   → explicación general de la app (primera vez)
//  · [MapIntroOverlay]   → historia/objetivo del mapa (primera vez por mapa)
//
// Ambos son saltables y usan un sistema de "slides" con next/skip.

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class TutorialSlide {
  final String emoji;
  final String title;
  final String body;
  const TutorialSlide({
    required this.emoji,
    required this.title,
    required this.body,
  });
}

/// Tutorial general de la app (se muestra la primera vez que se abre).
class TutorialOverlay extends StatefulWidget {
  final VoidCallback onFinish;
  const TutorialOverlay({super.key, required this.onFinish});

  static const List<TutorialSlide> slides = [
    TutorialSlide(
      emoji: '🌿',
      title: '¡Bienvenido, Explorador!',
      body:
          'Recorre los bosques de Aldea Canta y sus rutas para descubrir animales salvajes, recolectar objetos y resolver minijuegos educativos.',
    ),
    TutorialSlide(
      emoji: '🕹️',
      title: 'Cómo moverte',
      body:
          'Usa el joystick virtual (abajo izquierda) o las teclas WASD / flechas en PC. Pulsa el botón verde para interactuar con animales cercanos.',
    ),
    TutorialSlide(
      emoji: '🐾',
      title: 'Animales y minijuegos',
      body:
          'Al acercarte a un animal aparecerá su ficha. ¡Juega al minijuego para desbloquearlo en tu Colección y ganar XP + monedas!',
    ),
    TutorialSlide(
      emoji: '💰',
      title: 'Cofres y recompensas',
      body:
          'En los bordes de cada zona transitable encontrarás cofres con monedas, gemas y objetos útiles. ¡Ábrelos todos!',
    ),
    TutorialSlide(
      emoji: '🎒',
      title: 'Mochila y power-ups',
      body:
          'En tu mochila tienes comida para recuperar vida y power-ups (🍀 +1★, 🎫 3★ automáticas, 📜 reintento gratis…) para usar en los minijuegos.',
    ),
    TutorialSlide(
      emoji: '🛒',
      title: 'Tienda',
      body:
          'Compra más items con las monedas y gemas que ganes. ¡Pronto irás al nivel 1!',
    ),
  ];

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay> {
  int _i = 0;

  void _next() {
    if (_i < TutorialOverlay.slides.length - 1) {
      setState(() => _i++);
    } else {
      widget.onFinish();
    }
  }

  void _skip() => widget.onFinish();

  @override
  Widget build(BuildContext context) {
    final s = TutorialOverlay.slides[_i];
    final isLast = _i == TutorialOverlay.slides.length - 1;
    return Material(
      color: Colors.black.withOpacity(0.78),
      child: SafeArea(
        child: Stack(children: [
          // Skip top-right
          Positioned(
            top: 10, right: 10,
            child: GestureDetector(
              onTap: _skip,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: const [
                  Text('Saltar',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 12)),
                  SizedBox(width: 4),
                  Icon(Icons.skip_next_rounded, color: Colors.white, size: 16),
                ]),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Container(
                  key: ValueKey(_i),
                  constraints: const BoxConstraints(maxWidth: 380),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1B4A2E), Color(0xFF0D2B1A)],
                    ),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                        color: AppColors.greenAccent.withOpacity(0.5),
                        width: 2),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.greenAccent.withOpacity(0.25),
                          blurRadius: 30),
                    ],
                  ),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(s.emoji, style: const TextStyle(fontSize: 72)),
                    const SizedBox(height: 10),
                    Text(s.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900)),
                    const SizedBox(height: 10),
                    Text(s.body,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.82),
                            fontSize: 14,
                            height: 1.4)),
                    const SizedBox(height: 20),
                    // Dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        TutorialOverlay.slides.length,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: i == _i ? 16 : 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: i == _i
                                ? AppColors.greenAccent
                                : Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _next,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [
                            AppColors.greenAccent,
                            AppColors.greenDeep
                          ]),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                                color:
                                    AppColors.greenAccent.withOpacity(0.4),
                                blurRadius: 14),
                          ],
                        ),
                        child: Text(
                          isLast ? '¡Empezar!' : 'Siguiente →',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 14),
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

/// Overlay con la historia/objetivo del mapa. El primer mapa tiene un texto
/// narrativo especial; el resto una intro genérica por id.
class MapIntroOverlay extends StatelessWidget {
  final String mapId;
  final VoidCallback onClose;
  const MapIntroOverlay({super.key, required this.mapId, required this.onClose});

  static const Map<String, ({String title, String emoji, String story, String objective})> _data = {
    'jungle': (
      title: 'Aldea Canta — El principio',
      emoji: '🌿',
      story:
          'Hace muchas lunas, los animales del bosque vivían en armonía alrededor de Aldea Canta. Una mañana, el anciano del pueblo notó que las criaturas ya no se dejaban ver: alguien había roto el equilibrio del bosque.\n\nÉl cree que tú, con tu curiosidad y buen corazón, puedes reconectar con cada animal y devolverles la confianza perdida.',
      objective:
          'Encuentra a los 6 animales escondidos en la Ruta 1, acércate a ellos y supera sus minijuegos para añadirlos a tu Colección. Busca cofres en los bordes del sendero para conseguir monedas y power-ups.',
    ),
    'savanna': (
      title: 'Ruta del Bosque',
      emoji: '🌳',
      story:
          'Los caminos entre montañas esconden nuevas especies. Dicen que aquí se oyen cantos de aves nunca antes vistas.',
      objective:
          'Descubre los 6 animales de esta ruta y completa sus minijuegos para expandir tu Colección.',
    ),
    'farm': (
      title: 'Ruta Rocosa',
      emoji: '⛰️',
      story:
          'El terreno escarpado guarda criaturas resistentes, acostumbradas al frío de las cumbres.',
      objective:
          'Explora con cuidado: los cofres suelen esconderse en los bordes de los acantilados.',
    ),
    'ocean': (
      title: 'Ruta Costera',
      emoji: '🌊',
      story:
          'El sonido del mar atrae a criaturas únicas. Algunas solo aparecen con la marea baja.',
      objective:
          'Recorre la costa, descubre a sus habitantes y consigue tesoros ocultos en la arena.',
    ),
  };

  @override
  Widget build(BuildContext context) {
    final d = _data[mapId] ?? _data['jungle']!;
    return Material(
      color: Colors.black.withOpacity(0.82),
      child: SafeArea(
        child: Stack(children: [
          Positioned(
            top: 10, right: 10,
            child: GestureDetector(
              onTap: onClose,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: const [
                  Text('Saltar',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 12)),
                  SizedBox(width: 4),
                  Icon(Icons.skip_next_rounded,
                      color: Colors.white, size: 16),
                ]),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(22),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 420),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1A4A2E), Color(0xFF0D2B1A)],
                  ),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                      color: AppColors.gold.withOpacity(0.55), width: 2),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.gold.withOpacity(0.22),
                        blurRadius: 30),
                  ],
                ),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(d.emoji, style: const TextStyle(fontSize: 64)),
                  const SizedBox(height: 6),
                  Text(d.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: AppColors.gold,
                          fontSize: 20,
                          fontWeight: FontWeight.w900)),
                  const SizedBox(height: 14),
                  // Story
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.28),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Text(d.story,
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.88),
                            fontSize: 13,
                            height: 1.5)),
                  ),
                  const SizedBox(height: 12),
                  // Objetivo
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.greenAccent.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.greenAccent.withOpacity(0.5)),
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: const [
                            Icon(Icons.flag_rounded,
                                color: AppColors.greenAccent, size: 16),
                            SizedBox(width: 6),
                            Text('Tu objetivo',
                                style: TextStyle(
                                    color: AppColors.greenAccent,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12)),
                          ]),
                          const SizedBox(height: 6),
                          Text(d.objective,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  height: 1.45)),
                        ]),
                  ),
                  const SizedBox(height: 18),
                  GestureDetector(
                    onTap: onClose,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [
                          AppColors.gold,
                          AppColors.goldDark,
                        ]),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                              color: AppColors.gold.withOpacity(0.4),
                              blurRadius: 14),
                        ],
                      ),
                      child: const Text('¡A la aventura!',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w900,
                              fontSize: 14)),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
