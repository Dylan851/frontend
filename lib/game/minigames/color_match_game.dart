// lib/game/minigames/color_match_game.dart
// Minijuego: Elige el color correcto de la Mariposa Monarca

import 'package:flutter/material.dart';
import '../../data/animal_data.dart';
import '../../theme/app_theme.dart';

class ColorMatchGame extends StatefulWidget {
  final AnimalData animal;
  final void Function(int stars) onComplete;
  const ColorMatchGame({super.key, required this.animal, required this.onComplete});
  @override State<ColorMatchGame> createState() => _ColorMatchGameState();
}

class _ColorPart {
  final String name;
  final Color correctColor;
  final List<Color> options;
  Color? chosen;
  _ColorPart(this.name, this.correctColor, this.options);
  bool get isCorrect => chosen == correctColor;
}

class _ColorMatchGameState extends State<ColorMatchGame> {
  final _parts = [
    _ColorPart('Alas superiores', const Color(0xFFFF6B00),
        [const Color(0xFFFF6B00), Colors.blue, Colors.purple, Colors.green]),
    _ColorPart('Manchas negras', Colors.black,
        [Colors.black, Colors.brown, Colors.blue, Colors.red]),
    _ColorPart('Puntos blancos', Colors.white,
        [Colors.white, Colors.yellow, Colors.pink, Colors.cyan]),
    _ColorPart('Cuerpo', Colors.black,
        [Colors.black, Colors.orange, Colors.grey, Colors.brown]),
  ];

  int _selectedPart = 0;
  bool _completed = false;

  void _pickColor(Color c) {
    setState(() => _parts[_selectedPart].chosen = c);
  }

  void _checkAll() {
    final correct = _parts.where((p) => p.isCorrect).length;
    _completed = true;
    final stars = correct == 4 ? 3 : correct >= 2 ? 2 : 1;
    Future.delayed(const Duration(milliseconds: 500), () => widget.onComplete(stars));
  }

  @override
  Widget build(BuildContext context) {
    final allChosen = _parts.every((p) => p.chosen != null);

    return Column(children: [
      // Header
      Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(children: [
          Text(widget.animal.emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('¡Pinta la Mariposa Monarca!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            Text('Selecciona cada parte y elige el color correcto', style: TextStyle(color: Colors.white60, fontSize: 11)),
          ])),
        ])),

      Expanded(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        // Mariposa visual
        _buildButterfly(),
        const SizedBox(width: 40),
        // Panel de selección
        SizedBox(width: 300, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          // Partes seleccionables
          ..._parts.asMap().entries.map((e) {
            final i = e.key; final part = e.value;
            final selected = _selectedPart == i;
            return GestureDetector(
              onTap: () => setState(() => _selectedPart = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? Colors.white.withOpacity(0.12) : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: selected ? AppColors.greenAccent : Colors.white.withOpacity(0.1), width: selected ? 2 : 1),
                ),
                child: Row(children: [
                  Text(part.name, style: TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.bold, fontSize: 13)),
                  const Spacer(),
                  if (part.chosen != null) Container(width: 24, height: 24,
                    decoration: BoxDecoration(color: part.chosen, shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.4), width: 1))),
                  if (part.chosen != null && _completed)
                    Padding(padding: const EdgeInsets.only(left: 4),
                      child: Text(part.isCorrect ? '✅' : '❌', style: const TextStyle(fontSize: 14))),
                ]),
              ),
            );
          }),

          const SizedBox(height: 12),

          // Paleta de colores para la parte seleccionada
          Wrap(spacing: 10, children: _parts[_selectedPart].options.map((c) =>
            GestureDetector(
              onTap: () => _pickColor(c),
              child: Container(width: 40, height: 40,
                decoration: BoxDecoration(color: c, shape: BoxShape.circle,
                  border: Border.all(color: _parts[_selectedPart].chosen == c
                      ? AppColors.greenAccent : Colors.white.withOpacity(0.3),
                      width: _parts[_selectedPart].chosen == c ? 3 : 1),
                  boxShadow: [if (_parts[_selectedPart].chosen == c)
                    BoxShadow(color: AppColors.greenAccent.withOpacity(0.4), blurRadius: 8)])),
            )).toList()),

          const SizedBox(height: 16),

          if (allChosen && !_completed)
            ElevatedButton(onPressed: _checkAll,
              child: const Text('✅ ¡Comprobar!')),
        ])),
      ])),
    ]);
  }

  Widget _buildButterfly() {
    final wingColor = _parts[0].chosen ?? const Color(0xFF333333);
    final spotColor = _parts[1].chosen ?? const Color(0xFF222222);
    final dotColor  = _parts[2].chosen ?? Colors.grey.withOpacity(0.3);
    final bodyColor = _parts[3].chosen ?? const Color(0xFF222222);

    return SizedBox(
      width: 180, height: 180,
      child: CustomPaint(
        painter: _ButterflyPainter(wingColor, spotColor, dotColor, bodyColor),
      ),
    );
  }
}

class _ButterflyPainter extends CustomPainter {
  final Color wing, spot, dot, body;
  const _ButterflyPainter(this.wing, this.spot, this.dot, this.body);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Ala izquierda superior
    _drawWing(canvas, cx, cy, -1, -1, wing);
    // Ala derecha superior
    _drawWing(canvas, cx, cy, 1, -1, wing);
    // Ala izquierda inferior
    _drawWingLower(canvas, cx, cy, -1, wing);
    // Ala derecha inferior
    _drawWingLower(canvas, cx, cy, 1, wing);

    // Manchas negras
    for (final offset in [Offset(cx - 35, cy - 35), Offset(cx + 35, cy - 35),
        Offset(cx - 20, cy - 15), Offset(cx + 20, cy - 15)]) {
      canvas.drawCircle(offset, 6, Paint()..color = spot);
    }

    // Puntos blancos en los bordes
    for (final offset in [Offset(cx - 60, cy - 50), Offset(cx + 60, cy - 50),
        Offset(cx - 55, cy - 30), Offset(cx + 55, cy - 30),
        Offset(cx - 58, cy - 10), Offset(cx + 58, cy - 10)]) {
      canvas.drawCircle(offset, 3, Paint()..color = dot);
    }

    // Cuerpo
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy), width: 10, height: 50),
      const Radius.circular(5)),
      Paint()..color = body);

    // Antenas
    final antennaPaint = Paint()..color = body..strokeWidth = 2..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(cx, cy - 22), Offset(cx - 20, cy - 55), antennaPaint);
    canvas.drawLine(Offset(cx, cy - 22), Offset(cx + 20, cy - 55), antennaPaint);
    canvas.drawCircle(Offset(cx - 20, cy - 56), 3, Paint()..color = body);
    canvas.drawCircle(Offset(cx + 20, cy - 56), 3, Paint()..color = body);
  }

  void _drawWing(Canvas canvas, double cx, double cy, double sx, double sy, Color c) {
    final path = Path()
      ..moveTo(cx, cy)
      ..cubicTo(cx + sx * 20, cy + sy * 55, cx + sx * 75, cy + sy * 65, cx + sx * 70, cy + sy * 20)
      ..cubicTo(cx + sx * 65, cy - sy * 10, cx + sx * 20, cy - sy * 5, cx, cy);
    canvas.drawPath(path, Paint()..color = c);
    canvas.drawPath(path, Paint()..color = Colors.black.withOpacity(0.3)..style = PaintingStyle.stroke..strokeWidth = 1.5);
  }

  void _drawWingLower(Canvas canvas, double cx, double cy, double sx, Color c) {
    final path = Path()
      ..moveTo(cx, cy)
      ..cubicTo(cx + sx * 15, cy + 10, cx + sx * 55, cy + 25, cx + sx * 45, cy + 60)
      ..cubicTo(cx + sx * 35, cy + 70, cx + sx * 10, cy + 55, cx, cy);
    canvas.drawPath(path, Paint()..color = c);
    canvas.drawPath(path, Paint()..color = Colors.black.withOpacity(0.3)..style = PaintingStyle.stroke..strokeWidth = 1.5);
  }

  @override bool shouldRepaint(_ButterflyPainter o) =>
    wing != o.wing || spot != o.spot || dot != o.dot || body != o.body;
}
