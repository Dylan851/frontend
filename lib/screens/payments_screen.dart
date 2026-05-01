import 'package:flutter/material.dart';

import '../services/stripe_payment_service.dart';
import '../theme/app_theme.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  bool _loading = false;
  String? _packId;

  Future<void> _buy(String packId) async {
    setState(() {
      _loading = true;
      _packId = packId;
    });
    try {
      final message = await StripePaymentService.buyPack(packId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.badgeRed,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _packId = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1A10),
      appBar: AppBar(title: const Text('Pagos')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Monedas = recurso normal. Diamantes = recurso premium y mas caro.',
            style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ...StripePaymentService.packs.map((pack) {
            final premium = pack.currencyType == 'diamonds';
            final selected = _loading && _packId == pack.id;
            return Card(
              color: const Color(0xFF143421),
              child: ListTile(
                title: Text(pack.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                subtitle: Text(
                  '${premium ? "Premium" : "Normal"} - ${pack.priceLabel}',
                  style: TextStyle(color: premium ? Colors.lightBlueAccent : Colors.amberAccent),
                ),
                trailing: ElevatedButton(
                  onPressed: _loading ? null : () => _buy(pack.id),
                  child: Text(selected ? '...' : 'Comprar'),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
