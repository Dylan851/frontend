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
                            EdgeInsets.fromLTRB(10 * s, 6 * s, 10 * s, 8 * s),
                        child: Column(
                          children: [
                            _header(s),
                            SizedBox(height: 6 * s),
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
                                        SizedBox(height: 6 * s),
                                        _toggleRow(
                                          s: s,
                                          icon: Icons.volume_up_rounded,
                                          iconColor: const Color(0xFF66D4FF),
                                          label: 'Efectos de sonido',
                                          value: _gs.sfxOn,
                                          onChanged: (v) =>
                                              setState(() => _gs.sfxOn = v),
                                        ),
                                        SizedBox(height: 6 * s),
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
                                    SizedBox(height: 9 * s),
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
                                        SizedBox(height: 6 * s),
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
                                        SizedBox(height: 6 * s),
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
                            SizedBox(height: 7 * s),
                            Row(
                              children: [
                                Expanded(child: _logoutButton(s, compact)),
                                SizedBox(width: 8 * s),
                                Expanded(child: _deleteAccountButton(s, compact)),
                              ],
                            ),
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
                fontSize: 23 * s,
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
      padding: EdgeInsets.fromLTRB(15 * s, 10 * s, 15 * s, 10 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 20 * s, vertical: 4 * s),
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
                  fontSize: 18 * s,
                ),
              ),
            ),
          ),
          SizedBox(height: 9 * s),
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: GameTone.textCream,
              fontWeight: FontWeight.w900,
              fontSize: 18 * s,
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: GameTone.textCream,
              fontWeight: FontWeight.w900,
              fontSize: 18 * s,
            ),
          ),
        ),
        SizedBox(
          width: compact ? 140 * s : 220 * s,
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

  Future<void> _confirmAndDeleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2C1A0E),
        title: const Text('Eliminar cuenta',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
        content: const Text(
          'Esta acción borrará tu cuenta y todo el progreso. No se puede deshacer.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB23A30)),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await AuthService.deleteAccount();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Cuenta eliminada.'),
    ));
    Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
  }

  Widget _deleteAccountButton(double s, bool compact) {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: _confirmAndDeleteAccount,
        child: PixelFrame(
          radius: 12 * s,
          innerFill: const Color(0xFF3A0E0E),
          padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 11 * s),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Eliminar cuenta',
                style: TextStyle(
                  color: const Color(0xFFFFC5BD),
                  fontWeight: FontWeight.w900,
                  fontSize: 18 * s,
                ),
              ),
              SizedBox(height: 2 * s),
              Text(
                'Acción permanente',
                style: TextStyle(
                  color: const Color(0xFFFFB4A9),
                  fontWeight: FontWeight.w700,
                  fontSize: 13 * s,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _logoutButton(double s, bool compact) {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: () async {
          await AuthService.logout();
          if (!mounted) return;
          Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
        },
        child: PixelFrame(
          radius: 12 * s,
          innerFill: const Color(0xFF2C1A0E),
          padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 11 * s),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Cerrar sesión',
                style: TextStyle(
                  color: GameTone.textCream,
                  fontWeight: FontWeight.w900,
                  fontSize: 20 * s,
                ),
              ),
              SizedBox(height: 2 * s),
              Text(
                'Volver a inicio',
                style: TextStyle(
                  color: GameTone.textGold,
                  fontWeight: FontWeight.w700,
                  fontSize: 14 * s,
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
