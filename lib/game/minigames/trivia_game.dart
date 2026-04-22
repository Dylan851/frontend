// lib/game/minigames/trivia_game.dart
// Minijuego: Verdadero o Falso — preguntas sobre el animal.
// Banco de preguntas específico por animal + pool genérico. Cada partida
// escoge 7 preguntas aleatorias mezclando específicas y genéricas.

import 'dart:math' as math;
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

// ── Banco de preguntas específicas por id de animal ─────────────────────────
const Map<String, List<_TriviaQuestion>> _animalQuestions = {
  'deer': [
    _TriviaQuestion('¿Solo los ciervos macho tienen astas?', true,
        'Solo los machos. Las hembras se llaman ciervas.'),
    _TriviaQuestion('¿Las astas del ciervo tardan un año en crecer?', false,
        'Crecen muy rápido: ¡hasta 3 cm por día!'),
    _TriviaQuestion('¿Los ciervos pueden nadar?', true,
        'Son excelentes nadadores y cruzan ríos largos.'),
    _TriviaQuestion('¿Los ciervos son carnívoros?', false,
        'Son herbívoros: hierbas, hojas, bayas y corteza.'),
    _TriviaQuestion('¿Las crías del ciervo tienen manchas blancas?', true,
        'Las manchas las camuflan entre luz y sombra.'),
  ],
  'fox': [
    _TriviaQuestion('¿El zorro rojo es parte de la familia de los perros?', true,
        '¡Sí! Pertenece a los cánidos, como perros y lobos.'),
    _TriviaQuestion('¿Los zorros cazan en manadas grandes?', false,
        'Son cazadores solitarios; viven en grupos pequeños familiares.'),
    _TriviaQuestion('¿El zorro puede oír a un ratón bajo la nieve?', true,
        'Su oído detecta sonidos a más de 100 metros de distancia.'),
  ],
  'owl': [
    _TriviaQuestion('¿Los búhos pueden girar la cabeza 270°?', true,
        'Tienen 14 vértebras en el cuello (los humanos solo 7).'),
    _TriviaQuestion('¿Los búhos ven muy bien los colores?', false,
        'Ven muy bien en la oscuridad pero distinguen pocos colores.'),
    _TriviaQuestion('¿Las plumas del búho le permiten volar en silencio?', true,
        'Sus plumas con borde flecos amortiguan el ruido del aleteo.'),
  ],
  'bear': [
    _TriviaQuestion('¿Los osos hibernan durante todo el invierno?', true,
        'Bajan su ritmo cardíaco y viven de sus reservas de grasa.'),
    _TriviaQuestion('¿Los osos son malos nadadores?', false,
        'Son excelentes nadadores, sobre todo los osos polares.'),
    _TriviaQuestion('¿El oso pardo puede correr a 50 km/h?', true,
        'En distancias cortas, ¡más rápido que un atleta olímpico!'),
  ],
  'butterfly': [
    _TriviaQuestion('¿Las mariposas saborean con las patas?', true,
        'Tienen receptores químicos en las patas para identificar plantas.'),
    _TriviaQuestion('¿Las mariposas viven muchos años?', false,
        'La mayoría vive de 2 semanas a pocos meses.'),
    _TriviaQuestion('¿La monarca migra miles de kilómetros?', true,
        'Hasta 4800 km entre EE.UU. y México cada año.'),
  ],
  'frog': [
    _TriviaQuestion('¿Las ranas beben agua por la piel?', true,
        'Absorben agua a través de la piel, no necesitan beber.'),
    _TriviaQuestion('¿Todas las ranas ponen huevos en tierra?', false,
        'La mayoría los pone en agua; necesitan humedad.'),
    _TriviaQuestion('¿Hay ranas venenosas de colores brillantes?', true,
        'Las ranas dardo tienen veneno potente en la piel.'),
  ],
  'chicken': [
    _TriviaQuestion('¿Las gallinas tienen mejor visión que los humanos?', true,
        'Ven más colores, incluida la luz ultravioleta.'),
    _TriviaQuestion('¿Las gallinas vuelan largas distancias?', false,
        'Solo vuelan distancias cortas, de pocos metros.'),
  ],
  'pig': [
    _TriviaQuestion('¿Los cerdos son muy inteligentes?', true,
        'Son más inteligentes que perros y niños de 3 años.'),
    _TriviaQuestion('¿Los cerdos sudan mucho?', false,
        'Apenas sudan; por eso se revuelcan en barro para enfriarse.'),
  ],
  'cat': [
    _TriviaQuestion('¿Los gatos duermen hasta 16 horas al día?', true,
        'Duermen entre 12 y 16 h para ahorrar energía de caza.'),
    _TriviaQuestion('¿Los gatos ronronean solo cuando están felices?', false,
        'También ronronean cuando están estresados o heridos para calmarse.'),
    _TriviaQuestion('¿El gato distingue el sabor dulce?', false,
        'Son el único mamífero que NO detecta el sabor dulce.'),
  ],
  'wolf': [
    _TriviaQuestion('¿Los lobos viven y cazan en manada?', true,
        'La manada suele tener 6-10 miembros liderados por una pareja alfa.'),
    _TriviaQuestion('¿Aullar sirve para comunicarse a larga distancia?', true,
        'Se oye hasta a 10 km y coordina a toda la manada.'),
    _TriviaQuestion('¿El lobo es antepasado directo del gato doméstico?', false,
        'Es antepasado del perro, no del gato.'),
  ],
  'turtle': [
    _TriviaQuestion('¿Las tortugas pueden vivir más de 100 años?', true,
        'Algunas tortugas gigantes viven más de 150 años.'),
    _TriviaQuestion('¿La tortuga puede salir de su caparazón?', false,
        'El caparazón es parte de su esqueleto, no se puede quitar.'),
  ],
  'snow_fox': [
    _TriviaQuestion('¿El zorro ártico cambia el color de su pelaje?', true,
        'Blanco en invierno, marrón/gris en verano para camuflarse.'),
    _TriviaQuestion('¿Soporta temperaturas de -50°C?', true,
        'Su pelaje es el más aislante de cualquier mamífero.'),
  ],
  'porcupine': [
    _TriviaQuestion('¿El puercoespín dispara sus púas?', false,
        'No las dispara: se desprenden al clavarse en el atacante.'),
    _TriviaQuestion('¿Sus púas son pelos modificados?', true,
        'Son pelos rígidos cubiertos de queratina.'),
  ],
  'skunk': [
    _TriviaQuestion('¿El olor de la mofeta se huele a 1 km?', true,
        'Su spray es perceptible a más de 1,5 km a favor del viento.'),
    _TriviaQuestion('¿La mofeta es buena cazadora?', false,
        'Prefiere insectos y carroña; su mejor arma es el olor.'),
  ],
  'boar': [
    _TriviaQuestion('¿El jabalí es omnívoro?', true,
        'Come raíces, frutos, insectos y pequeños animales.'),
    _TriviaQuestion('¿Los jabalíes machos tienen colmillos permanentes?', true,
        'Sus colmillos siguen creciendo toda la vida.'),
  ],
  'goose': [
    _TriviaQuestion('¿Los gansos migran en formación de "V"?', true,
        'Ahorra energía: uno se aprovecha de la corriente del anterior.'),
    _TriviaQuestion('¿Los gansos son monógamos de por vida?', true,
        'Suelen emparejarse con el mismo compañero toda la vida.'),
  ],
  'green_frog': [
    _TriviaQuestion('¿La rana verde caza con la lengua pegajosa?', true,
        'La proyecta a gran velocidad para atrapar insectos.'),
    _TriviaQuestion('¿Puede respirar bajo el agua por sus branquias?', false,
        'Las ranas adultas respiran por pulmones y piel, no branquias.'),
  ],
  'toad': [
    _TriviaQuestion('¿Los sapos pueden vivir en lugares secos?', true,
        'Su piel más gruesa les permite vivir lejos del agua.'),
    _TriviaQuestion('¿Los sapos dan verrugas al tocarlos?', false,
        'Es un mito: no transmiten verrugas.'),
  ],
  'crab': [
    _TriviaQuestion('¿Los cangrejos caminan de lado?', true,
        'La estructura de sus patas hace el movimiento lateral más eficiente.'),
    _TriviaQuestion('¿Los cangrejos tienen esqueleto interno?', false,
        'Tienen exoesqueleto (caparazón) que mudan al crecer.'),
  ],
  'sheep': [
    _TriviaQuestion('¿Las ovejas reconocen rostros?', true,
        'Pueden recordar hasta 50 caras de ovejas y humanos durante años.'),
    _TriviaQuestion('¿La lana de oveja no crece si no se corta?', false,
        'La lana crece continuamente; hay que esquilarlas cada año.'),
  ],
  'chick': [
    _TriviaQuestion('¿Los pollitos rompen el huevo con un "diente"?', true,
        'Tienen un "diente de huevo" temporal en el pico para romperlo.'),
    _TriviaQuestion('¿Los pollitos pueden correr al nacer?', true,
        'A las pocas horas de nacer ya pueden caminar y comer solos.'),
  ],
};

// ── Pool genérico (se mezcla con las específicas) ───────────────────────────
const List<_TriviaQuestion> _genericQuestions = [
  _TriviaQuestion('¿Los mamíferos dan leche a sus crías?', true,
      'Es una de las características que los define.'),
  _TriviaQuestion('¿Todos los insectos tienen 6 patas?', true,
      'Seis patas es la característica principal del grupo.'),
  _TriviaQuestion('¿Las arañas son insectos?', false,
      'Son arácnidos: tienen 8 patas, no 6.'),
  _TriviaQuestion('¿Los peces respiran por pulmones?', false,
      'Respiran por branquias tomando oxígeno del agua.'),
  _TriviaQuestion('¿Las aves tienen huesos huecos?', true,
      'Los huesos ligeros les ayudan a volar.'),
  _TriviaQuestion('¿Los reptiles regulan su temperatura internamente?', false,
      'Son de sangre fría: dependen del sol para calentarse.'),
  _TriviaQuestion('¿La ballena azul es el animal más grande conocido?', true,
      'Puede medir 30 m y pesar 200 toneladas.'),
  _TriviaQuestion('¿El guepardo es el animal terrestre más rápido?', true,
      'Alcanza 110 km/h en carreras cortas.'),
  _TriviaQuestion('¿Los murciélagos están ciegos?', false,
      'Ven bien; también usan ecolocalización para orientarse.'),
  _TriviaQuestion('¿Los pulpos tienen tres corazones?', true,
      'Dos bombean sangre a las branquias y uno al resto del cuerpo.'),
  _TriviaQuestion('¿El elefante es el mamífero terrestre más grande?', true,
      'Un elefante africano puede pesar 6 toneladas.'),
  _TriviaQuestion('¿Los delfines son peces?', false,
      'Son mamíferos: respiran aire y amamantan a sus crías.'),
  _TriviaQuestion('¿Las jirafas tienen el mismo nº de vértebras que humanos?',
      true, 'Ambos tenemos 7 vértebras cervicales, solo que las suyas son enormes.'),
  _TriviaQuestion('¿Las abejas mueren al picar?', true,
      'Su aguijón queda atrapado y al separarse mueren.'),
  _TriviaQuestion('¿Los koalas duermen hasta 22 horas al día?', true,
      'Su dieta de eucalipto es tan pobre en energía que duermen mucho.'),
  _TriviaQuestion('¿Los canguros no pueden caminar hacia atrás?', true,
      'La forma de sus patas y cola se lo impide.'),
  _TriviaQuestion('¿Los caballos duermen siempre tumbados?', false,
      'Pueden dormir de pie gracias a un mecanismo de "candado" en las patas.'),
  _TriviaQuestion('¿Un grupo de leones se llama manada?', false,
      'Se llama "orgullo" (pride en inglés).'),
];

class _TriviaGameState extends State<TriviaGame> {
  late final List<_TriviaQuestion> _questions;

  @override
  void initState() {
    super.initState();
    final rng = math.Random();
    final specific = List<_TriviaQuestion>.from(
        _animalQuestions[widget.animal.id] ?? const []);
    final generic = List<_TriviaQuestion>.from(_genericQuestions);
    specific.shuffle(rng);
    generic.shuffle(rng);
    // Mezcla: hasta 4 específicas + el resto genéricas, total 7.
    final picked = <_TriviaQuestion>[];
    picked.addAll(specific.take(4));
    picked.addAll(generic.take(7 - picked.length));
    picked.shuffle(rng);
    _questions = picked;
  }

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
        // 7 preguntas: 6-7 aciertos=3★, 4-5=2★, 0-3=1★
        final stars = _correct >= 6 ? 3 : _correct >= 4 ? 2 : 1;
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
