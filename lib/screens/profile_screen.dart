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

  // Available skins the user can pick
  static const _skins = [
    '🧑', '👦', '👧', '🧒', '👨‍🔬', '🧙', '👷', '🥷', '🧑‍🚀', '🤠',
  ];

  static const _achievements = [
    ('first_animal',  '🐾', 'Primer Animal',   'Descubre tu primer animal'),
    ('first_items',   '📦', 'Recolector',       'Recoge 5 ítems'),
    ('first_minigame','🎮', 'Primer Minijuego', 'Completa un minijuego'),
    ('all_animals',   '🌟', 'Maestro Animal',   'Descubre todos los animales'),
    ('complete_map',  '🗺️', 'Mapa Completo',    'Completa un mapa entero'),
    ('level20',       '🏆', 'Veterano',         'Llega al nivel 20'),
    ('coins100',      '💎', 'Coleccionista',    'Acumula 100 gemas'),
    ('master',        '👑', 'Maestro',          'Logra todos los logros'),
  ];

  static const _ranks = [
    (1,  '🌱', 'Novato'),
    (5,  '🌿', 'Rastreador'),
    (10, '🌲', 'Explorador'),
    (20, '🦅', 'Guardabosques'),
    (35, '🏆', 'Maestro'),
  ];

  String get _rankEmoji {
    String emoji = '🌱';
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
    _fadeCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 400))
      ..forward();
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() { _fadeCtrl.dispose(); super.dispose(); }

  void _editName() {
    final ctrl = TextEditingController(text: _gs.playerName);
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF1B4A2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Cambiar nombre',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
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

  void _pickSkin() {
    showDialog(context: context, builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF1B4A2E), Color(0xFF0D2B1A)]),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: AppColors.greenAccent.withOpacity(0.3), width: 1.5),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Elige tu personaje',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 16)),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10, runSpacing: 10,
            children: _skins.map((s) => GestureDetector(
              onTap: () {
                setState(() => _gs.selectedSkin = s);
                Navigator.pop(context);
              },
              child: Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: _gs.selectedSkin == s
                      ? AppColors.greenAccent.withOpacity(0.2)
                      : Colors.white.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _gs.selectedSkin == s
                        ? AppColors.greenAccent
                        : Colors.white.withOpacity(0.15),
                    width: _gs.selectedSkin == s ? 2 : 1,
                  ),
                ),
                child: Center(
                    child: Text(s, style: const TextStyle(fontSize: 28))),
              ),
            )).toList(),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar',
                style: TextStyle(color: Colors.white.withOpacity(0.6))),
          ),
        ]),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fade,
        child: Stack(children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0D1A2E), Color(0xFF1A2E4A), Color(0xFF0D1A2E)],
              ),
            ),
          ),
          CustomPaint(
            painter: const HexPatternPainter(),
            size: const Size(double.infinity, double.infinity),
          ),
          Column(children: [
            _topBar(),
            Expanded(child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: Column(children: [
                _heroCard(),
                const SizedBox(height: 10),
                _statsGrid(),
                const SizedBox(height: 10),
                _achievementsSection(),
              ]),
            )),
          ]),
        ]),
      ),
    );
  }

  Widget _topBar() => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(children: [
            BackBtn(),
            const SizedBox(width: 10),
            const Text('👤  Mi Perfil',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 17)),
            const Spacer(),
            CurrencyChip(icon: '🪙', value: '${_gs.coins}'),
            const SizedBox(width: 6),
            CurrencyChip(icon: '💎', value: '${_gs.gems}'),
          ]),
        ),
      );

  Widget _heroCard() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.greenAccent.withOpacity(0.12),
              Colors.white.withOpacity(0.04),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: AppColors.greenAccent.withOpacity(0.3), width: 1.5),
        ),
        child: Row(children: [
          // Avatar
          GestureDetector(
            onTap: _pickSkin,
            child: Stack(children: [
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                      colors: [AppColors.goldDark, Color(0xFFFF5500)]),
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: Center(
                  child: Text(_gs.selectedSkin,
                      style: const TextStyle(fontSize: 38)),
                ),
              ),
              Positioned(
                bottom: -2, right: -2,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.greenAccent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: const Color(0xFF0D2B1A), width: 2),
                  ),
                  child: Text('Nv.${_gs.level}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 9)),
                ),
              ),
            ]),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(_gs.playerName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 19)),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: _editName,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('✏️',
                          style: TextStyle(fontSize: 11)),
                    ),
                  ),
                ]),
                const SizedBox(height: 3),
                Text('Miembro desde Enero 2025 · ${_mapName()}',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.55),
                        fontSize: 11)),
                const SizedBox(height: 7),
                // XP bar
                Row(children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: _gs.xpPercent,
                        minHeight: 8,
                        backgroundColor: Colors.white.withOpacity(0.12),
                        valueColor: const AlwaysStoppedAnimation(
                            AppColors.greenAccent),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${_gs.currentXp}/${_gs.maxXp} XP',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 10)),
                ]),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Rank
          Column(children: [
            Text(_rankEmoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 3),
            Text(_rankName,
                style: const TextStyle(
                    color: AppColors.greenAccent,
                    fontWeight: FontWeight.w900,
                    fontSize: 10)),
          ]),
        ]),
      );

  String _mapName() {
    try {
      return [
        'Aldea Canta', 'Sabana Africana', 'Granja Rural',
        'Fondo Oceánico', 'Ártico Polar',
      ][0];
    } catch (_) {
      return 'Aldea Canta';
    }
  }

  Widget _statsGrid() => GridView.count(
        crossAxisCount: 4,
        shrinkWrap: true,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.3,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _statCard('${_gs.discoveredCount}/${AnimalCatalog.all.length}',
              '🐾 Animales'),
          _statCard('${_gs.completedMinigames.length}',
              '🎮 Minijuegos'),
          _statCard('${_gs.coins}', '🪙 Monedas'),
          _statCard('${_gs.score}', '⭐ Puntos'),
        ],
      );

  Widget _statCard(String val, String label) => Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.09), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(val,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 17)),
            const SizedBox(height: 3),
            Text(label,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.45),
                    fontSize: 8.5),
                textAlign: TextAlign.center),
          ],
        ),
      );

  Widget _achievementsSection() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('LOGROS',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5)),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.0,
            physics: const NeverScrollableScrollPhysics(),
            children: _achievements.map((a) {
              final earned = _gs.hasAchievement(a.$1);
              return GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('${a.$3}: ${a.$4}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                    backgroundColor: earned
                        ? AppColors.greenDeep
                        : Colors.grey.shade800,
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
                    color: earned
                        ? AppColors.gold.withOpacity(0.1)
                        : Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: earned
                          ? AppColors.gold.withOpacity(0.4)
                          : Colors.white.withOpacity(0.12),
                      width: earned ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(a.$2,
                          style: TextStyle(
                              fontSize: 22,
                              color: earned
                                  ? null
                                  : Colors.white.withOpacity(0.2))),
                      const SizedBox(height: 4),
                      Text(a.$3,
                          style: TextStyle(
                              color: earned
                                  ? Colors.white.withOpacity(0.85)
                                  : Colors.white.withOpacity(0.25),
                              fontSize: 8.5,
                              fontWeight: FontWeight.w700),
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
