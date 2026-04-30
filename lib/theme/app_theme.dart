// lib/theme/app_theme.dart
//
// Aesthetic: Cozy Pixel Adventure
//   · Foundations: deep emerald + parchment cream + warm amber
//   · Bold tracked typography for game-ad feel
//   · Chunky cards with thick borders + inner highlight + drop shadow
//   · Decorative leaf pattern atmosphere
//
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

abstract class AppColors {
  // ── Legacy palette (mantenida para compatibilidad) ───────────────────
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

  // ── New "Cozy Adventure" tones ───────────────────────────────────────
  static const Color forestNight  = Color(0xFF071A0F); // background base
  static const Color forestDeep   = Color(0xFF0F2E1B);
  static const Color emerald      = Color(0xFF1F5C39);
  static const Color emeraldGlow  = Color(0xFF34A65F);
  static const Color parchment    = Color(0xFFF5E6CA); // cream UI base
  static const Color parchmentDim = Color(0xFFD9C49E);
  static const Color amber        = Color(0xFFE8B452); // warm accents
  static const Color amberDeep    = Color(0xFFB07A2A);
  static const Color woodTrim     = Color(0xFF5D3A1A); // borders
  static const Color woodLight    = Color(0xFF8B5A2B);
  static const Color ink          = Color(0xFF221208); // dark text on parchment
  static const Color leafShadow   = Color(0xFF052010);
  static const Color sunRay       = Color(0xFFFFE8A8);
}

abstract class AppTheme {
  static ThemeData get theme => ThemeData(
    fontFamily: 'Nunito',
    scaffoldBackgroundColor: AppColors.forestNight,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.emeraldGlow,
      secondary: AppColors.amber,
      surface: AppColors.forestDeep,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.emeraldGlow,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(
            fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────
//  TEXT STYLES
// ─────────────────────────────────────────────────────────────────────
abstract class AppText {
  /// Big tracked uppercase title — "DISTINCTIVE" feel.
  static const TextStyle display = TextStyle(
    color: AppColors.parchment,
    fontWeight: FontWeight.w900,
    fontSize: 28,
    letterSpacing: 2.6,
    height: 1.05,
    shadows: [
      Shadow(color: Color(0xFF000000), offset: Offset(0, 3), blurRadius: 0),
      Shadow(color: AppColors.leafShadow, offset: Offset(0, 6), blurRadius: 12),
    ],
  );

  static const TextStyle eyebrow = TextStyle(
    color: AppColors.amber,
    fontWeight: FontWeight.w800,
    fontSize: 10,
    letterSpacing: 3.0,
  );

  static const TextStyle sectionTitle = TextStyle(
    color: AppColors.parchment,
    fontWeight: FontWeight.w900,
    fontSize: 16,
    letterSpacing: 1.6,
  );

  static const TextStyle bodyLight = TextStyle(
    color: Color(0xCCFFFFFF),
    fontSize: 12.5,
    height: 1.45,
  );
}

// ─────────────────────────────────────────────────────────────────────
//  REUSABLE WIDGETS
// ─────────────────────────────────────────────────────────────────────

/// Chunky framed card — thick wood-trim border, inner highlight, drop shadow.
/// Use as the basis for "game-ad" panels.
class WoodPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final Color? bg;
  final Color? border;
  final bool emerald;
  const WoodPanel({
    super.key,
    required this.child,
    this.padding,
    this.radius = 18,
    this.bg,
    this.border,
    this.emerald = true,
  });

  @override
  Widget build(BuildContext context) {
    final base = bg ??
        (emerald
            ? const Color(0xFF143421)
            : AppColors.parchment);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: emerald
              ? [base.lighten(0.04), base.darken(0.06)]
              : [base, base.darken(0.08)],
        ),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: border ?? (emerald ? AppColors.amber.withOpacity(0.55) : AppColors.woodTrim),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.leafShadow.withOpacity(0.55),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
          // Inner highlight (top edge)
          BoxShadow(
            color: Colors.white.withOpacity(0.04),
            blurRadius: 0,
            spreadRadius: -1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );
  }
}

extension _ColorTone on Color {
  Color lighten(double a) => Color.lerp(this, Colors.white, a) ?? this;
  Color darken(double a) => Color.lerp(this, Colors.black, a) ?? this;
}

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

/// Currency / stat chip with ornate amber border.
class CurrencyChip extends StatelessWidget {
  final String icon;
  final String value;
  final Color? accent;
  const CurrencyChip({super.key, required this.icon, required this.value, this.accent});

  @override
  Widget build(BuildContext context) {
    final c = accent ?? AppColors.amber;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF0A1F12).withOpacity(0.95),
            const Color(0xFF051208).withOpacity(0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.withOpacity(0.7), width: 1.4),
        boxShadow: [
          BoxShadow(color: c.withOpacity(0.18), blurRadius: 10),
        ],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(icon, style: const TextStyle(fontSize: 13)),
        const SizedBox(width: 5),
        Text(value, style: TextStyle(
            color: c.lighten(0.4),
            fontWeight: FontWeight.w900,
            fontSize: 12,
            letterSpacing: 0.6)),
      ]),
    );
  }
}

class BackBtn extends StatelessWidget {
  final VoidCallback? onTap;
  const BackBtn({super.key, this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap ?? () => Navigator.of(context).pop(),
    child: Container(
      width: 38, height: 38,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF143421), Color(0xFF071A0F)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: AppColors.amber.withOpacity(0.55), width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.parchment, size: 15),
    ),
  );
}

/// Section title with decorative leaf flourishes on each side.
class OrnateTitle extends StatelessWidget {
  final String text;
  final String? eyebrow;
  final TextAlign align;
  const OrnateTitle({super.key, required this.text, this.eyebrow, this.align = TextAlign.center});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      if (eyebrow != null) ...[
        Text(eyebrow!, style: AppText.eyebrow, textAlign: align),
        const SizedBox(height: 4),
      ],
      Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
        _flourish(true),
        const SizedBox(width: 8),
        Flexible(child: Text(text,
            textAlign: align,
            style: AppText.sectionTitle.copyWith(color: AppColors.parchment))),
        const SizedBox(width: 8),
        _flourish(false),
      ]),
    ]);
  }

  Widget _flourish(bool left) => Row(mainAxisSize: MainAxisSize.min, children: [
    if (!left) const Text('🍃', style: TextStyle(fontSize: 12)),
    Container(
      width: 26, height: 1.5,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: left ? Alignment.centerLeft : Alignment.centerRight,
          end: left ? Alignment.centerRight : Alignment.centerLeft,
          colors: [Colors.transparent, AppColors.amber.withOpacity(0.6)],
        ),
      ),
    ),
    if (left) const Text('🍃', style: TextStyle(fontSize: 12)),
  ]);
}

/// Diagonal ribbon corner badge ("NEW", "HOT", "!", etc.)
class CornerRibbon extends StatelessWidget {
  final String label;
  final Color color;
  const CornerRibbon({super.key, required this.label, this.color = AppColors.amber});

  @override
  Widget build(BuildContext context) => Transform.rotate(
        angle: 0.7,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.darken(0.2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [BoxShadow(color: color.withOpacity(0.6), blurRadius: 8)],
          ),
          child: Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 9,
                  letterSpacing: 1.2)),
        ),
      );
}

/// Chunky 3D primary action button.
class ChunkyButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final Color color;
  final Color textColor;
  final double height;
  final bool wide;
  const ChunkyButton({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.color = AppColors.emeraldGlow,
    this.textColor = Colors.white,
    this.height = 54,
    this.wide = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = Container(
      height: height,
      padding: EdgeInsets.symmetric(horizontal: wide ? 28 : 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.lighten(0.08), color.darken(0.18)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.18), width: 1.5),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.45), blurRadius: 22),
          BoxShadow(color: Colors.black.withOpacity(0.45), blurRadius: 6, offset: const Offset(0, 4)),
        ],
      ),
      child: Center(
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(label,
              style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: 1.6,
                  shadows: const [Shadow(color: Color(0xFF052010), offset: Offset(0, 2), blurRadius: 4)])),
          if (icon != null) ...[
            const SizedBox(width: 8),
            Icon(icon, color: textColor, size: 22),
          ],
        ]),
      ),
    );
    return GestureDetector(onTap: onTap, child: child);
  }
}

// ─────────────────────────────────────────────────────────────────────
//  PATTERN PAINTERS
// ─────────────────────────────────────────────────────────────────────

/// Subtle leaf-vein lattice — replaces the old hex pattern for atmosphere.
class LeafLatticePainter extends CustomPainter {
  final double opacity;
  const LeafLatticePainter({this.opacity = 0.05});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.amber.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    const step = 56.0;
    for (double y = 0; y < size.height + step; y += step) {
      for (double x = -step; x < size.width + step; x += step) {
        final off = (y / step).floor().isOdd ? step / 2 : 0;
        // Diagonal leaf shape
        final path = Path()
          ..moveTo(x + off, y)
          ..quadraticBezierTo(x + off + step / 2, y - 10, x + off + step, y)
          ..moveTo(x + off + step / 2, y - 8)
          ..lineTo(x + off + step / 2, y - 22);
        canvas.drawPath(path, paint);
      }
    }
  }

  @override bool shouldRepaint(_) => false;
}

/// Old hex pattern kept for backward compatibility.
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
          final a = math.pi / 180 * (60 * i - 30);
          final px = x + r * math.cos(a); final py = y + r * math.sin(a);
          i == 0 ? path.moveTo(px, py) : path.lineTo(px, py);
        }
        path.close(); canvas.drawPath(path, paint);
      }
      col++;
    }
  }
  @override bool shouldRepaint(_) => false;
}

// ─────────────────────────────────────────────────────────────────────
//  PIXEL-GAME CHROME (wooden frames, logo, pills)
// ─────────────────────────────────────────────────────────────────────

/// Backdrop común para las pantallas accedidas desde el menú
/// (Mochila, Colección, Tienda, Misiones, Perfil...). Carga la
/// pixel-art forest scene y un overlay oscuro para legibilidad.
class MenuBackdrop extends StatelessWidget {
  final Widget child;
  final double dim;
  const MenuBackdrop({super.key, required this.child, this.dim = 0.55});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned.fill(
        child: Image.asset(
          'assets/images/backgrounds/map_select_bg.png',
          fit: BoxFit.cover,
          filterQuality: FilterQuality.none,
        ),
      ),
      Positioned.fill(child: Container(color: Colors.black.withOpacity(dim))),
      Positioned.fill(child: child),
    ]);
  }
}

/// Cabecera estándar: botón atrás (madera) + título dorado tracked +
/// chip opcional a la derecha (counter / currencies).
class GameHeader extends StatelessWidget {
  final String title;
  final List<Widget> trailing;
  final VoidCallback? onBack;
  const GameHeader({
    super.key,
    required this.title,
    this.trailing = const [],
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        _woodBack(context),
        const SizedBox(width: 12),
        Flexible(
          child: ShaderMask(
            shaderCallback: (b) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFE48A), Color(0xFFE8B452), Color(0xFFB07A2A)],
            ).createShader(b),
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 30,
                letterSpacing: 1.6,
                height: 1.0,
                shadows: [
                  Shadow(color: Color(0xFF1A0E04), offset: Offset(-2, 0), blurRadius: 0),
                  Shadow(color: Color(0xFF1A0E04), offset: Offset(2, 0), blurRadius: 0),
                  Shadow(color: Color(0xFF1A0E04), offset: Offset(0, -2), blurRadius: 0),
                  Shadow(color: Color(0xFF1A0E04), offset: Offset(0, 3), blurRadius: 0),
                  Shadow(color: Color(0x88000000), offset: Offset(0, 6), blurRadius: 8),
                ],
              ),
            ),
          ),
        ),
        const Spacer(),
        ...trailing.map((w) => Padding(padding: const EdgeInsets.only(left: 6), child: w)),
      ]),
    );
  }

  Widget _woodBack(BuildContext context) => GestureDetector(
    onTap: onBack ?? () => Navigator.of(context).pop(),
    child: Container(
      width: 46, height: 42,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color(0xFF6B4423), Color(0xFF3A2210)],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: GameTone.goldTrim, width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 6, offset: const Offset(0, 3)),
        ],
      ),
      child: const Icon(Icons.arrow_back_rounded, color: GameTone.textCream, size: 22),
    ),
  );
}

/// Chip estilo placa de madera (texto sobre madera + borde dorado),
/// usado para el contador "14/24 slots" y similares.
class WoodChip extends StatelessWidget {
  final String label;
  final String? icon;
  const WoodChip({super.key, required this.label, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color(0xFF6B4423), Color(0xFF3A2210)],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: GameTone.goldTrim, width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.45), blurRadius: 6, offset: const Offset(0, 3)),
        ],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[
          Text(icon!, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
        ],
        Text(label,
            style: const TextStyle(
              color: GameTone.textCream,
              fontWeight: FontWeight.w800,
              fontSize: 13,
              letterSpacing: 0.4,
              shadows: [Shadow(color: Color(0xFF1A0E04), offset: Offset(0, 2), blurRadius: 0)],
            )),
      ]),
    );
  }
}

/// Pestaña tipo "Comida / Equipo / Especial" — placa de madera con
/// estado activo (verde brillante con borde dorado).
class WoodTab extends StatelessWidget {
  final String icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;
  const WoodTab({
    super.key,
    required this.icon,
    required this.label,
    this.active = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: active
                ? const [Color(0xFF6BBA5B), Color(0xFF1F4E2A)]
                : const [Color(0xFF6B4423), Color(0xFF3A2210)],
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: GameTone.goldTrim, width: active ? 2 : 1.4),
          boxShadow: [
            if (active)
              BoxShadow(color: const Color(0xFF6BE095).withOpacity(0.45), blurRadius: 14),
            BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 5, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                color: GameTone.textCream,
                fontWeight: FontWeight.w800,
                fontSize: 13,
                letterSpacing: 0.3,
                shadows: [Shadow(color: Color(0xFF1A0E04), offset: Offset(0, 2), blurRadius: 0)],
              )),
        ]),
      ),
    );
  }
}



abstract class GameTone {
  // Wooden game UI palette (matches mockup screenshots)
  static const Color woodOuter   = Color(0xFF2A1A0C); // outer dark border
  static const Color woodMid     = Color(0xFF4A2D14); // middle layer
  static const Color woodInner   = Color(0xFF6B4423); // light wood highlight
  static const Color goldTrim    = Color(0xFFD4A04A); // gold inner trim
  static const Color goldBright  = Color(0xFFF6C76B); // gold highlight
  static const Color panelDark   = Color(0xFF1B2812); // dark panel fill (greenish)
  static const Color panelMid    = Color(0xFF2A3A1E);
  static const Color leafGreen   = Color(0xFF3A7A3A); // button green
  static const Color leafDeep    = Color(0xFF1F4E2A);
  static const Color textGold    = Color(0xFFF5C863);
  static const Color textCream   = Color(0xFFFBE9C2);
}

/// Wooden 9-slice-style frame painted procedurally:
/// outer dark wood → mid wood → gold trim → inner dark panel.
class PixelFrame extends StatelessWidget {
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final Color innerFill;
  final bool goldStuds;
  const PixelFrame({
    super.key,
    this.child,
    this.padding,
    this.radius = 14,
    this.innerFill = GameTone.panelDark,
    this.goldStuds = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PixelFramePainter(radius: radius, innerFill: innerFill, studs: goldStuds),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(10),
        child: child,
      ),
    );
  }
}

class _PixelFramePainter extends CustomPainter {
  final double radius;
  final Color innerFill;
  final bool studs;
  _PixelFramePainter({required this.radius, required this.innerFill, required this.studs});

  @override
  void paint(Canvas canvas, Size size) {
    final r = radius;
    final outer = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(r));
    canvas.drawRRect(outer, Paint()..color = GameTone.woodOuter);
    // mid wood
    final mid = RRect.fromRectAndRadius(
        const Offset(2, 2) & Size(size.width - 4, size.height - 4),
        Radius.circular(r - 1));
    canvas.drawRRect(mid, Paint()..color = GameTone.woodMid);
    // wood grain top highlight
    final hi = RRect.fromRectAndRadius(
        const Offset(3, 3) & Size(size.width - 6, 2),
        Radius.circular(1));
    canvas.drawRRect(hi, Paint()..color = GameTone.woodInner.withOpacity(0.8));
    // gold trim
    final goldRect = RRect.fromRectAndRadius(
        const Offset(5, 5) & Size(size.width - 10, size.height - 10),
        Radius.circular(r - 3));
    canvas.drawRRect(goldRect, Paint()
      ..color = GameTone.goldTrim
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2);
    // inner fill
    final inner = RRect.fromRectAndRadius(
        const Offset(7, 7) & Size(size.width - 14, size.height - 14),
        Radius.circular(r - 5));
    canvas.drawRRect(inner, Paint()..color = innerFill);
    // gold highlight on top of inner
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Offset(7, 7) & Size(size.width - 14, 1.5),
          const Radius.circular(0.8)),
      Paint()..color = GameTone.goldBright.withOpacity(0.18),
    );

    // Corner studs (small gold rivets)
    if (studs) {
      const pad = 9.5;
      final stud = Paint()..color = GameTone.goldBright;
      final studDark = Paint()..color = GameTone.goldTrim;
      for (final p in [
        Offset(pad, pad),
        Offset(size.width - pad, pad),
        Offset(pad, size.height - pad),
        Offset(size.width - pad, size.height - pad),
      ]) {
        canvas.drawCircle(p, 1.6, studDark);
        canvas.drawCircle(p.translate(-0.4, -0.4), 0.9, stud);
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

/// "ANIMALGO"-style chunky gold logo with black outline and drop shadow.
class GameLogo extends StatelessWidget {
  final String title;
  final String? subtitle;
  final double fontSize;
  const GameLogo({super.key, required this.title, this.subtitle, this.fontSize = 44});

  @override
  Widget build(BuildContext context) {
    final outline = <Shadow>[
      const Shadow(color: Color(0xFF1A0E04), offset: Offset(-2, 0), blurRadius: 0),
      const Shadow(color: Color(0xFF1A0E04), offset: Offset(2, 0), blurRadius: 0),
      const Shadow(color: Color(0xFF1A0E04), offset: Offset(0, -2), blurRadius: 0),
      const Shadow(color: Color(0xFF1A0E04), offset: Offset(0, 2), blurRadius: 0),
      const Shadow(color: Color(0xFF1A0E04), offset: Offset(2, 2), blurRadius: 0),
      const Shadow(color: Color(0xFF1A0E04), offset: Offset(-2, 2), blurRadius: 0),
      const Shadow(color: Color(0x88000000), offset: Offset(0, 6), blurRadius: 8),
    ];
    return Column(mainAxisSize: MainAxisSize.min, children: [
      // Leaf crown
      const Text('🌿', style: TextStyle(fontSize: 22, height: 1)),
      Transform.translate(
        offset: const Offset(0, -6),
        child: ShaderMask(
          shaderCallback: (b) => const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFE48A), Color(0xFFE8B452), Color(0xFFB07A2A)],
            stops: [0.0, 0.55, 1.0],
          ).createShader(b),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: fontSize,
              letterSpacing: 1.5,
              height: 1.0,
              shadows: outline,
            ),
          ),
        ),
      ),
      if (subtitle != null) ...[
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: GameTone.woodOuter,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: GameTone.goldTrim, width: 1.2),
          ),
          child: Text(subtitle!,
              style: const TextStyle(
                color: GameTone.textCream,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              )),
        ),
      ],
    ]);
  }
}

/// Side-menu pill button — icon-on-left, gold-trimmed wooden plaque.
class MenuPill extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback? onTap;
  final Color accent;
  final double width;
  const MenuPill({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.accent = GameTone.panelDark,
    this.width = 168,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width, height: 78,
        child: PixelFrame(
          radius: 14,
          innerFill: accent,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: GameTone.woodOuter,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: GameTone.goldTrim.withOpacity(0.7), width: 1.4),
              ),
              child: Center(child: Text(icon, style: const TextStyle(fontSize: 28))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                    color: GameTone.textCream,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    letterSpacing: 0.3,
                    shadows: [Shadow(color: Color(0xFF1A0E04), offset: Offset(0, 2), blurRadius: 0)],
                  )),
            ),
          ]),
        ),
      ),
    );
  }
}

/// Oval gold-bordered chip for currencies (like the 1240 / 85 chips in mockup).
class OvalGoldChip extends StatelessWidget {
  final String icon;
  final String value;
  const OvalGoldChip({super.key, required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 4, 14, 4),
      decoration: BoxDecoration(
        color: GameTone.woodOuter,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: GameTone.goldTrim, width: 1.6),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.45), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [
              icon == '🪙' ? const Color(0xFFFFE48A) : const Color(0xFF7DD3FC),
              icon == '🪙' ? const Color(0xFFB07A2A) : const Color(0xFF1F5E8C),
            ]),
            border: Border.all(color: GameTone.goldTrim, width: 1),
          ),
          child: Center(child: Text(icon, style: const TextStyle(fontSize: 14))),
        ),
        const SizedBox(width: 7),
        Text(value,
            style: const TextStyle(
              color: GameTone.textCream,
              fontWeight: FontWeight.w900,
              fontSize: 16,
              letterSpacing: 0.4,
              shadows: [Shadow(color: Color(0xFF1A0E04), offset: Offset(0, 2), blurRadius: 0)],
            )),
      ]),
    );
  }
}

/// Big green wooden "JUGAR" button.
class JugarButton extends StatefulWidget {
  final VoidCallback? onTap;
  const JugarButton({super.key, this.onTap});
  @override
  State<JugarButton> createState() => _JugarButtonState();
}

class _JugarButtonState extends State<JugarButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
  }
  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) => Container(
          width: 200, height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6BE095).withOpacity(0.3 + 0.3 * _c.value),
                blurRadius: 22,
                spreadRadius: 1,
              ),
            ],
          ),
          child: CustomPaint(
            painter: _GreenButtonPainter(),
            child: Center(
              child: Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: const [
                Text('🌿', style: TextStyle(fontSize: 18)),
                SizedBox(width: 6),
                Text('¡JUGAR!',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 26,
                      letterSpacing: 1.6,
                      shadows: [
                        Shadow(color: Color(0xFF0E2C18), offset: Offset(-2, 0), blurRadius: 0),
                        Shadow(color: Color(0xFF0E2C18), offset: Offset(2, 0), blurRadius: 0),
                        Shadow(color: Color(0xFF0E2C18), offset: Offset(0, -2), blurRadius: 0),
                        Shadow(color: Color(0xFF0E2C18), offset: Offset(0, 3), blurRadius: 0),
                      ],
                    )),
                SizedBox(width: 6),
                Text('🌿', style: TextStyle(fontSize: 18)),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class _GreenButtonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final outer = RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(14));
    canvas.drawRRect(outer, Paint()..color = const Color(0xFF1A0E04));
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Offset(2, 2) & Size(size.width - 4, size.height - 4), const Radius.circular(12)),
      Paint()..color = GameTone.goldTrim,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Offset(5, 5) & Size(size.width - 10, size.height - 10), const Radius.circular(10)),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF6BBA5B), Color(0xFF3A7A3A), Color(0xFF1F4E2A)],
        ).createShader(const Offset(5, 5) & Size(size.width - 10, size.height - 10)),
    );
    // Top highlight stroke
    canvas.drawLine(
      const Offset(10, 8.5),
      Offset(size.width - 10, 8.5),
      Paint()
        ..color = const Color(0x55FFFFFF)
        ..strokeWidth = 1.4,
    );
  }
  @override
  bool shouldRepaint(_) => false;
}

/// Painted forest atmosphere — gradient + subtle grain. Used when no
/// pixel-art background asset is available.
class ForestSceneBg extends StatelessWidget {
  const ForestSceneBg({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF3A6B2C),
            Color(0xFF2D5821),
            Color(0xFF1B3815),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(children: [
        // dapples of light
        Positioned.fill(child: CustomPaint(painter: _DapplePainter())),
        // vignette
        const Positioned.fill(child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              radius: 1.2,
              colors: [Colors.transparent, Color(0x99000000)],
              stops: [0.55, 1.0],
            ),
          ),
        )),
      ]),
    );
  }
}

class _DapplePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(7);
    final p = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
    for (int i = 0; i < 16; i++) {
      p.color = Colors.yellow.withOpacity(0.04 + rng.nextDouble() * 0.04);
      canvas.drawCircle(
        Offset(rng.nextDouble() * size.width, rng.nextDouble() * size.height),
        18 + rng.nextDouble() * 24,
        p,
      );
    }
    // tiny fireflies
    final fp = Paint()..color = const Color(0xFFFFE48A).withOpacity(0.9)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
    for (int i = 0; i < 12; i++) {
      canvas.drawCircle(
        Offset(rng.nextDouble() * size.width, size.height * (0.4 + rng.nextDouble() * 0.55)),
        1.2 + rng.nextDouble() * 1.4,
        fp,
      );
    }
  }
  @override
  bool shouldRepaint(_) => false;
}

/// Animated soft sun-rays radiating from a focal point — used as
/// hero atmosphere on the main menu.
class SunRaysPainter extends CustomPainter {
  final double t;
  final Offset focus;
  const SunRaysPainter({required this.t, required this.focus});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..blendMode = BlendMode.plus;
    const rays = 12;
    for (int i = 0; i < rays; i++) {
      final a = (i / rays) * math.pi * 2 + t * 0.4;
      final len = math.max(size.width, size.height);
      final dx = math.cos(a) * len;
      final dy = math.sin(a) * len;
      final shader = ui.Gradient.linear(
        focus,
        Offset(focus.dx + dx, focus.dy + dy),
        [AppColors.sunRay.withOpacity(0.10), Colors.transparent],
      );
      p.shader = shader;
      final path = Path()
        ..moveTo(focus.dx, focus.dy)
        ..lineTo(focus.dx + dx + math.cos(a + 0.06) * 80,
                 focus.dy + dy + math.sin(a + 0.06) * 80)
        ..lineTo(focus.dx + dx - math.cos(a + 0.06) * 80,
                 focus.dy + dy - math.sin(a + 0.06) * 80)
        ..close();
      canvas.drawPath(path, p);
    }
  }

  @override
  bool shouldRepaint(covariant SunRaysPainter old) => old.t != t || old.focus != focus;
}
