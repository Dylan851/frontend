import 'package:flutter/foundation.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'api_service.dart';
import 'auth_service.dart';
import 'external_url_opener.dart';

class CurrencyPack {
  final String id;
  final String title;
  final String currencyType;
  final int quantity;
  final String priceLabel;

  const CurrencyPack({
    required this.id,
    required this.title,
    required this.currencyType,
    required this.quantity,
    required this.priceLabel,
  });
}

class StripePaymentService {
  static const packs = <CurrencyPack>[
    CurrencyPack(id: 'coins_100', title: '100 Monedas', currencyType: 'coins', quantity: 100, priceLabel: '0.99 EUR'),
    CurrencyPack(id: 'coins_500', title: '500 Monedas', currencyType: 'coins', quantity: 500, priceLabel: '2.99 EUR'),
    CurrencyPack(id: 'coins_1000', title: '1000 Monedas', currencyType: 'coins', quantity: 1000, priceLabel: '4.99 EUR'),
    CurrencyPack(id: 'diamonds_10', title: '10 Diamantes', currencyType: 'diamonds', quantity: 10, priceLabel: '1.99 EUR'),
    CurrencyPack(id: 'diamonds_30', title: '30 Diamantes', currencyType: 'diamonds', quantity: 30, priceLabel: '4.99 EUR'),
    CurrencyPack(id: 'diamonds_75', title: '75 Diamantes', currencyType: 'diamonds', quantity: 75, priceLabel: '9.99 EUR'),
  ];

  static Future<String> buyPack(String packId) async {
    final session = await AuthService.restoreSession();
    if (session == null || session.token.isEmpty || session.playerId == null) {
      throw Exception('Debes iniciar sesión para comprar.');
    }

    if (kIsWeb) {
      return _buyPackWebCheckout(session.token, session.playerId!, packId);
    }

    return _buyPackMobileSheet(session.token, session.playerId!, packId);
  }

  static Future<String> _buyPackMobileSheet(String token, String playerId, String packId) async {
    final intent = await ApiService.createPaymentIntent(
      token: token,
      userId: playerId,
      packId: packId,
    );
    if (intent['success'] != true) {
      throw Exception((intent['detail'] ?? intent['error'] ?? 'No se pudo crear el pago.').toString());
    }

    final data = (intent['data'] as Map?)?.cast<String, dynamic>() ?? {};
    final clientSecret = (data['client_secret'] ?? '').toString();
    if (clientSecret.isEmpty) {
      throw Exception('No se recibió client_secret de Stripe.');
    }

    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: 'AnimalGO',
      ),
    );
    await Stripe.instance.presentPaymentSheet();

    final refreshed = await AuthService.restoreSession();
    if (refreshed != null) {
      await AuthService.refreshSessionFromServer(refreshed);
    }
    return 'Pago completado. Tu saldo se actualizará tras confirmar Stripe.';
  }

  static Future<String> _buyPackWebCheckout(String token, String playerId, String packId) async {
    final checkout = await ApiService.createCheckoutSession(
      token: token,
      userId: playerId,
      packId: packId,
      successUrl: 'http://localhost:8080/#/payments?result=success',
      cancelUrl: 'http://localhost:8080/#/payments?result=cancel',
    );
    if (checkout['success'] != true) {
      throw Exception((checkout['detail'] ?? checkout['error'] ?? 'No se pudo crear Stripe Checkout.').toString());
    }

    final data = (checkout['data'] as Map?)?.cast<String, dynamic>() ?? {};
    final checkoutUrl = (data['checkout_url'] ?? '').toString();
    if (checkoutUrl.isEmpty) {
      throw Exception('No se recibió checkout_url de Stripe.');
    }

    final opened = await openExternalUrl(checkoutUrl);
    if (!opened) {
      throw Exception('No se pudo abrir Stripe Checkout.');
    }

    return 'Redirigiendo a Stripe Checkout...';
  }
}
