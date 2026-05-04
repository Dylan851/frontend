import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/game_state.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  final _gs = GameState();
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    )..forward();
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fade,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/backgrounds/map_select_bg.png',
                fit: BoxFit.cover,
                filterQuality: FilterQuality.none,
              ),
            ),
            Positioned.fill(
              child: Container(color: const Color(0x55000000)),
            ),
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 980),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                    child: Column(
                      children: [
                        _header(),
                        const SizedBox(height: 8),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                _sectionFrame(
                                  title: 'Audio',
                                  children: [
                                    _toggleRow(
                                      icon: Icons.music_note_rounded,
                                      iconColor: const Color(0xFFF1C94D),
                                      label: 'Música',
                                      value: _gs.musicOn,
                                      onChanged: (v) =>
                                          setState(() => _gs.musicOn = v),
                                    ),
                                    const SizedBox(height: 8),
                                    _toggleRow(
                                      icon: Icons.volume_up_rounded,
                                      iconColor: const Color(0xFF66D4FF),
                                      label: 'Efectos de sonido',
                                      value: _gs.sfxOn,
                                      onChanged: (v) =>
                                          setState(() => _gs.sfxOn = v),
                                    ),
                                    const SizedBox(height: 8),
                                    _sliderRow(
                                      icon: Icons.tune_rounded,
                                      iconColor: const Color(0xFFE9DFC8),
                                      label: 'Volumen música',
                                      value: _gs.musicVol,
                                      onChanged: (v) =>
                                          setState(() => _gs.musicVol = v),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _sectionFrame(
                                  title: 'Controles',
                                  children: [
                                    _toggleRow(
                                      icon: Icons.sports_esports_rounded,
                                      iconColor: const Color(0xFFF1C94D),
                                      label: 'Joystick virtual',
                                      value: _gs.joystickOn,
                                      onChanged: (v) =>
                                          setState(() => _gs.joystickOn = v),
                                    ),
                                    const SizedBox(height: 8),
                                    _toggleRow(
                                      icon: Icons.vibration_rounded,
                                      iconColor: const Color(0xFF66D4FF),
                                      label: 'Vibración',
                                      value: _gs.vibrationOn,
                                      onChanged: (v) {
                                        setState(() => _gs.vibrationOn = v);
                                        if (v) HapticFeedback.mediumImpact();
                                      },
                                    ),
                                    const SizedBox(height: 8),
                                    _sliderRow(
                                      icon: Icons.touch_app_rounded,
                                      iconColor: const Color(0xFFE9DFC8),
                                      label: 'Sensibilidad',
                                      value: _gs.sensitivity,
                                      onChanged: (v) =>
                                          setState(() => _gs.sensitivity = v),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _logoutButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF5A3A16), Color(0xFF2D1B0A)],
              ),
              border: Border.all(color: GameTone.goldTrim, width: 1.6),
            ),
            child: const Icon(
              Icons.arrow_back,
              color: GameTone.textGold,
              size: 30,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: PixelFrame(
            radius: 10,
            innerFill: const Color(0xFF2C1A0E),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: const Text(
              'Ajustes',
              style: TextStyle(
                color: GameTone.textCream,
                fontWeight: FontWeight.w900,
                fontSize: 26,
                shadows: [
                  Shadow(
                    color: Color(0xFF1A0E04),
                    offset: Offset(0, 2),
                    blurRadius: 0,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionFrame({required String title, required List<Widget> children}) {
    return PixelFrame(
      radius: 12,
      innerFill: const Color(0xCC0C2A1E),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 5),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF5A3A16), Color(0xFF2D1B0A)],
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: GameTone.goldTrim, width: 1.4),
              ),
              child: Text(
                title,
                style: const TextStyle(
                  color: GameTone.textCream,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _toggleRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 38,
          child: Icon(icon, size: 30, color: iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: GameTone.textCream,
              fontWeight: FontWeight.w900,
              fontSize: 24,
            ),
          ),
        ),
        _PixelToggle(value: value, onChanged: onChanged),
      ],
    );
  }

  Widget _sliderRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 38,
          child: Icon(icon, size: 30, color: iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: GameTone.textCream,
              fontWeight: FontWeight.w900,
              fontSize: 24,
            ),
          ),
        ),
        SizedBox(
          width: 280,
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 12,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 11),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              activeTrackColor: const Color(0xFF58A53C),
              inactiveTrackColor: const Color(0xFF3B2A17),
              thumbColor: const Color(0xFFD8A33B),
              overlayColor: const Color(0x33D8A33B),
            ),
            child: Slider(value: value, onChanged: onChanged),
          ),
        ),
      ],
    );
  }

  Widget _logoutButton() {
    return SizedBox(
      width: 380,
      child: GestureDetector(
        onTap: () async {
          await AuthService.logout();
          if (!mounted) return;
          Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
        },
        child: PixelFrame(
          radius: 12,
          innerFill: const Color(0xFF2C1A0E),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: const Column(
            children: [
              Text(
                'Cerrar sesión',
                style: TextStyle(
                  color: GameTone.textCream,
                  fontWeight: FontWeight.w900,
                  fontSize: 28,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Volver a inicio',
                style: TextStyle(
                  color: GameTone.textGold,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PixelToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PixelToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 90,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: value
              ? const LinearGradient(colors: [Color(0xFF7AB44D), Color(0xFF4E852E)])
              : const LinearGradient(colors: [Color(0xFF4A4438), Color(0xFF2E2A22)]),
          border: Border.all(color: GameTone.goldTrim, width: 1.5),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 160),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 34,
            height: 34,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE9E5D5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xAA000000), width: 0.8),
            ),
          ),
        ),
      ),
    );
  }
}
