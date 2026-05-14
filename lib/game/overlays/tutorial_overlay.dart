// lib/game/overlays/tutorial_overlay.dart
// Overlays de tutorial:
//  · [TutorialOverlay]   → explicación general de la app (primera vez)
//  · [MapIntroOverlay]   → historia/objetivo del mapa (primera vez por mapa)
//
// Estilo "Cozy Pixel Adventure": marco de madera + acentos dorados, igual
// que la tienda y el menú principal.

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
    final scale =
        (MediaQuery.sizeOf(context).shortestSide / 600).clamp(0.62, 1.05);
    return Material(
      color: Colors.black.withOpacity(0.78),
      child: SafeArea(
        child: Stack(children: [
          // Skip top-right (wooden plaque).
          Positioned(
            top: 10,
            right: 10,
            child: GestureDetector(
              onTap: _skip,
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 12 * scale, vertical: 7 * scale),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF6B4423), Color(0xFF3A2210)],
                  ),
                  borderRadius: BorderRadius.circular(10 * scale),
                  border:
                      Border.all(color: GameTone.goldTrim, width: 1.4 * scale),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.45),
                        blurRadius: 5,
                        offset: const Offset(0, 2)),
                  ],
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('Saltar',
                      style: TextStyle(
                        color: GameTone.textCream,
                        fontWeight: FontWeight.w900,
                        fontSize: 12 * scale,
                        letterSpacing: 0.4,
                        shadows: const [
                          Shadow(
                              color: Color(0xFF1A0E04),
                              offset: Offset(0, 2),
                              blurRadius: 0),
                        ],
                      )),
                  SizedBox(width: 4 * scale),
                  Icon(Icons.skip_next_rounded,
                      color: GameTone.textCream, size: 16 * scale),
                ]),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 22 * scale),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: ConstrainedBox(
                  key: ValueKey(_i),
                  constraints: BoxConstraints(maxWidth: 400 * scale),
                  child: PixelFrame(
                    radius: 18 * scale,
                    innerFill: GameTone.panelDark,
                    padding: EdgeInsets.fromLTRB(
                        20 * scale, 18 * scale, 20 * scale, 18 * scale),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text(s.emoji, style: TextStyle(fontSize: 64 * scale)),
                      SizedBox(height: 8 * scale),
                      ShaderMask(
                        shaderCallback: (b) => const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFFFFE48A),
                            Color(0xFFE8B452),
                            Color(0xFFB07A2A),
                          ],
                        ).createShader(b),
                        child: Text(
                          s.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20 * scale,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                            shadows: const [
                              Shadow(
                                  color: Color(0xFF1A0E04),
                                  offset: Offset(-2, 0),
                                  blurRadius: 0),
                              Shadow(
                                  color: Color(0xFF1A0E04),
                                  offset: Offset(2, 0),
                                  blurRadius: 0),
                              Shadow(
                                  color: Color(0xFF1A0E04),
                                  offset: Offset(0, 2),
                                  blurRadius: 0),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10 * scale),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10 * scale, vertical: 8 * scale),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF3A2210), Color(0xFF1A0E04)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10 * scale),
                          border: Border.all(
                              color: GameTone.goldTrim.withOpacity(0.7),
                              width: 1.3),
                        ),
                        child: Text(
                          s.body,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.parchment.withOpacity(0.92),
                            fontSize: 13 * scale,
                            height: 1.4,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(height: 16 * scale),
                      // Dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          TutorialOverlay.slides.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            margin: EdgeInsets.symmetric(horizontal: 3 * scale),
                            width: i == _i ? 16 * scale : 7 * scale,
                            height: 7 * scale,
                            decoration: BoxDecoration(
                              color: i == _i
                                  ? GameTone.goldBright
                                  : GameTone.woodOuter,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                  color: GameTone.goldTrim.withOpacity(0.7),
                                  width: 1),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 14 * scale),
                      _woodBtn(
                        label: isLast ? '¡Empezar!' : 'Siguiente →',
                        onTap: _next,
                        primary: true,
                        scale: scale,
                      ),
                    ]),
                  ),
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
  const MapIntroOverlay(
      {super.key, required this.mapId, required this.onClose});

  static const Map<String,
      ({String title, String emoji, String story, String objective})> _data = {
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
    final scale =
        (MediaQuery.sizeOf(context).shortestSide / 600).clamp(0.62, 1.05);
    return Material(
      color: Colors.black.withOpacity(0.82),
      child: SafeArea(
        child: Stack(children: [
          Positioned(
            top: 10,
            right: 10,
            child: GestureDetector(
              onTap: onClose,
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 12 * scale, vertical: 7 * scale),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF6B4423), Color(0xFF3A2210)],
                  ),
                  borderRadius: BorderRadius.circular(10 * scale),
                  border:
                      Border.all(color: GameTone.goldTrim, width: 1.4 * scale),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('Saltar',
                      style: TextStyle(
                          color: GameTone.textCream,
                          fontWeight: FontWeight.w900,
                          fontSize: 12 * scale)),
                  SizedBox(width: 4 * scale),
                  Icon(Icons.skip_next_rounded,
                      color: GameTone.textCream, size: 16 * scale),
                ]),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.all(12 * scale),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 480 * scale,
                  maxHeight: MediaQuery.sizeOf(context).height * 0.92,
                ),
                child: PixelFrame(
                  radius: 18 * scale,
                  innerFill: GameTone.panelDark,
                  padding: EdgeInsets.fromLTRB(
                      16 * scale, 14 * scale, 16 * scale, 14 * scale),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(d.emoji, style: TextStyle(fontSize: 36 * scale)),
                    SizedBox(height: 4 * scale),
                    ShaderMask(
                      shaderCallback: (b) => const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFFFFE48A),
                          Color(0xFFE8B452),
                          Color(0xFFB07A2A),
                        ],
                      ).createShader(b),
                      child: Text(d.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18 * scale,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.6,
                            shadows: const [
                              Shadow(
                                  color: Color(0xFF1A0E04),
                                  offset: Offset(-2, 0),
                                  blurRadius: 0),
                              Shadow(
                                  color: Color(0xFF1A0E04),
                                  offset: Offset(2, 0),
                                  blurRadius: 0),
                              Shadow(
                                  color: Color(0xFF1A0E04),
                                  offset: Offset(0, 2),
                                  blurRadius: 0),
                            ],
                          )),
                    ),
                    SizedBox(height: 10 * scale),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(10 * scale),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF3A2210),
                                      Color(0xFF1A0E04)
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(10 * scale),
                                  border: Border.all(
                                      color: GameTone.goldTrim
                                          .withOpacity(0.7),
                                      width: 1.3),
                                ),
                                child: Text(d.story,
                                    style: TextStyle(
                                      color: AppColors.parchment
                                          .withOpacity(0.9),
                                      fontSize: 11.5 * scale,
                                      height: 1.45,
                                      fontWeight: FontWeight.w600,
                                    )),
                              ),
                              SizedBox(height: 8 * scale),
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(10 * scale),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF1F4A2C),
                                      Color(0xFF0E2914),
                                    ],
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(10 * scale),
                                  border: Border.all(
                                      color:
                                          AppColors.amber.withOpacity(0.55),
                                      width: 1.4),
                                  boxShadow: [
                                    BoxShadow(
                                        color: AppColors.amber
                                            .withOpacity(0.18),
                                        blurRadius: 8),
                                  ],
                                ),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(children: [
                                        Icon(Icons.flag_rounded,
                                            color: GameTone.goldBright,
                                            size: 16 * scale),
                                        SizedBox(width: 6 * scale),
                                        Text('Tu objetivo',
                                            style: TextStyle(
                                              color: GameTone.textGold,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 12 * scale,
                                              letterSpacing: 0.5,
                                            )),
                                      ]),
                                      SizedBox(height: 6 * scale),
                                      Text(d.objective,
                                          style: TextStyle(
                                            color: GameTone.textCream,
                                            fontSize: 11.5 * scale,
                                            height: 1.45,
                                            fontWeight: FontWeight.w600,
                                          )),
                                    ]),
                              ),
                            ]),
                      ),
                    ),
                    SizedBox(height: 12 * scale),
                    _woodBtn(
                      label: '¡A la aventura!',
                      onTap: onClose,
                      primary: true,
                      scale: scale,
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

Widget _woodBtn({
  required String label,
  required VoidCallback onTap,
  required bool primary,
  required double scale,
}) {
  final colors = primary
      ? const [Color(0xFF6BBA5B), Color(0xFF3A7A3A), Color(0xFF1F4E2A)]
      : const [Color(0xFF6B4423), Color(0xFF3A2210)];
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding:
          EdgeInsets.symmetric(horizontal: 24 * scale, vertical: 11 * scale),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(11 * scale),
        border: Border.all(
            color: GameTone.goldTrim, width: primary ? 1.8 : 1.4),
        boxShadow: [
          if (primary)
            BoxShadow(
                color: const Color(0xFF6BE095).withOpacity(0.4),
                blurRadius: 14),
          BoxShadow(
              color: Colors.black.withOpacity(0.45),
              blurRadius: 5,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Text(label,
          style: TextStyle(
            color: GameTone.textCream,
            fontWeight: FontWeight.w900,
            fontSize: 14 * scale,
            letterSpacing: 0.6,
            shadows: const [
              Shadow(
                  color: Color(0xFF1A0E04),
                  offset: Offset(0, 2),
                  blurRadius: 0),
            ],
          )),
    ),
  );
}
