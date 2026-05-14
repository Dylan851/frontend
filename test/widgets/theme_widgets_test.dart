// test/widgets/theme_widgets_test.dart
//
// Widget tests para los componentes visuales de `theme/app_theme.dart`.
// Se construyen los widgets dentro de un `MaterialApp` mínimo y se verifica
// presencia de textos/iconos clave y reactividad de `onTap`.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animalgo_game/theme/app_theme.dart';

Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  group('CurrencyChip', () {
    testWidgets('muestra icono y valor', (tester) async {
      await tester.pumpWidget(_wrap(
        const CurrencyChip(icon: '🪙', value: '1240'),
      ));
      expect(find.text('🪙'), findsOneWidget);
      expect(find.text('1240'), findsOneWidget);
    });

    testWidgets('admite color de acento personalizado', (tester) async {
      await tester.pumpWidget(_wrap(
        const CurrencyChip(icon: '💎', value: '9', accent: Colors.cyan),
      ));
      expect(find.text('💎'), findsOneWidget);
      expect(find.text('9'), findsOneWidget);
    });
  });

  group('BackBtn', () {
    testWidgets('muestra icono de back y dispara onTap', (tester) async {
      var pressed = false;
      await tester.pumpWidget(_wrap(
        BackBtn(onTap: () => pressed = true),
      ));
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
      await tester.tap(find.byType(BackBtn));
      expect(pressed, isTrue);
    });
  });

  group('GlassBox', () {
    testWidgets('renderiza el child que se le pasa', (tester) async {
      await tester.pumpWidget(_wrap(
        const GlassBox(child: Text('contenido glass')),
      ));
      expect(find.text('contenido glass'), findsOneWidget);
    });
  });

  group('WoodPanel', () {
    testWidgets('renderiza child y aplica padding', (tester) async {
      await tester.pumpWidget(_wrap(
        const WoodPanel(
          padding: EdgeInsets.all(8),
          child: Text('panel'),
        ),
      ));
      expect(find.text('panel'), findsOneWidget);
    });

    testWidgets('variante parchment (emerald=false) sigue mostrando child', (tester) async {
      await tester.pumpWidget(_wrap(
        const WoodPanel(emerald: false, child: Text('cream')),
      ));
      expect(find.text('cream'), findsOneWidget);
    });
  });

  group('CornerRibbon', () {
    testWidgets('muestra el label', (tester) async {
      await tester.pumpWidget(_wrap(
        const CornerRibbon(label: 'NEW'),
      ));
      expect(find.text('NEW'), findsOneWidget);
    });
  });

  group('ChunkyButton', () {
    testWidgets('muestra label y reacciona al tap', (tester) async {
      var taps = 0;
      await tester.pumpWidget(_wrap(
        ChunkyButton(label: 'JUGAR', onTap: () => taps++),
      ));
      expect(find.text('JUGAR'), findsOneWidget);
      await tester.tap(find.byType(ChunkyButton));
      expect(taps, 1);
    });

    testWidgets('puede mostrar un icono opcional', (tester) async {
      await tester.pumpWidget(_wrap(
        const ChunkyButton(label: 'PLAY', icon: Icons.play_arrow),
      ));
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });
  });

  group('PixelFrame', () {
    testWidgets('renderiza el child dentro del marco pixelado', (tester) async {
      await tester.pumpWidget(_wrap(
        const PixelFrame(child: Text('inside-frame')),
      ));
      expect(find.text('inside-frame'), findsOneWidget);
    });
  });

  group('OvalGoldChip', () {
    testWidgets('muestra icono y valor', (tester) async {
      await tester.pumpWidget(_wrap(
        const OvalGoldChip(icon: '🪙', value: '85'),
      ));
      expect(find.text('🪙'), findsOneWidget);
      expect(find.text('85'), findsOneWidget);
    });

    testWidgets('botón "+" aparece solo si onPlusTap está definido', (tester) async {
      var plusTaps = 0;
      await tester.pumpWidget(_wrap(
        OvalGoldChip(icon: '💎', value: '5', onPlusTap: () => plusTaps++),
      ));
      expect(find.text('+'), findsOneWidget);
      await tester.tap(find.text('+'));
      expect(plusTaps, 1);
    });

    testWidgets('sin onPlusTap, no dibuja botón "+"', (tester) async {
      await tester.pumpWidget(_wrap(
        const OvalGoldChip(icon: '💎', value: '5'),
      ));
      expect(find.text('+'), findsNothing);
    });
  });

  group('MenuPill', () {
    testWidgets('muestra icono y label', (tester) async {
      await tester.pumpWidget(_wrap(
        const MenuPill(icon: '🎒', label: 'INVENTARIO'),
      ));
      expect(find.text('🎒'), findsOneWidget);
      expect(find.text('INVENTARIO'), findsOneWidget);
    });

    testWidgets('dispara onTap al pulsar', (tester) async {
      var taps = 0;
      await tester.pumpWidget(_wrap(
        MenuPill(icon: '🛒', label: 'TIENDA', onTap: () => taps++),
      ));
      await tester.tap(find.byType(MenuPill));
      expect(taps, 1);
    });
  });
}
