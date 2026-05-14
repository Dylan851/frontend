// test/widget_test.dart
//
// Smoke test mínimo del entry point. Las suites detalladas están en
// `test/data/`, `test/widgets/` y `test/config/`. Este archivo se mantiene
// como punto de comprobación rápido del binding de tests.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animalgo_game/data/game_state.dart';

void main() {
  testWidgets('binding inicializa y GameState es accesible', (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    final gs = GameState();
    expect(gs, isNotNull);
    expect(identical(GameState(), gs), isTrue,
        reason: 'GameState debe ser singleton');
  });
}
