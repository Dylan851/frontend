// lib/theme/app_theme.dart
import 'package:flutter/material.dart';

abstract class AppColors {
  static const Color greenDark    = Color(0xFF0D2B1A);
  static const Color greenMid     = Color(0xFF1A4A2E);
  static const Color greenBright  = Color(0xFF2D9E5F);
  static const Color greenAccent  = Color(0xFF56E39F);
  static const Color greenDeep    = Color(0xFF16A461);
  static const Color greenGround  = Color(0xFF0D3D20);
  static const Color gold         = Color(0xFFFFE566);
  static const Color goldDark     = Color(0xFFFF9900);
  static const Color badgeRed     = Color(0xFFFF3B3B);
  static const Color overlay45    = Color(0x73000000);
  static const Color overlay35    = Color(0x59000000);
  static const Color borderWhite  = Color(0x33FFFFFF);
  static const Color shopPurple   = Color(0xFF9B59B6);
  static const Color profileBlue  = Color(0xFF2C3E8A);
  static const Color settingsDark = Color(0xFF1A1A4A);
  static const Color starGold     = Color(0xFFFFD700);
  static const Color correct      = Color(0xFF4CAF50);
  static const Color wrong        = Color(0xFFF44336);
  static const Color cardBack     = Color(0xFF1B4332);
  static const Color cardFront    = Color(0xFF2D9E5F);
  static const Color avatarOrange = Color(0xFFFF9900);
  static const Color avatarRed    = Color(0xFFFF5500);
}

abstract class AppTheme {
  static ThemeData get theme => ThemeData(
    fontFamily: 'Nunito',
    scaffoldBackgroundColor: AppColors.greenDark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.greenAccent,
      secondary: AppColors.gold,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.greenAccent,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
  );
}

// ─── Reusable Widgets ──────────────────────────────────────────────────────

class GlassBox extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Color? borderColor;
  final Color? bgColor;
  const GlassBox({super.key, required this.child, this.padding,
      this.borderRadius, this.borderColor, this.bgColor});

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: bgColor ?? AppColors.overlay45,
      borderRadius: borderRadius ?? BorderRadius.circular(14),
      border: Border.all(color: borderColor ?? AppColors.borderWhite, width: 1.5),
    ),
    child: child,
  );
}

class CurrencyChip extends StatelessWidget {
  final String icon;
  final String value;
  const CurrencyChip({super.key, required this.icon, required this.value});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: AppColors.overlay45,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.borderWhite, width: 1),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Text(icon, style: const TextStyle(fontSize: 13)),
      const SizedBox(width: 4),
      Text(value, style: const TextStyle(
          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
    ]),
  );
}

class BackBtn extends StatelessWidget {
  final VoidCallback? onTap;
  const BackBtn({super.key, this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap ?? () => Navigator.of(context).pop(),
    child: Container(
      width: 36, height: 36,
      decoration: BoxDecoration(
        color: AppColors.overlay45,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderWhite, width: 1.5),
      ),
      child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 15),
    ),
  );
}

class HexPatternPainter extends CustomPainter {
  const HexPatternPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..style = PaintingStyle.stroke..strokeWidth = 1;
    const r = 30.0; const h = r * 1.732; int col = 0;
    for (double x = 0; x < size.width + r * 2; x += r * 1.5) {
      for (double y = col.isEven ? 0 : h / 2; y < size.height + h; y += h) {
        final path = Path();
        for (int i = 0; i < 6; i++) {
          final a = 3.14159265 / 180 * (60 * i - 30);
          final px = x + r * _cos(a); final py = y + r * _sin(a);
          i == 0 ? path.moveTo(px, py) : path.lineTo(px, py);
        }
        path.close(); canvas.drawPath(path, paint);
      }
      col++;
    }
  }
  static double _cos(double a) {
    double s = 0, t = 1;
    for (int i = 1; i <= 7; i++) { t *= -a * a / (2 * i * (2 * i - 1)); s += t; }
    return 1 + s;
  }
  static double _sin(double a) {
    double s = a, t = a;
    for (int i = 1; i <= 7; i++) { t *= -a * a / ((2 * i) * (2 * i + 1)); s += t; }
    return s;
  }
  @override bool shouldRepaint(_) => false;
}
