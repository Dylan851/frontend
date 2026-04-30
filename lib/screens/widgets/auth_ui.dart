import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AuthScaffold extends StatelessWidget {
  final Widget child;
  const AuthScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1A10),
      body: MenuBackdrop(
        dim: 0.5,
        child: SafeArea(
          child: OrientationBuilder(
            builder: (context, orientation) {
              final size = MediaQuery.of(context).size;
              final isPortrait = size.height > size.width;
              if (isPortrait) return const _RotateDeviceHint();
              return child;
            },
          ),
        ),
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
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: PixelFrame(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
            radius: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: GameTone.textCream,
                    fontWeight: FontWeight.w900,
                    fontSize: 44,
                    shadows: [
                      Shadow(color: Color(0xFF1A0E04), offset: Offset(0, 2)),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: GameTone.textGold,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 14),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: GameTone.textCream,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: validator,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: const TextStyle(color: GameTone.textCream),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: GameTone.textCream.withOpacity(0.55)),
            prefixIcon: Icon(icon, color: GameTone.goldTrim),
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
