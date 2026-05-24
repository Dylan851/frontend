import 'package:animalgo_game/router/app_router.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AppRouter parsea el path y query de /payments?result=cancel', () {
    final route = AppRouter.parseRoute('/payments?result=cancel');

    expect(route.path, AppRouter.payments);
    expect(route.queryParameters['result'], 'cancel');
  });
}
