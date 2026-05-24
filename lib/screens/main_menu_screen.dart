import 'package:flutter/material.dart';

import '../data/animal_data.dart';
import '../data/game_state.dart';
import '../data/item_data.dart';
import '../game/overlays/tutorial_overlay.dart';
import '../router/app_router.dart';
import '../services/auth_service.dart';
import '../services/stripe_payment_service.dart';
import '../theme/app_theme.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  final _gs = GameState();
  bool _showTutorial = false;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();

    if (!_gs.hasSeenAppTutorial) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _showTutorial = true);
      });
    }
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _push(String route) {
    Navigator.pushNamed(context, route).then((_) {
      if (mounted) setState(() {});
    });
  }

  String get _mapName {
    try {
      return MapCatalog.all.firstWhere((m) => m.id == _gs.currentMapId).name;
    } catch (_) {
      return 'Aldea Canta';
    }
  }

  String get _mapEmoji {
    try {
      return MapCatalog.all.firstWhere((m) => m.id == _gs.currentMapId).emoji;
    } catch (_) {
      return '\u{1F5FA}\u{FE0F}';
    }
  }

  int get _mapAnimals {
    try {
      return MapCatalog.all
          .firstWhere((m) => m.id == _gs.currentMapId)
          .animalsCount;
    } catch (_) {
      return 6;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeCtrl,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/backgrounds/main_menu_bg.png',
                fit: BoxFit.cover,
                filterQuality: FilterQuality.none,
              ),
            ),
            Positioned.fill(child: Container(color: const Color(0x33000000))),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, c) {
                  final w = c.maxWidth;
                  final h = c.maxHeight;
                  // Escala basada en el lado más corto: en móviles
                  // (h pequeño en horizontal) se reduce más agresivo.
                  final shortest = w < h ? w : h;
                  final scale = (shortest / 460).clamp(0.55, 1.10);
                  return _buildContent(w, h, scale.toDouble());
                },
              ),
            ),
            if (_showTutorial)
              TutorialOverlay(
                onFinish: () {
                  _gs.hasSeenAppTutorial = true;
                  _gs.autosave();
                  setState(() => _showTutorial = false);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(double w, double h, double s) {
    final pad = 8.0 * s;
    final isShort = h < 420; // móvil en horizontal típico
    final isNarrow = w < 800;
    // En móvil ocultamos el logo central (siempre) para liberar espacio
    // y evitar que el perfil + monedas + ajustes se solapen con él.
    return Padding(
      padding: EdgeInsets.all(pad),
      child: Column(
        children: [
          // ── Top bar: perfil | (logo solo en pantalla ancha) | monedas+ajustes
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(flex: 0, child: _profileCard(s)),
              const Spacer(),
              if (!isNarrow)
                Flexible(
                  child: IgnorePointer(
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: GameLogo(
                          title: 'ANIMAL GO!',
                          subtitle: '',
                          fontSize: 46 * s,
                        ),
                      ),
                    ),
                  ),
                ),
              if (!isNarrow) const Spacer(),
              OvalGoldChip(
                icon: '\u{1FA99}',
                value: '${_gs.coins}',
                onPlusTap: () => _showCurrencyShopDialog(isGems: false),
              ),
              SizedBox(width: 4 * s),
              OvalGoldChip(
                icon: '\u{1F48E}',
                value: '${_gs.gems}',
                onPlusTap: () => _showCurrencyShopDialog(isGems: true),
              ),
              SizedBox(width: 4 * s),
              _settingsBtn(s),
            ],
          ),
          SizedBox(height: 4 * s),
          // ── Centro: 4 botones en cuadrícula 2x2 (compacta) ────────────
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(vertical: 4 * s),
                child: _menuGrid2x2(s, w, isShort),
              ),
            ),
          ),
          SizedBox(height: 4 * s),
          // ── Bottom bar: mapa | play ─────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(flex: 3, child: _mapCard(s, w)),
              SizedBox(width: 6 * s),
              Expanded(flex: 2, child: _playButton(s, w)),
            ],
          ),
        ],
      ),
    );
  }

  /// Cuadrícula 2x2 compacta (Tienda · Animales / Misiones · Mochila),
  /// que cabe siempre en horizontal de móvil sin solaparse con la barra
  /// inferior ni con la barra superior.
  Widget _menuGrid2x2(double s, double w, bool isShort) {
    // Layout: dos columnas pegadas a los laterales, cada una con 2 pills
    // apiladas. Espacio central libre para que se vea el fondo del menú.
    //   IZQ: Animales (arriba) · Misiones (abajo)
    //   DER: Tienda  (arriba) · Mochila  (abajo)
    final pillW = ((w * 0.36).clamp(150.0, 240.0)).toDouble();
    final gap = 10.0 * s;
    Widget col(List<Widget> children) => Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            children[0],
            SizedBox(height: gap),
            children[1],
          ],
        );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        col([
          MenuPill(
              icon: '\u{1F4D6}',
              label: 'Animales',
              width: pillW,
              onTap: () => _push(AppRouter.collection)),
          MenuPill(
              icon: '\u{1F3AF}',
              label: 'Misiones',
              width: pillW,
              onTap: () => _push(AppRouter.missions)),
        ]),
        const Spacer(),
        col([
          MenuPill(
              icon: '\u{1F6D2}',
              label: 'Tienda',
              width: pillW,
              onTap: () => _push(AppRouter.shop)),
          MenuPill(
              icon: '\u{1F392}',
              label: 'Mochila',
              width: pillW,
              onTap: () => _push(AppRouter.inventory)),
        ]),
      ],
    );
  }

  Widget _profileCard(double s) => GestureDetector(
        onTap: () => _push(AppRouter.profile),
        child: SizedBox(
          width: 220 * s,
          height: 68 * s,
          child: PixelFrame(
            radius: 12,
            padding: EdgeInsets.fromLTRB(6 * s, 5 * s, 8 * s, 5 * s),
            child: Row(
              children: [
                Container(
                  width: 42 * s,
                  height: 42 * s,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [Color(0xFFFFE48A), Color(0xFFB07A2A)],
                    ),
                    border: Border.all(color: GameTone.goldTrim, width: 1.6),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: (_gs.googlePhotoUrl != null &&
                          _gs.googlePhotoUrl!.isNotEmpty)
                      ? Image.network(
                          _gs.googlePhotoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Text(
                              _gs.selectedSkin,
                              style: TextStyle(fontSize: 24 * s),
                            ),
                          ),
                        )
                      : Center(
                          child: Text(
                            _gs.selectedSkin,
                            style: TextStyle(fontSize: 24 * s),
                          ),
                        ),
                ),
                SizedBox(width: 7 * s),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _gs.playerName,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: GameTone.textCream,
                          fontWeight: FontWeight.w900,
                          fontSize: 13 * s,
                          height: 1.0,
                          shadows: const [
                            Shadow(
                              color: Color(0xFF1A0E04),
                              offset: Offset(0, 2),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 2 * s),
                      Text(
                        'Nv. ${_gs.level}',
                        style: TextStyle(
                          color: GameTone.textGold,
                          fontWeight: FontWeight.w800,
                          fontSize: 10 * s,
                        ),
                      ),
                      SizedBox(height: 3 * s),
                      Row(
                        children: [
                          Text('\u{2B50}', style: TextStyle(fontSize: 9 * s)),
                          SizedBox(width: 3 * s),
                          Expanded(
                            child: Container(
                              height: 6 * s,
                              decoration: BoxDecoration(
                                color: GameTone.woodOuter,
                                borderRadius: BorderRadius.circular(3),
                                border: Border.all(
                                  color: GameTone.goldTrim.withOpacity(0.7),
                                  width: 0.7,
                                ),
                              ),
                              child: FractionallySizedBox(
                                widthFactor: AnimalCatalog.all.isEmpty
                                    ? 0
                                    : (_gs.discoveredCount /
                                            AnimalCatalog.all.length)
                                        .clamp(0.0, 1.0),
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFF6C76B),
                                        Color(0xFFD4A04A),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 4 * s),
                          Text(
                            '${_gs.discoveredCount}/${AnimalCatalog.all.length}',
                            style: TextStyle(
                              color: GameTone.textCream,
                              fontWeight: FontWeight.w800,
                              fontSize: 9 * s,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _settingsBtn(double s) => GestureDetector(
        onTap: () => _push(AppRouter.settings),
        child: Container(
          width: 38 * s,
          height: 38 * s,
          decoration: BoxDecoration(
            color: GameTone.woodOuter,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: GameTone.goldTrim, width: 1.4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child:
                Icon(Icons.settings, size: 18 * s, color: GameTone.textCream),
          ),
        ),
      );

  Future<void> _showCurrencyShopDialog({required bool isGems}) async {
    final title = isGems ? 'Comprar diamantes' : 'Comprar monedas';
    final type = isGems ? 'diamonds' : 'coins';
    final packs = StripePaymentService.packs
        .where((p) => p.currencyType == type)
        .toList();
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierColor: const Color(0xAA000000),
      builder: (context) {
        String? buyingPackId;
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: StatefulBuilder(
              builder: (context, setLocalState) {
                Future<void> onBuy(CurrencyPack pack) async {
                  setLocalState(() => buyingPackId = pack.id);
                  try {
                    final msg = await StripePaymentService.buyPack(pack.id);
                    final session = await AuthService.restoreSession();
                    if (session != null) {
                      AuthService.applySessionToGameState(session);
                    }
                    if (!mounted || !context.mounted) return;
                    setState(() {});
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(msg)));
                  } on PurchaseCanceledException {
                    // El usuario salio de Stripe sin completar la compra.
                  } catch (e) {
                    if (!mounted || !context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          e.toString().replaceFirst('Exception: ', ''),
                        ),
                        backgroundColor: AppColors.badgeRed,
                      ),
                    );
                  } finally {
                    if (context.mounted) {
                      setLocalState(() => buyingPackId = null);
                    }
                  }
                }

                return PixelFrame(
                  radius: 14,
                  innerFill: const Color(0xFF1F1308),
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: GameTone.textGold,
                                  fontSize: 42,
                                  fontWeight: FontWeight.w900,
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
                            GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF5A3A16),
                                      Color(0xFF2D1B0A)
                                    ],
                                  ),
                                  border: Border.all(
                                    color: GameTone.goldTrim,
                                    width: 1.4,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: GameTone.textCream,
                                  size: 30,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        for (final pack in packs) ...[
                          _CurrencyPackCard(
                            pack: pack,
                            isGems: isGems,
                            loading: buyingPackId == pack.id,
                            onBuy: () => onBuy(pack),
                          ),
                          if (pack != packs.last) const SizedBox(height: 12),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _mapCard(double s, double w) {
    return GestureDetector(
      onTap: () => _push(AppRouter.mapSelect),
      child: SizedBox(
        height: 74 * s,
        child: PixelFrame(
          radius: 12,
          padding: EdgeInsets.fromLTRB(6 * s, 5 * s, 12 * s, 5 * s),
          child: Row(
            children: [
              Container(
                width: 48 * s,
                height: 48 * s,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: GameTone.goldTrim, width: 1.4),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF6BBA5B), Color(0xFF1F4E2A)],
                  ),
                ),
                child: Center(
                  child: Text(_mapEmoji, style: TextStyle(fontSize: 22 * s)),
                ),
              ),
              SizedBox(width: 10 * s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '\u{1F33F}  MUNDO SELECCIONADO',
                      style: TextStyle(
                        color: GameTone.textGold,
                        fontWeight: FontWeight.w800,
                        fontSize: 10 * s,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 3 * s),
                    Text(
                      _mapName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: GameTone.textCream,
                        fontWeight: FontWeight.w900,
                        fontSize: 14 * s,
                        height: 1.0,
                        shadows: const [
                          Shadow(
                            color: Color(0xFF1A0E04),
                            offset: Offset(0, 2),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 3 * s),
                    Container(
                        height: 1, color: GameTone.goldTrim.withOpacity(0.4)),
                    SizedBox(height: 3 * s),
                    Text(
                      '$_mapAnimals animales \u{1F333}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: GameTone.textCream.withOpacity(0.85),
                        fontSize: 11 * s,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _playButton(double s, double w) {
    return GestureDetector(
      onTap: () => _push(AppRouter.characterSelect),
      child: SizedBox(
        height: 74 * s,
        child: const _PlayBtnInline(),
      ),
    );
  }
}

class _CurrencyPackCard extends StatelessWidget {
  final CurrencyPack pack;
  final bool isGems;
  final bool loading;
  final VoidCallback onBuy;

  const _CurrencyPackCard({
    required this.pack,
    required this.isGems,
    required this.loading,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    final icon = switch (pack.id) {
      'coins_100' => '\u{1FA99}',
      'coins_500' => '\u{1FA99}\u{1FA99}',
      'coins_1000' => '\u{1F4B0}',
      'diamonds_10' => '\u{1F48E}',
      'diamonds_30' => '\u{1F48E}\u{1F48E}',
      'diamonds_75' => '\u{1F48D}',
      _ => isGems ? '\u{1F48E}' : '\u{1FA99}',
    };

    return PixelFrame(
      radius: 12,
      innerFill: const Color(0xFF2A180B),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: GameTone.goldTrim.withOpacity(0.7)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isGems
                    ? const [Color(0xFF12314A), Color(0xFF1A0E04)]
                    : const [Color(0xFF5A3A10), Color(0xFF1A0E04)],
              ),
            ),
            child:
                Center(child: Text(icon, style: const TextStyle(fontSize: 30))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              pack.title,
              style: const TextStyle(
                color: GameTone.textCream,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                pack.priceLabel,
                style: TextStyle(
                  color: isGems ? const Color(0xFF7DC7FF) : GameTone.textGold,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 42,
                child: ElevatedButton(
                  onPressed: loading ? null : onBuy,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2FA54D),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(
                          color: Color(0xFF145D2A), width: 1.4),
                    ),
                  ),
                  child: Text(
                    loading ? '...' : 'Comprar',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlayBtnInline extends StatefulWidget {
  const _PlayBtnInline();

  @override
  State<_PlayBtnInline> createState() => _PlayBtnInlineState();
}

class _PlayBtnInlineState extends State<_PlayBtnInline>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Container(
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: CustomPaint(
            painter: _GreenButtonPainterInline(),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('\u{1F33F}', style: TextStyle(fontSize: 16)),
                      SizedBox(width: 6),
                      Text(
                        '¡JUGAR!',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                          letterSpacing: 1.6,
                          shadows: [
                            Shadow(
                              color: Color(0xFF0E2C18),
                              offset: Offset(-2, 0),
                              blurRadius: 0,
                            ),
                            Shadow(
                              color: Color(0xFF0E2C18),
                              offset: Offset(2, 0),
                              blurRadius: 0,
                            ),
                            Shadow(
                              color: Color(0xFF0E2C18),
                              offset: Offset(0, -2),
                              blurRadius: 0,
                            ),
                            Shadow(
                              color: Color(0xFF0E2C18),
                              offset: Offset(0, 3),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 6),
                      Text('\u{1F33F}', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GreenButtonPainterInline extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final outer =
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(14));
    canvas.drawRRect(outer, Paint()..color = const Color(0xFF1A0E04));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Offset(2, 2) & Size(size.width - 4, size.height - 4),
        const Radius.circular(12),
      ),
      Paint()..color = GameTone.goldTrim,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Offset(5, 5) & Size(size.width - 10, size.height - 10),
        const Radius.circular(10),
      ),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF6BBA5B), Color(0xFF3A7A3A), Color(0xFF1F4E2A)],
        ).createShader(
          const Offset(5, 5) & Size(size.width - 10, size.height - 10),
        ),
    );
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
