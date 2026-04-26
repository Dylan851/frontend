// lib/screens/missions_screen.dart
import 'package:flutter/material.dart';
import '../data/game_state.dart';
import '../data/mission_data.dart';
import '../theme/app_theme.dart';

class MissionsScreen extends StatefulWidget {
  const MissionsScreen({super.key});
  @override
  State<MissionsScreen> createState() => _MissionsScreenState();
}

class _MissionsScreenState extends State<MissionsScreen>
    with SingleTickerProviderStateMixin {
  final _gs = GameState();
  late final AnimationController _fadeCtrl;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400))..forward();
  }

  @override
  void dispose() { _fadeCtrl.dispose(); super.dispose(); }

  void _claim(Mission m) {
    final ok = _gs.claimMission(m.id,
        coins: m.rewardCoins, gems: m.rewardGems, xp: m.rewardXp);
    if (ok) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: GameTone.leafDeep,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(milliseconds: 1800),
        content: Text(
          '🎉 Recompensa: '
          '${m.rewardCoins > 0 ? "+${m.rewardCoins}🪙 " : ""}'
          '${m.rewardGems > 0 ? "+${m.rewardGems}💎 " : ""}'
          '${m.rewardXp > 0 ? "+${m.rewardXp}XP" : ""}'.trim(),
          style: const TextStyle(
              color: GameTone.textCream,
              fontWeight: FontWeight.w800),
        ),
      ));
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final all = MissionCatalog.all;
    final claimable = all.where((m) => m.isClaimable(_gs)).toList();
    final inProgress = all.where((m) => !m.isComplete(_gs)).toList();
    final claimed = all.where((m) => m.isClaimed(_gs)).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0A1A10),
      body: FadeTransition(
        opacity: _fadeCtrl,
        child: MenuBackdrop(
          dim: 0.55,
          child: SafeArea(
            child: Column(children: [
              GameHeader(
                title: 'Misiones',
                trailing: [
                  OvalGoldChip(icon: '🪙', value: '${_gs.coins}'),
                  OvalGoldChip(icon: '💎', value: '${_gs.gems}'),
                ],
              ),
              // Summary chip
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: SizedBox(
                  width: double.infinity,
                  child: PixelFrame(
                    radius: 12,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    child: Row(children: [
                      _summary('✅', '${claimed.length}', 'Reclamadas'),
                      _vDivider(),
                      _summary('🎁', '${claimable.length}', 'Listas'),
                      _vDivider(),
                      _summary('⏳', '${inProgress.length}', 'En progreso'),
                      _vDivider(),
                      _summary('🌟', '${all.length}', 'Total'),
                    ]),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // List
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                  children: [
                    if (claimable.isNotEmpty) ...[
                      _section('🎁  RECOMPENSAS DISPONIBLES'),
                      ...claimable.map((m) => _missionTile(m, highlight: true)),
                      const SizedBox(height: 8),
                    ],
                    if (inProgress.isNotEmpty) ...[
                      _section('⏳  EN PROGRESO'),
                      ...inProgress.map((m) => _missionTile(m)),
                      const SizedBox(height: 8),
                    ],
                    if (claimed.isNotEmpty) ...[
                      _section('✅  COMPLETADAS'),
                      ...claimed.map((m) => _missionTile(m, completed: true)),
                    ],
                  ],
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _summary(String icon, String val, String label) => Expanded(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text(icon, style: const TextStyle(fontSize: 16)),
      const SizedBox(height: 2),
      Text(val,
          style: const TextStyle(
            color: GameTone.textCream,
            fontWeight: FontWeight.w900,
            fontSize: 16,
          )),
      Text(label,
          style: TextStyle(
            color: GameTone.textGold.withOpacity(0.85),
            fontWeight: FontWeight.w700,
            fontSize: 9,
            letterSpacing: 0.6,
          )),
    ]),
  );

  Widget _vDivider() => Container(
    width: 1, height: 36,
    color: GameTone.goldTrim.withOpacity(0.3),
  );

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 6, 4, 6),
    child: Text(title,
        style: const TextStyle(
          color: GameTone.textGold,
          fontWeight: FontWeight.w900,
          fontSize: 11,
          letterSpacing: 1.6,
        )),
  );

  Widget _missionTile(Mission m, {bool highlight = false, bool completed = false}) {
    final pct = m.pct(_gs);
    final progress = m.progress(_gs);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: PixelFrame(
        radius: 12,
        innerFill: completed
            ? const Color(0xFF152213)
            : (highlight ? const Color(0xFF1F3A1F) : GameTone.panelDark),
        padding: const EdgeInsets.all(10),
        child: Row(children: [
          // Icon badge
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: completed
                  ? [const Color(0xFF6E885A), const Color(0xFF34532A)]
                  : highlight
                      ? [const Color(0xFFFFE48A), const Color(0xFFB07A2A)]
                      : [const Color(0xFF6BBA5B), const Color(0xFF1F4E2A)]),
              border: Border.all(color: GameTone.goldTrim, width: 1.4),
            ),
            child: Center(child: Text(m.emoji, style: const TextStyle(fontSize: 26))),
          ),
          const SizedBox(width: 10),
          // Texts + bar
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(m.title,
                  style: TextStyle(
                    color: completed
                        ? GameTone.textCream.withOpacity(0.7)
                        : GameTone.textCream,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    decoration: completed ? TextDecoration.lineThrough : null,
                  )),
              const SizedBox(height: 2),
              Text(m.description,
                  style: TextStyle(
                    color: GameTone.textCream.withOpacity(0.7),
                    fontSize: 10.5,
                    height: 1.3,
                  )),
              const SizedBox(height: 5),
              Row(children: [
                Expanded(child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: GameTone.woodOuter,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: GameTone.goldTrim.withOpacity(0.7), width: 0.8),
                  ),
                  child: FractionallySizedBox(
                    widthFactor: pct,
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: completed
                            ? [const Color(0xFF7DA86A), const Color(0xFF456E3D)]
                            : [const Color(0xFFF6C76B), const Color(0xFFD4A04A)]),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                )),
                const SizedBox(width: 6),
                Text('$progress/${m.target}',
                    style: const TextStyle(
                      color: GameTone.textCream,
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                    )),
              ]),
              const SizedBox(height: 5),
              Row(children: [
                if (m.rewardCoins > 0) _rewardChip('🪙', '${m.rewardCoins}'),
                if (m.rewardGems > 0)  _rewardChip('💎', '${m.rewardGems}'),
                if (m.rewardXp > 0)    _rewardChip('⭐', '${m.rewardXp}'),
              ]),
            ],
          )),
          const SizedBox(width: 8),
          // Action button
          if (completed)
            const Icon(Icons.check_circle_rounded,
                color: Color(0xFF7DA86A), size: 32)
          else if (highlight)
            GestureDetector(
              onTap: () => _claim(m),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Color(0xFF6BBA5B), Color(0xFF1F4E2A)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: GameTone.goldTrim, width: 1.4),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF6BE095).withOpacity(0.4), blurRadius: 12),
                  ],
                ),
                child: const Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.card_giftcard_rounded, color: Colors.white, size: 20),
                  SizedBox(height: 2),
                  Text('COBRAR',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 9,
                        letterSpacing: 0.8,
                      )),
                ]),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: GameTone.woodOuter,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: GameTone.goldTrim.withOpacity(0.6)),
              ),
              child: Text('${(pct * 100).toInt()}%',
                  style: const TextStyle(
                    color: GameTone.textGold,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                  )),
            ),
        ]),
      ),
    );
  }

  Widget _rewardChip(String icon, String val) => Container(
    margin: const EdgeInsets.only(right: 5),
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: GameTone.woodOuter,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: GameTone.goldTrim.withOpacity(0.6), width: 0.8),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Text(icon, style: const TextStyle(fontSize: 10)),
      const SizedBox(width: 3),
      Text(val,
          style: const TextStyle(
            color: GameTone.textGold,
            fontWeight: FontWeight.w900,
            fontSize: 10,
          )),
    ]),
  );
}
