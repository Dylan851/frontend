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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final compact = width < 960;
            final s = AppResponsive.scaleForWidth(width, min: 0.68, max: 1.05);
            return Stack(
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
                      constraints: BoxConstraints(maxWidth: 980 * s + 160),
                      child: Padding(
                        padding:
                            EdgeInsets.fromLTRB(12 * s, 8 * s, 12 * s, 10 * s),
                        child: Column(
                          children: [
                            _header(s),
                            SizedBox(height: 8 * s),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    _sectionFrame(
                                      s: s,
                                      title: 'Audio',
                                      children: [
                                        _toggleRow(
                                          s: s,
                                          icon: Icons.music_note_rounded,
                                          iconColor: const Color(0xFFF1C94D),
                                          label: 'Música',
                                          value: _gs.musicOn,
                                          onChanged: (v) =>
                                              setState(() => _gs.musicOn = v),
                                        ),
                                        SizedBox(height: 8 * s),
                                        _toggleRow(
                                          s: s,
                                          icon: Icons.volume_up_rounded,
                                          iconColor: const Color(0xFF66D4FF),
                                          label: 'Efectos de sonido',
                                          value: _gs.sfxOn,
                                          onChanged: (v) =>
                                              setState(() => _gs.sfxOn = v),
                                        ),
                                        SizedBox(height: 8 * s),
                                        _sliderRow(
                                          s: s,
                                          compact: compact,
                                          icon: Icons.tune_rounded,
                                          iconColor: const Color(0xFFE9DFC8),
                                          label: 'Volumen música',
                                          value: _gs.musicVol,
                                          onChanged: (v) =>
                                              setState(() => _gs.musicVol = v),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 12 * s),
                                    _sectionFrame(
                                      s: s,
                                      title: 'Controles',
                                      children: [
                                        _toggleRow(
                                          s: s,
                                          icon: Icons.sports_esports_rounded,
                                          iconColor: const Color(0xFFF1C94D),
                                          label: 'Joystick virtual',
                                          value: _gs.joystickOn,
                                          onChanged: (v) => setState(
                                              () => _gs.joystickOn = v),
                                        ),
                                        SizedBox(height: 8 * s),
                                        _toggleRow(
                                          s: s,
                                          icon: Icons.vibration_rounded,
                                          iconColor: const Color(0xFF66D4FF),
                                          label: 'Vibración',
                                          value: _gs.vibrationOn,
                                          onChanged: (v) {
                                            setState(() => _gs.vibrationOn = v);
                                            if (v)
                                              HapticFeedback.mediumImpact();
                                          },
                                        ),
                                        SizedBox(height: 8 * s),
                                        _sliderRow(
                                          s: s,
                                          compact: compact,
                                          icon: Icons.touch_app_rounded,
                                          iconColor: const Color(0xFFE9DFC8),
                                          label: 'Sensibilidad',
                                          value: _gs.sensitivity,
                                          onChanged: (v) => setState(
                                              () => _gs.sensitivity = v),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 10 * s),
                            _logoutButton(s, compact),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _header(double s) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: 52 * s,
            height: 52 * s,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10 * s),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF5A3A16), Color(0xFF2D1B0A)],
              ),
              border: Border.all(color: GameTone.goldTrim, width: 1.6 * s),
            ),
            child: Icon(
              Icons.arrow_back,
              color: GameTone.textGold,
              size: 30 * s,
            ),
          ),
        ),
        SizedBox(width: 10 * s),
        Expanded(
          child: PixelFrame(
            radius: 10 * s,
            innerFill: const Color(0xFF2C1A0E),
            padding: EdgeInsets.symmetric(horizontal: 18 * s, vertical: 8 * s),
            child: Text(
              'Ajustes',
              style: TextStyle(
                color: GameTone.textCream,
                fontWeight: FontWeight.w900,
                fontSize: 26 * s,
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

  Widget _sectionFrame({
    required double s,
    required String title,
    required List<Widget> children,
  }) {
    return PixelFrame(
      radius: 12 * s,
      innerFill: const Color(0xCC0C2A1E),
      padding: EdgeInsets.fromLTRB(18 * s, 12 * s, 18 * s, 12 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 24 * s, vertical: 5 * s),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF5A3A16), Color(0xFF2D1B0A)],
                ),
                borderRadius: BorderRadius.circular(10 * s),
                border: Border.all(color: GameTone.goldTrim, width: 1.4 * s),
              ),
              child: Text(
                title,
                style: TextStyle(
                  color: GameTone.textCream,
                  fontWeight: FontWeight.w900,
                  fontSize: 20 * s,
                ),
              ),
            ),
          ),
          SizedBox(height: 12 * s),
          ...children,
        ],
      ),
    );
  }

  Widget _toggleRow({
    required double s,
    required IconData icon,
    required Color iconColor,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 38 * s,
          child: Icon(icon, size: 30 * s, color: iconColor),
        ),
        SizedBox(width: 10 * s),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: GameTone.textCream,
              fontWeight: FontWeight.w900,
              fontSize: 24 * s,
            ),
          ),
        ),
        _PixelToggle(scale: s, value: value, onChanged: onChanged),
      ],
    );
  }

  Widget _sliderRow({
    required double s,
    required bool compact,
    required IconData icon,
    required Color iconColor,
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 38 * s,
          child: Icon(icon, size: 30 * s, color: iconColor),
        ),
        SizedBox(width: 10 * s),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: GameTone.textCream,
              fontWeight: FontWeight.w900,
              fontSize: 24 * s,
            ),
          ),
        ),
        SizedBox(
          width: compact ? 180 * s : 280 * s,
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 12 * s,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 11 * s),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 16 * s),
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

  Widget _logoutButton(double s, bool compact) {
    return SizedBox(
      width: compact ? double.infinity : 380 * s,
      child: GestureDetector(
        onTap: () async {
          await AuthService.logout();
          if (!mounted) return;
          Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
        },
        child: PixelFrame(
          radius: 12 * s,
          innerFill: const Color(0xFF2C1A0E),
          padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 12 * s),
          child: Column(
            children: [
              Text(
                'Cerrar sesión',
                style: TextStyle(
                  color: GameTone.textCream,
                  fontWeight: FontWeight.w900,
                  fontSize: 28 * s,
                ),
              ),
              SizedBox(height: 2 * s),
              Text(
                'Volver a inicio',
                style: TextStyle(
                  color: GameTone.textGold,
                  fontWeight: FontWeight.w700,
                  fontSize: 20 * s,
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
  final double scale;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PixelToggle({
    required this.scale,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 90 * scale,
        height: 44 * scale,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10 * scale),
          gradient: value
              ? const LinearGradient(
                  colors: [Color(0xFF7AB44D), Color(0xFF4E852E)])
              : const LinearGradient(
                  colors: [Color(0xFF4A4438), Color(0xFF2E2A22)]),
          border: Border.all(color: GameTone.goldTrim, width: 1.5 * scale),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 160),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 34 * scale,
            height: 34 * scale,
            margin: EdgeInsets.symmetric(horizontal: 4 * scale),
            decoration: BoxDecoration(
              color: const Color(0xFFE9E5D5),
              borderRadius: BorderRadius.circular(8 * scale),
              border: Border.all(
                  color: const Color(0xAA000000), width: 0.8 * scale),
            ),
          ),
        ),
      ),
    );
  }
}
