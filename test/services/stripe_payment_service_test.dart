import 'package:animalgo_game/services/stripe_payment_service.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StripePaymentService.isUserCancellation', () {
    test('devuelve true para cancelación explícita de la app', () {
      expect(
        StripePaymentService.isUserCancellation(
          const PurchaseCanceledException(),
        ),
        isTrue,
      );
    });

    test('devuelve true para StripeException cancelada', () {
      expect(
        StripePaymentService.isUserCancellation(
          const StripeException(
            error: LocalizedErrorMessage(code: FailureCode.Canceled),
          ),
        ),
        isTrue,
      );
    });

    test('devuelve false para StripeException fallida', () {
      expect(
        StripePaymentService.isUserCancellation(
          const StripeException(
            error: LocalizedErrorMessage(code: FailureCode.Failed),
          ),
        ),
        isFalse,
      );
    });
  });
}
