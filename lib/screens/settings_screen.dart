// lib/screens/settings_screen.dart
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
  late AnimationController _fadeCtrl;
  late Animation<double> _fade;

  static const _qualityOptions = ['Baja', 'Media', 'Alta', 'Ultra'];
  int _qualityIdx = 2;

  static const _languages = ['Español', 'English', 'Français', 'Deutsch'];
  int _langIdx = 0;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 380))
      ..forward();
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _langIdx = _languages.indexOf(_gs.language).clamp(0, _languages.length - 1);
  }

  @override
  void dispose() { _fadeCtrl.dispose(); super.dispose(); }

  void _confirmReset() {
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF1A1A4A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('⚠️ Borrar progreso',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
      content: const Text(
          'Esto eliminará TODOS tus animales, monedas y nivel. ¿Estás seguro?',
          style: TextStyle(color: Colors.white70, fontSize: 13)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar',
              style: TextStyle(color: Colors.white54)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.badgeRed),
          onPressed: () {
            _gs.reset();
            Navigator.pop(context);
            Navigator.of(context)
                .pushNamedAndRemoveUntil('/', (_) => false);
          },
          child: const Text('Borrar Todo'),
        ),
      ],
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
                  Color(0xFF0D0D2E), Color(0xFF1A1A4A), Color(0xFF0D0D2E)],
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left column
                  Expanded(child: Column(children: [
                    _sectionCard('Audio', [
                      _toggleRow('♪', 'Música', 'Tema del bosque',
                          _gs.musicOn,
                          (v) => setState(() => _gs.musicOn = v)),
                      _toggleRow('🔉', 'Efectos de sonido', '',
                          _gs.sfxOn,
                          (v) => setState(() => _gs.sfxOn = v)),
                      _sliderRow('🎚', 'Volumen música',
                          _gs.musicVol,
                          (v) => setState(() => _gs.musicVol = v)),
                    ]),
                    const SizedBox(height: 8),
                    _sectionCard('Controles', [
                      _toggleRow('🕹', 'Joystick virtual', '',
                          _gs.joystickOn,
                          (v) => setState(() => _gs.joystickOn = v)),
                      _toggleRow('📳', 'Vibración', '',
                          _gs.vibrationOn,
                          (v) {
                            setState(() => _gs.vibrationOn = v);
                            if (v) HapticFeedback.mediumImpact();
                          }),
                      _sliderRow('☝', 'Sensibilidad',
                          _gs.sensitivity,
                          (v) => setState(() => _gs.sensitivity = v)),
                    ]),
                  ])),
                  const SizedBox(width: 8),
                  // Right column
                  Expanded(child: Column(children: [
                    _sectionCard('Pantalla', [
                      _selectRow('✨', 'Calidad gráfica',
                          _qualityOptions[_qualityIdx], () {
                        setState(() =>
                            _qualityIdx = (_qualityIdx + 1) % _qualityOptions.length);
                      }),
                      _toggleRow('🌙', 'Modo nocturno', '',
                          _gs.nightMode,
                          (v) => setState(() => _gs.nightMode = v)),
                      _sliderRow('🔆', 'Brillo HUD',
                          _gs.hudBrightness,
                          (v) => setState(() => _gs.hudBrightness = v)),
                    ]),
                    const SizedBox(height: 8),
                    _sectionCard('Cuenta', [
                      _selectRow('🌐', 'Idioma',
                          _languages[_langIdx], () {
                        setState(() {
                          _langIdx = (_langIdx + 1) % _languages.length;
                          _gs.language = _languages[_langIdx];
                        });
                      }),
                      _toggleRow('☁️', 'Guardar en nube', '',
                          _gs.cloudSave,
                          (v) => setState(() => _gs.cloudSave = v)),
                      _actionRow('↩', 'Cerrar sesión', 'Volver a inicio', () async {
                        await AuthService.logout();
                        if (!mounted) return;
                        Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
                      }),
                      _dangerRow('🗑️', 'Borrar progreso',
                          'Acción irreversible', _confirmReset),
                    ]),
                    const SizedBox(height: 8),
                    // Version info card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.07)),
                      ),
                      child: Column(children: [
                        const Text('AnimalGO!',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 13)),
                        const SizedBox(height: 3),
                        Text('Versión 1.0.0',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 10)),
                        Text('Flutter + Bonfire 3.16',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.3),
                                fontSize: 9)),
                      ]),
                    ),
                  ])),
                ],
              ),
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
            const Text('⚙️  Ajustes',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 17)),
          ]),
        ),
      );

  Widget _sectionCard(String title, List<Widget> rows) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: Colors.white.withOpacity(0.08), width: 1),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Text(title,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5)),
          const SizedBox(height: 6),
          ...rows,
        ]),
      );

  Widget _divider() => Divider(
      height: 1,
      color: Colors.white.withOpacity(0.06),
      thickness: 1);

  Widget _toggleRow(String icon, String label, String sub, bool val,
      ValueChanged<bool> onChange) =>
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 11.5)),
            if (sub.isNotEmpty)
              Text(sub,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 9)),
          ],
        )),
        _Toggle(value: val, onChanged: onChange),
      ]),
    );

  Widget _sliderRow(String icon, String label, double val,
      ValueChanged<double> onChange) =>
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Expanded(child: Text(label,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 11.5))),
        SizedBox(
          width: 80,
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
              activeTrackColor: AppColors.greenAccent,
              inactiveTrackColor: Colors.white.withOpacity(0.15),
              thumbColor: AppColors.greenAccent,
              overlayColor: AppColors.greenAccent.withOpacity(0.2),
            ),
            child: Slider(
              value: val,
              onChanged: onChange,
              min: 0, max: 1,
            ),
          ),
        ),
      ]),
    );

  Widget _selectRow(String icon, String label, String current,
      VoidCallback onTap) =>
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 11.5)),
            Text(current,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.45),
                    fontSize: 9)),
          ],
        )),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: Colors.white.withOpacity(0.15), width: 1),
            ),
            child: const Text('Cambiar',
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700)),
          ),
        ),
      ]),
    );

  Widget _actionRow(String icon, String label, String sub,
      VoidCallback onTap) =>
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 11.5)),
            Text(sub,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.45),
                    fontSize: 9)),
          ],
        )),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: Colors.white.withOpacity(0.15), width: 1),
            ),
            child: const Text('Salir',
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700)),
          ),
        ),
      ]),
    );

  Widget _dangerRow(String icon, String label, String sub,
      VoidCallback onTap) =>
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 11.5)),
            Text(sub,
                style: const TextStyle(
                    color: Color(0xFFFF6B6B), fontSize: 9)),
          ],
        )),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.badgeRed.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: AppColors.badgeRed.withOpacity(0.4), width: 1),
            ),
            child: const Text('Borrar',
                style: TextStyle(
                    color: Color(0xFFFF6B6B),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700)),
          ),
        ),
      ]),
    );
}

// Custom toggle widget
class _Toggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _Toggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 38, height: 22,
        decoration: BoxDecoration(
          color: value
              ? AppColors.greenAccent
              : Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(11),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: 16, height: 16,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}


