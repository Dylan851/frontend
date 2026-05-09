import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AuthScaffold extends StatelessWidget {
  final Widget child;
  const AuthScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1A10),
      // resizeToAvoidBottomInset deja que el teclado empuje los campos.
      resizeToAvoidBottomInset: true,
      body: MenuBackdrop(
        dim: 0.5,
        child: SafeArea(child: child),
      ),
    );
  }
}

class AuthPanel extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  const AuthPanel({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;
    // Escala adaptativa: en horizontal compactamos más para no salir de pantalla.
    final shortest = size.shortestSide;
    final base = isLandscape ? 700 : 600;
    final s = (shortest / base).clamp(0.62, 1.05);
    // Ancho máximo: en horizontal limitamos a ~70 % del alto para que quepa
    // siempre sin scroll en pantalla pequeña; en vertical, ancho casi total.
    final maxW = isLandscape
        ? (size.height * 1.25).clamp(360.0, 520.0)
        : (size.width - 16).clamp(280.0, 460.0);
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 12 * s),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxW.toDouble()),
          child: PixelFrame(
            padding: EdgeInsets.fromLTRB(22 * s, 18 * s, 22 * s, 18 * s),
            radius: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    title,
                    style: TextStyle(
                      color: GameTone.textCream,
                      fontWeight: FontWeight.w900,
                      fontSize: (isLandscape ? 22 : 26) * s,
                      shadows: const [
                        Shadow(color: Color(0xFF1A0E04), offset: Offset(0, 2)),
                      ],
                    ),
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  SizedBox(height: 2 * s),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: GameTone.textGold,
                      fontWeight: FontWeight.w700,
                      fontSize: 11 * s,
                    ),
                  ),
                ],
                SizedBox(height: 6 * s),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AuthTextField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final VoidCallback? onToggleVisibility;
  const AuthTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    required this.validator,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    final s = (MediaQuery.of(context).size.shortestSide / 600).clamp(0.78, 1.10);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: GameTone.textCream,
            fontWeight: FontWeight.w800,
            fontSize: 13 * s,
          ),
        ),
        SizedBox(height: 4 * s),
        TextFormField(
          controller: controller,
          validator: validator,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: TextStyle(color: GameTone.textCream, fontSize: 14 * s),
          decoration: InputDecoration(
            hintText: hint,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 12 * s),
            hintStyle: TextStyle(color: GameTone.textCream.withOpacity(0.55), fontSize: 13 * s),
            prefixIcon: Icon(icon, color: GameTone.goldTrim, size: 18 * s),
            suffixIcon: onToggleVisibility == null
                ? null
                : IconButton(
                    onPressed: onToggleVisibility,
                    icon: Icon(
                      obscureText ? Icons.visibility : Icons.visibility_off,
                      color: GameTone.goldTrim,
                    ),
                  ),
            filled: true,
            fillColor: const Color(0xAA1A0E04),
            errorStyle: const TextStyle(color: Color(0xFFFFB4A9)),
            enabledBorder: _fieldBorder(),
            focusedBorder: _fieldBorder(active: true),
            errorBorder: _fieldBorder(error: true),
            focusedErrorBorder: _fieldBorder(error: true),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _fieldBorder({bool active = false, bool error = false}) {
    final color =
        error ? const Color(0xFFE57373) : (active ? GameTone.goldBright : GameTone.goldTrim);
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: color, width: active ? 1.8 : 1.4),
    );
  }
}

class _RotateDeviceHint extends StatelessWidget {
  const _RotateDeviceHint();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: PixelFrame(
        padding: const EdgeInsets.all(20),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.screen_rotation_alt, size: 44, color: GameTone.textGold),
            SizedBox(height: 10),
            Text(
              'Gira el dispositivo',
              style: TextStyle(
                color: GameTone.textCream,
                fontWeight: FontWeight.w900,
                fontSize: 24,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Animal Go funciona en horizontal.',
              style: TextStyle(color: GameTone.textGold, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
