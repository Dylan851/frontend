// lib/game/minigames/trivia_game.dart
// Minijuego: Verdadero o Falso — preguntas sobre el animal

import 'package:flutter/material.dart';
import '../../data/animal_data.dart';
import '../../theme/app_theme.dart';

class TriviaGame extends StatefulWidget {
  final AnimalData animal;
  final void Function(int stars) onComplete;
  const TriviaGame({super.key, required this.animal, required this.onComplete});
  @override State<TriviaGame> createState() => _TriviaGameState();
}

class _TriviaQuestion {
  final String question;
  final bool answer;
  final String explanation;
  const _TriviaQuestion(this.question, this.answer, this.explanation);
}

class _TriviaGameState extends State<TriviaGame> {
  static const _questions = [
    _TriviaQuestion('¿Solo los ciervos macho tienen astas?', true,
        '¡Correcto! Solo los machos (ciervos) tienen astas. Las hembras se llaman ciervas.'),
    _TriviaQuestion('¿Las astas del ciervo tardan un año en crecer?', false,
        'Las astas crecen muy rápido: ¡hasta 3 cm por día! Se renuevan cada año.'),
    _TriviaQuestion('¿Los ciervos pueden nadar?', true,
        '¡Sí! Los ciervos son excelentes nadadores y pueden cruzar ríos largos.'),
    _TriviaQuestion('¿Los ciervos son carnívoros?', false,
        'Los ciervos son herbívoros: comen hierbas, hojas, bayas y corteza de árbol.'),
    _TriviaQuestion('¿Las crías del ciervo tienen manchas blancas?', true,
        '¡Exacto! Las manchas las camuflan entre la luz y sombra del bosque.'),
  ];

  int _current = 0;
  int _correct = 0;
  bool? _answered; // null=sin responder, true=correcto, false=incorrecto
  bool _showExplanation = false;

  void _answer(bool val) {
    if (_answered != null) return;
    final isRight = val == _questions[_current].answer;
    setState(() { _answered = isRight; _showExplanation = true; if (isRight) _correct++; });

    Future.delayed(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      if (_current < _questions.length - 1) {
        setState(() { _current++; _answered = null; _showExplanation = false; });
      } else {
        final stars = _correct >= 5 ? 3 : _correct >= 3 ? 2 : 1;
        widget.onComplete(stars);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[_current];
    final progress = (_current + 1) / _questions.length;

    return Column(children: [
      // Header
      Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(children: [
          Text(widget.animal.emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('¡Verdadero o Falso!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Row(children: [
              Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(value: progress, minHeight: 6,
                  backgroundColor: Colors.white.withOpacity(0.15),
                  valueColor: const AlwaysStoppedAnimation(AppColors.greenAccent)))),
              const SizedBox(width: 8),
              Text('${_current + 1}/${_questions.length}', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11)),
              const SizedBox(width: 8),
              Text('✅ $_correct', style: const TextStyle(color: AppColors.greenAccent, fontWeight: FontWeight.bold, fontSize: 12)),
            ]),
          ])),
        ])),

      // Pregunta
      Expanded(child: Center(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 60),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          // Caja de pregunta
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Container(
              key: ValueKey(_current),
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.07),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.12)),
              ),
              child: Column(children: [
                Text(widget.animal.emoji, style: const TextStyle(fontSize: 50)),
                const SizedBox(height: 16),
                Text(q.question, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, height: 1.4), textAlign: TextAlign.center),
              ]),
            ),
          ),

          const SizedBox(height: 24),

          // Explicación
          if (_showExplanation)
            AnimatedOpacity(
              opacity: _showExplanation ? 1 : 0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: (_answered! ? AppColors.greenAccent : AppColors.badgeRed).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: (_answered! ? AppColors.greenAccent : AppColors.badgeRed).withOpacity(0.4)),
                ),
                child: Row(children: [
                  Text(_answered! ? '✅' : '❌', style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(child: Text(q.explanation, style: const TextStyle(color: Colors.white, fontSize: 12))),
                ]),
              ),
            ),

          const SizedBox(height: 24),

          // Botones
          if (_answered == null)
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _answerBtn('✅  VERDADERO', true, AppColors.greenAccent),
              const SizedBox(width: 20),
              _answerBtn('❌  FALSO', false, AppColors.badgeRed),
            ]),
        ]),
      ))),
    ]);
  }

  Widget _answerBtn(String label, bool val, Color color) => GestureDetector(
    onTap: () => _answer(val),
    child: Container(
      width: 180, height: 54,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.6), width: 2),
        boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 10)],
      ),
      child: Center(child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15))),
    ),
  );
}
