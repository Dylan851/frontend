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

  /// Sonido característico mostrado en el diálogo de encuentro (p.ej. "¡Cluck, cluck!").
  final String sound;

  /// Ruta del spritesheet (64x16 con 4 frames de 16x16) — null para animales antiguos.
  final String? spriteAsset;

  /// Dato curioso extra estilo Wikipedia — se muestra en la colección al desbloquear.
  final String wikiFact;

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
    this.sound = '',
    this.spriteAsset,
    this.wikiFact = '',
  });

  AnimalData copyWith({bool? isDiscovered}) => AnimalData(
    id: id, name: name, emoji: emoji, habitat: habitat,
    description: description, funFacts: funFacts, minigame: minigame,
    diet: diet, size: size,
    isDiscovered: isDiscovered ?? this.isDiscovered,
    sound: sound, spriteAsset: spriteAsset, wikiFact: wikiFact,
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
    for (final a in all) { if (a.id == id) return a; }
    for (final a in basicPack) { if (a.id == id) return a; }
    return null;
  }

  // ── Basic Asset Pack (Kanto map) ────────────────────────────────────────
  // 15 animales con spritesheet 64x16 (4 frames de 16x16) — `assets/images/animals_basic/*.png`
  static const List<AnimalData> basicPack = [
    AnimalData(
      id: 'chicken', name: 'Gallina', emoji: '🐔', habitat: 'Granja',
      description: 'La gallina es un ave doméstica descendiente del ave roja de la jungla.',
      funFacts: [
        'Pueden reconocer más de 100 caras distintas',
        'Se comunican con más de 30 sonidos diferentes',
      ],
      minigame: MinigameType.memoryCards,
      diet: 'Omnívoro', size: '40–50 cm',
      sound: '¡Cluck, cluck, cluck!',
      spriteAsset: 'animals_basic/cluckingchicken.png',
      wikiFact: 'Gallus gallus domesticus es una de las aves más numerosas del planeta, con más de 25.000 millones de ejemplares según Wikipedia.',
    ),
    AnimalData(
      id: 'crab', name: 'Cangrejo', emoji: '🦀', habitat: 'Costa',
      description: 'El cangrejo es un crustáceo decápodo con un exoesqueleto duro.',
      funFacts: ['Camina de lado', 'Puede regenerar sus pinzas'],
      minigame: MinigameType.puzzle,
      diet: 'Omnívoro', size: '5–30 cm',
      sound: '¡Click, click!',
      spriteAsset: 'animals_basic/coralcrab.png',
      wikiFact: 'Según Wikipedia, existen más de 6.700 especies de cangrejos y la mayoría se alimentan filtrando detritos del agua.',
    ),
    AnimalData(
      id: 'toad', name: 'Sapo', emoji: '🐸', habitat: 'Charca',
      description: 'Los sapos son anfibios de piel rugosa que viven en zonas húmedas.',
      funFacts: ['Respiran por la piel', 'Pueden vivir más de 30 años'],
      minigame: MinigameType.soundMatch,
      diet: 'Insectívoro', size: '8–15 cm',
      sound: '¡Croooak, croooak!',
      spriteAsset: 'animals_basic/croakingtoad.png',
      wikiFact: 'Wikipedia indica que los sapos verdaderos (familia Bufonidae) segregan toxinas por glándulas parótidas para defenderse.',
    ),
    AnimalData(
      id: 'pig', name: 'Cerdo', emoji: '🐷', habitat: 'Granja',
      description: 'Mamífero inteligente, social y uno de los animales domesticados más antiguos.',
      funFacts: ['Tienen una memoria excelente', 'Se enfrían revolcándose en barro'],
      minigame: MinigameType.trivia,
      diet: 'Omnívoro', size: '60–90 cm',
      sound: '¡Oink, oink!',
      spriteAsset: 'animals_basic/daintypig.png',
      wikiFact: 'Wikipedia: Sus scrofa domesticus fue domesticado hace unos 9.000 años y está considerado uno de los mamíferos más inteligentes.',
    ),
    AnimalData(
      id: 'goose', name: 'Ganso', emoji: '🪿', habitat: 'Lago',
      description: 'Aves acuáticas que forman vínculos de pareja duraderos.',
      funFacts: ['Vuelan en formación V', 'Son muy territoriales'],
      minigame: MinigameType.colorMatch,
      diet: 'Herbívoro', size: '70–90 cm',
      sound: '¡Honk, honk!',
      spriteAsset: 'animals_basic/honkinggoose.png',
      wikiFact: 'Según Wikipedia, los gansos migran miles de kilómetros y usan el campo magnético terrestre para orientarse.',
    ),
    AnimalData(
      id: 'green_frog', name: 'Rana', emoji: '🐸', habitat: 'Río',
      description: 'Las ranas son anfibios saltarines con patas traseras muy potentes.',
      funFacts: ['Pueden saltar 20 veces su longitud', 'Parpadean para tragar'],
      minigame: MinigameType.silhouette,
      diet: 'Insectívoro', size: '2–10 cm',
      sound: '¡Ribbit, ribbit!',
      spriteAsset: 'animals_basic/leapingfrog.png',
      wikiFact: 'Wikipedia: las ranas existen desde hace más de 200 millones de años y hay más de 7.000 especies descritas.',
    ),
    AnimalData(
      id: 'boar', name: 'Jabalí', emoji: '🐗', habitat: 'Bosque',
      description: 'Mamífero robusto y salvaje, antepasado del cerdo doméstico.',
      funFacts: ['Puede correr a 40 km/h', 'Tiene un olfato excelente'],
      minigame: MinigameType.taming,
      diet: 'Omnívoro', size: '90–110 cm',
      sound: '¡Grrrunt, grrrunt!',
      spriteAsset: 'animals_basic/madboar.png',
      wikiFact: 'Wikipedia: Sus scrofa está presente en casi todos los continentes y puede ser invasor fuera de su rango natural.',
    ),
    AnimalData(
      id: 'cat', name: 'Gato', emoji: '🐈', habitat: 'Pueblo',
      description: 'Pequeño felino doméstico, compañero humano desde hace milenios.',
      funFacts: ['Duerme unas 16 horas al día', 'Ronronea a ~25 Hz'],
      minigame: MinigameType.memoryCards,
      diet: 'Carnívoro', size: '25–30 cm',
      sound: '¡Miau, miau!',
      spriteAsset: 'animals_basic/meowingcat.png',
      wikiFact: 'Según Wikipedia, Felis catus fue domesticado en el Creciente Fértil hace más de 9.000 años.',
    ),
    AnimalData(
      id: 'sheep', name: 'Oveja', emoji: '🐑', habitat: 'Pradera',
      description: 'Rumiante lanar domesticado desde hace más de 10.000 años.',
      funFacts: ['Distingue expresiones faciales', 'Puede producir hasta 30 kg de lana al año'],
      minigame: MinigameType.trivia,
      diet: 'Herbívoro', size: '60–100 cm',
      sound: '¡Beee, beee!',
      spriteAsset: 'animals_basic/pasturingsheep.png',
      wikiFact: 'Wikipedia: Ovis aries se cría en todos los continentes habitados y es la base de la ganadería lanar mundial.',
    ),
    AnimalData(
      id: 'turtle', name: 'Tortuga', emoji: '🐢', habitat: 'Estanque',
      description: 'Reptil con caparazón óseo protector; existen especies terrestres y acuáticas.',
      funFacts: ['Pueden vivir más de 100 años', 'Su caparazón está hecho de huesos'],
      minigame: MinigameType.puzzle,
      diet: 'Omnívoro', size: '15–40 cm',
      sound: '¡Ssshhh...!',
      spriteAsset: 'animals_basic/slowturtle.png',
      wikiFact: 'Wikipedia: las tortugas aparecieron hace más de 220 millones de años, antes que los lagartos y cocodrilos.',
    ),
    AnimalData(
      id: 'snow_fox', name: 'Zorro Ártico', emoji: '🦊', habitat: 'Ártico',
      description: 'Pequeño cánido con un grueso pelaje blanco que lo aísla del frío polar.',
      funFacts: ['Resiste temperaturas de -50 °C', 'Cambia de color según la estación'],
      minigame: MinigameType.taming,
      diet: 'Carnívoro', size: '45–70 cm',
      sound: '¡Yip, yip!',
      spriteAsset: 'animals_basic/snowfox.png',
      wikiFact: 'Wikipedia: Vulpes lagopus habita la tundra ártica y puede detectar lemmings bajo la nieve solo con el oído.',
    ),
    AnimalData(
      id: 'porcupine', name: 'Puercoespín', emoji: '🦔', habitat: 'Bosque',
      description: 'Roedor con púas afiladas como defensa contra depredadores.',
      funFacts: ['Tiene más de 30.000 púas', 'Sus púas no se disparan, se sueltan al contacto'],
      minigame: MinigameType.silhouette,
      diet: 'Herbívoro', size: '60–90 cm',
      sound: '¡Chuff, chuff!',
      spriteAsset: 'animals_basic/spikeyporcupine.png',
      wikiFact: 'Wikipedia: los puercoespines son los terceros roedores más grandes del mundo, tras el capibara y el castor.',
    ),
    AnimalData(
      id: 'skunk', name: 'Mofeta', emoji: '🦨', habitat: 'Bosque',
      description: 'Mamífero con glándulas que segregan un líquido muy maloliente.',
      funFacts: ['Su olor se detecta a 1 km', 'Avisa antes de rociar'],
      minigame: MinigameType.soundMatch,
      diet: 'Omnívoro', size: '40–70 cm',
      sound: '¡Fsss, fsss!',
      spriteAsset: 'animals_basic/stinkyskunk.png',
      wikiFact: 'Wikipedia: la mofeta puede rociar su líquido defensivo hasta 3 metros con gran precisión.',
    ),
    AnimalData(
      id: 'wolf', name: 'Lobo', emoji: '🐺', habitat: 'Bosque',
      description: 'Cánido social que vive en manadas y es antepasado del perro doméstico.',
      funFacts: ['Aúlla para comunicarse a distancia', 'Una manada recorre hasta 50 km al día'],
      minigame: MinigameType.trivia,
      diet: 'Carnívoro', size: '70–90 cm',
      sound: '¡Auuuuuu!',
      spriteAsset: 'animals_basic/timberwolf.png',
      wikiFact: 'Wikipedia: Canis lupus es el cánido silvestre más grande y base genética de todas las razas de perro.',
    ),
    AnimalData(
      id: 'chick', name: 'Pollito', emoji: '🐥', habitat: 'Granja',
      description: 'La cría de la gallina, cubierta de plumón suave y amarillo.',
      funFacts: ['Pía para llamar a su madre', 'Se orienta por el sonido desde el huevo'],
      minigame: MinigameType.colorMatch,
      diet: 'Omnívoro', size: '5–10 cm',
      sound: '¡Pío, pío!',
      spriteAsset: 'animals_basic/tinychick.png',
      wikiFact: 'Wikipedia: los pollitos empiezan a comunicarse con la gallina antes incluso de romper el cascarón.',
    ),
  ];
}
