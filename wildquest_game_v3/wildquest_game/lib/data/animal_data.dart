// lib/data/animal_data.dart

enum MinigameType {
  memoryCards,  // Voltear cartas encontrando parejas
  silhouette,   // Adivina el animal por su silueta
  soundMatch,   // Emparejar animal con su sonido
  trivia,       // Pregunta de verdadero/falso
  puzzle,       // Ordenar las piezas
  colorMatch,   // Pinta el animal con el color correcto
  taming,       // 🆕 Paddle de domesticación
}

class AnimalData {
  final String id;
  final String name;
  final String emoji;
  final String habitat;
  final String description;
  final List<String> funFacts;
  final MinigameType minigame;
  final String diet;
  final String size;
  final bool isDiscovered;

  const AnimalData({
    required this.id,
    required this.name,
    required this.emoji,
    required this.habitat,
    required this.description,
    required this.funFacts,
    required this.minigame,
    required this.diet,
    required this.size,
    this.isDiscovered = false,
  });

  AnimalData copyWith({bool? isDiscovered}) => AnimalData(
    id: id, name: name, emoji: emoji, habitat: habitat,
    description: description, funFacts: funFacts, minigame: minigame,
    diet: diet, size: size,
    isDiscovered: isDiscovered ?? this.isDiscovered,
  );
}

class AnimalCatalog {
  static const List<AnimalData> all = [
    AnimalData(
      id: 'fox', name: 'Zorro Rojo', emoji: '🦊', habitat: 'Bosque',
      description: 'El zorro rojo es uno de los animales más inteligentes del bosque. '
          'Usa su espesa cola como bufanda en invierno y para comunicarse.',
      funFacts: [
        'Los zorros pueden escuchar un ratón bajo 1 metro de nieve',
        'Tienen pupilas verticales como los gatos',
        'Son los únicos cánidos que pueden trepar árboles',
        'Cada zorro tiene un ladrido único, como una huella dactilar',
      ],
      minigame: MinigameType.taming, // 🆕 Paddle de domesticación
      diet: 'Omnívoro', size: '35–50 cm de alto',
    ),

    AnimalData(
      id: 'deer', name: 'Ciervo', emoji: '🦌', habitat: 'Pradera y Bosque',
      description: 'El ciervo es un elegante habitante del bosque. Solo los machos '
          'tienen astas, que mudan y crecen cada año.',
      funFacts: [
        'Las astas son el tejido animal que más rápido crece: ¡3 cm por día!',
        'Los ciervos nadan muy bien y pueden cruzar ríos largos',
        'Las crías tienen manchas blancas que desaparecen al crecer',
        'Pueden correr a más de 50 km/h para escapar de depredadores',
      ],
      minigame: MinigameType.trivia,
      diet: 'Herbívoro', size: '70–120 cm de alto',
    ),

    AnimalData(
      id: 'owl', name: 'Búho Real', emoji: '🦉', habitat: 'Bosque nocturno',
      description: 'El búho real es el mayor búho de Europa. Caza de noche gracias a '
          'su visión y oído excepcionales.',
      funFacts: [
        'Puede girar la cabeza 270 grados, ¡casi completo!',
        'Sus plumas son tan silenciosas que su vuelo es inaudible',
        'Cada ojo tiene el tamaño de todo el cerebro del búho',
        'Puede ver en la oscuridad 100 veces mejor que un humano',
      ],
      minigame: MinigameType.memoryCards,
      diet: 'Carnívoro', size: '60–75 cm de alto',
    ),

    AnimalData(
      id: 'butterfly', name: 'Mariposa Monarca', emoji: '🦋',
      habitat: 'Prado y Jardín',
      description: 'La mariposa monarca realiza una de las migraciones más increíbles '
          'de la naturaleza: más de 4.000 km dos veces al año.',
      funFacts: [
        'Prueban la comida con los pies, ¡tienen "lengua" en las patitas!',
        'Migran de Canadá a México cada otoño guiadas por el sol',
        'Su crisálida es de color verde dorado, uno de los más raros',
        'Saben si una planta es venenosa antes de tocarla',
      ],
      minigame: MinigameType.colorMatch,
      diet: 'Néctar de flores', size: '10 cm de envergadura',
    ),

    AnimalData(
      id: 'bear', name: 'Oso Pardo', emoji: '🐻',
      habitat: 'Montaña y Bosque',
      description: 'El oso pardo es el mayor carnívoro terrestre de Europa. Pasa el '
          'invierno en hibernación, reduciendo su ritmo cardíaco a 8 latidos por minuto.',
      funFacts: [
        'Su olfato es 7 veces más potente que el de un perro',
        'Pueden correr a 50 km/h a pesar de su tamaño',
        'No duermen toda la hibernación: se despiertan varias veces',
        'Las crías nacen del tamaño de un conejillo de indias',
      ],
      minigame: MinigameType.puzzle,
      diet: 'Omnívoro', size: '1–1.5 m de alto',
    ),

    AnimalData(
      id: 'frog', name: 'Rana Venenosa', emoji: '🐸',
      habitat: 'Río y Charca',
      description: 'La rana venenosa es famosa por sus colores brillantes que advierten '
          'a los depredadores de su toxicidad. ¡Su veneno lo obtiene de su dieta!',
      funFacts: [
        'Sus brillantes colores son una señal de peligro para los depredadores',
        'En cautiverio pierden la toxicidad al cambiar de dieta',
        'Respiran por la piel además de por los pulmones',
        'Algunas especies cuidan a sus renacuajos en su espalda',
      ],
      minigame: MinigameType.soundMatch,
      diet: 'Insectívoro', size: '2–6 cm',
    ),
  ];

  static AnimalData? findById(String id) {
    try { return all.firstWhere((a) => a.id == id); } catch (_) { return null; }
  }
}
