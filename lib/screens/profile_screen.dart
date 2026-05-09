// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import '../data/game_state.dart';
import '../data/animal_data.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final _gs = GameState();
  late AnimationController _fadeCtrl;
  late Animation<double> _fade;
  int _factsPage = 0;

  static const _achievements = [
    ('first_animal', '\u{1F43E}', 'Primer Animal', 'Descubre tu primer animal'),
    ('first_items', '\u{1F4E6}', 'Recolector', 'Recoge 5 ítems'),
    (
      'first_minigame',
      '\u{1F3AE}',
      'Primer Minijuego',
      'Completa un minijuego'
    ),
    (
      'all_animals',
      '\u{1F31F}',
      'Maestro Animal',
      'Descubre todos los animales'
    ),
    (
      'complete_map',
      '\u{1F5FA}\u{FE0F}',
      'Mapa Completo',
      'Completa un mapa entero'
    ),
    ('level20', '\u{1F3C6}', 'Veterano', 'Llega al nivel 20'),
    ('coins100', '\u{1F48E}', 'Coleccionista', 'Acumula 100 gemas'),
    ('master', '\u{1F451}', 'Maestro', 'Logra todos los logros'),
  ];

  static const _ranks = [
    (1, '\u{1F331}', 'Novato'),
    (5, '\u{1F33F}', 'Rastreador'),
    (10, '\u{1F332}', 'Explorador'),
    (20, '\u{1F985}', 'Guardabosques'),
    (35, '\u{1F3C6}', 'Maestro'),
  ];

  String get _rankEmoji {
    String emoji = '\u{1F331}';
    for (final r in _ranks) {
      if (_gs.level >= r.$1) emoji = r.$2;
    }
    return emoji;
  }

  String get _rankName {
    String name = 'Novato';
    for (final r in _ranks) {
      if (_gs.level >= r.$1) name = r.$3;
    }
    return name;
  }

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400))
      ..forward();
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _editName() {
    final ctrl = TextEditingController(text: _gs.playerName);
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              backgroundColor: const Color(0xFF1B4A2E),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: const Text('Cambiar nombre',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w800)),
              content: TextField(
                controller: ctrl,
                style: const TextStyle(color: Colors.white),
                maxLength: 16,
                decoration: InputDecoration(
                  hintText: 'Tu nombre...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.greenAccent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: AppColors.greenAccent, width: 2),
                  ),
                  counterStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancelar',
                      style: TextStyle(color: Colors.white.withOpacity(0.6))),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (ctrl.text.trim().isNotEmpty) {
                      setState(() => _gs.playerName = ctrl.text.trim());
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Guardar'),
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1A10),
      body: FadeTransition(
        opacity: _fade,
        child: MenuBackdrop(
          dim: 0.55,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final s =
                  AppResponsive.scaleForWidth(width, min: 0.68, max: 1.02);
              return Stack(children: [
                Column(children: [
                  _topBar(s),
                  Expanded(
                      child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(12 * s, 4 * s, 12 * s, 12 * s),
                    child: Column(children: [
                      _heroCard(width, s),
                      SizedBox(height: 10 * s),
                      _statsGrid(width, s),
                      SizedBox(height: 10 * s),
                      _achievementsSection(width, s),
                    ]),
                  )),
                ]),
              ]);
            },
          ),
        ),
      ),
    );
  }

  Widget _topBar(double s) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(12 * s, 10 * s, 12 * s, 4 * s),
          child: Column(children: [
            const Row(children: [BackBtn(), Spacer()]),
            SizedBox(height: 8 * s),
            const OrnateTitle(
              eyebrow: 'TU TRAVESIA',
              text: 'PERFIL',
            ),
          ]),
        ),
      );

  Widget _heroCard(double width, double s) {
    final compact = width < 900;
    final avatarSize = compact ? 64 * s : 78 * s;
    final rankFont = compact ? 24 * s : 30 * s;
    final info = Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Flexible(
              child: Text(_gs.playerName.toUpperCase(),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: AppColors.parchment,
                      fontWeight: FontWeight.w900,
                      fontSize: (compact ? 14 : 17) * s,
                      letterSpacing: 1.6)),
            ),
            SizedBox(width: 6 * s),
            GestureDetector(
              onTap: _editName,
              child: Container(
                padding: EdgeInsets.all(4 * s),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6 * s),
                ),
                child: Text('\u270F\uFE0F', style: TextStyle(fontSize: 11 * s)),
              ),
            ),
          ]),
          SizedBox(height: 3 * s),
          Text('Miembro desde Enero 2025 · ${_mapName()}',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.55), fontSize: 11 * s)),
          SizedBox(height: 7 * s),
          Row(children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6 * s),
                child: LinearProgressIndicator(
                  value: _gs.xpPercent,
                  minHeight: 8 * s,
                  backgroundColor: Colors.white.withOpacity(0.12),
                  valueColor:
                      const AlwaysStoppedAnimation(AppColors.greenAccent),
                ),
              ),
            ),
            SizedBox(width: 8 * s),
            Text('${_gs.currentXp}/${_gs.maxXp} XP',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.5), fontSize: 10 * s)),
          ]),
        ],
      ),
    );
    final rank = Column(children: [
      Text(_rankEmoji, style: TextStyle(fontSize: rankFont)),
      SizedBox(height: 3 * s),
      Text(_rankName.toUpperCase(),
          style: TextStyle(
              color: AppColors.amber,
              fontWeight: FontWeight.w900,
              fontSize: 10 * s,
              letterSpacing: 1.2)),
    ]);

    return WoodPanel(
      padding: EdgeInsets.all(16 * s),
      child: compact
          ? Column(
              children: [
                Row(children: [
                  _avatar(avatarSize, s),
                  SizedBox(width: 12 * s),
                  info,
                ]),
                SizedBox(height: 10 * s),
                rank,
              ],
            )
          : Row(children: [
              // Avatar
              _avatar(avatarSize, s),
              SizedBox(width: 14 * s),
              info,
              SizedBox(width: 12 * s),
              rank,
            ]),
    );
  }

  Widget _avatar(double size, double s) {
    final url = _gs.googlePhotoUrl;
    final hasPhoto = url != null && url.isNotEmpty;
    return Stack(children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
                colors: [AppColors.amber, AppColors.amberDeep]),
            border: Border.all(color: AppColors.parchment, width: 3 * s),
            boxShadow: [
              BoxShadow(
                  color: AppColors.amber.withOpacity(0.4), blurRadius: 14 * s),
            ],
          ),
          child: hasPhoto
              ? ClipOval(
                  child: Image.network(
                    url,
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Center(
                      child: Text(_gs.selectedSkin,
                          style: TextStyle(fontSize: 38 * s)),
                    ),
                  ),
                )
              : Center(
                  child: Text(_gs.selectedSkin,
                      style: TextStyle(fontSize: 38 * s)),
                ),
        ),
        Positioned(
          bottom: -2 * s,
          right: -2 * s,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 6 * s, vertical: 2 * s),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [AppColors.emeraldGlow, AppColors.emerald]),
              borderRadius: BorderRadius.circular(8 * s),
              border: Border.all(color: AppColors.parchment, width: 2 * s),
            ),
            child: Text('LV ${_gs.level}',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 9 * s,
                    letterSpacing: 1.0)),
          ),
        ),
      ]);
  }

  String _mapName() {
    try {
      return [
        'Aldea Canta',
        'Sabana Africana',
        'Granja Rural',
        'Fondo Oceánico',
        'Ártico Polar',
      ][0];
    } catch (_) {
      return 'Aldea Canta';
    }
  }

  Widget _statsGrid(double width, double s) => GridView.count(
        crossAxisCount: AppResponsive.adaptiveColumns(
          width,
          minColumns: 1,
          maxColumns: 4,
          itemWidth: width < 850 ? 180 : 150,
        ),
        shrinkWrap: true,
        crossAxisSpacing: 8 * s,
        mainAxisSpacing: 8 * s,
        childAspectRatio: 1.6,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _statCard('${_gs.discoveredCount}/${AnimalCatalog.all.length}',
              '\u{1F43E} Animales'),
          _statCard('${_gs.completedMinigames.length}', '\u{1F3AE} Minijuegos'),
          _statCard('${_gs.coins}', '\u{1FA99} Monedas'),
          _statCard('${_gs.score}', '\u2B50 Puntos'),
        ],
      );

  Widget _statCard(String val, String label) => Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF143421), Color(0xFF0A1F12)],
          ),
          borderRadius: BorderRadius.circular(14),
          border:
              Border.all(color: AppColors.amber.withOpacity(0.35), width: 1.4),
          boxShadow: [
            BoxShadow(
              color: AppColors.leafShadow.withOpacity(0.45),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(val,
                style: const TextStyle(
                    color: AppColors.parchment,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    letterSpacing: 0.6)),
            const SizedBox(height: 3),
            Text(label.toUpperCase(),
                style: TextStyle(
                    color: AppColors.amber.withOpacity(0.85),
                    fontSize: 7.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8),
                textAlign: TextAlign.center),
          ],
        ),
      );

  Widget _achievementsSection(double width, double s) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const OrnateTitle(
            eyebrow: 'TU TRAVESIA',
            text: 'LOGROS',
          ),
          SizedBox(height: 10 * s),
          GridView.count(
            crossAxisCount: AppResponsive.adaptiveColumns(
              width,
              minColumns: 1,
              maxColumns: 4,
              itemWidth: width < 850 ? 160 : 120,
            ),
            shrinkWrap: true,
            crossAxisSpacing: 8 * s,
            mainAxisSpacing: 8 * s,
            childAspectRatio: 1.15,
            physics: const NeverScrollableScrollPhysics(),
            children: _achievements.map((a) {
              final earned = _gs.hasAchievement(a.$1);
              return GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('${a.$3}: ${a.$4}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, color: Colors.white)),
                    backgroundColor:
                        earned ? AppColors.greenDeep : Colors.grey.shade800,
                    duration: const Duration(milliseconds: 1600),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.all(12),
                  ));
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: earned
                          ? [const Color(0xFF1F4A2C), const Color(0xFF0E2914)]
                          : [const Color(0xFF0F2418), const Color(0xFF071A0F)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: earned
                          ? AppColors.amber.withOpacity(0.7)
                          : AppColors.amber.withOpacity(0.12),
                      width: earned ? 1.8 : 1,
                    ),
                    boxShadow: earned
                        ? [
                            BoxShadow(
                                color: AppColors.amber.withOpacity(0.25),
                                blurRadius: 10)
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(a.$2,
                          style: TextStyle(
                              fontSize: 18,
                              color: earned
                                  ? null
                                  : Colors.white.withOpacity(0.2))),
                      const SizedBox(height: 4),
                      Text(a.$3.toUpperCase(),
                          style: TextStyle(
                              color: earned
                                  ? AppColors.parchment
                                  : AppColors.parchment.withOpacity(0.3),
                              fontSize: 7,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8),
                          textAlign: TextAlign.center,
                          maxLines: 2),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      );
}
