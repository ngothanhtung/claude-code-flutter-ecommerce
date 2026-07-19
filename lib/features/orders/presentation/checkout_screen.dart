import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/currency.dart';
import '../../cart/presentation/cart_providers.dart';
import '../data/order.dart';
import 'order_providers.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});
  static const routeName = '/checkout';
  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final formKey = GlobalKey<FormState>();
  final recipient = TextEditingController();
  final phone = TextEditingController();
  final address = TextEditingController();
  PaymentMethod payment = PaymentMethod.cod;

  @override
  void dispose() {
    recipient.dispose();
    phone.dispose();
    address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = ref.watch(cartSubtotalProvider);
    final state = ref.watch(checkoutProvider);
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
          children: [
            Text(
              'Where should it go?',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              'Your order is securely linked to your account.',
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 22),
            TextFormField(
              key: const ValueKey('recipient-field'),
              controller: recipient,
              decoration: const InputDecoration(
                labelText: 'Recipient name',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: _required,
            ),
            const SizedBox(height: 14),
            TextFormField(
              key: const ValueKey('phone-field'),
              controller: phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone number',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              validator: (value) =>
                  RegExp(r'^[+0-9][0-9 ]{7,}$').hasMatch(value?.trim() ?? '')
                  ? null
                  : 'Enter a valid phone number',
            ),
            const SizedBox(height: 14),
            TextFormField(
              key: const ValueKey('address-field'),
              controller: address,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Delivery address',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              validator: _required,
            ),
            const SizedBox(height: 26),
            Text(
              'Payment',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            RadioGroup<PaymentMethod>(
              groupValue: payment,
              onChanged: (value) {
                if (value != null) setState(() => payment = value);
              },
              child: Column(
                children: [
                  RadioListTile(
                    value: PaymentMethod.cod,
                    title: const Text('Cash on delivery'),
                    subtitle: const Text('Pay when your order arrives'),
                    secondary: const Icon(Icons.payments_outlined),
                  ),
                  RadioListTile(
                    value: PaymentMethod.demoCard,
                    title: const Text('Demo card'),
                    subtitle: const Text(
                      'Simulated payment — no card details needed',
                    ),
                    secondary: const Icon(Icons.credit_card_outlined),
                  ),
                ],
              ),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  'Could not place the order. Your cart is safe.',
                  style: TextStyle(color: colors.error),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
          child: FilledButton.icon(
            key: const ValueKey('place-order-button'),
            onPressed: state.isLoading
                ? null
                : () async {
                    if (!(formKey.currentState?.validate() ?? false)) return;
                    final order = await ref
                        .read(checkoutProvider.notifier)
                        .placeOrder(
                          recipient: recipient.text,
                          phone: phone.text,
                          address: address.text,
                          paymentMethod: payment,
                        );
                    if (order != null && context.mounted) {
                      Navigator.pushReplacementNamed(
                        context,
                        OrderSuccessScreen.routeName,
                        arguments: order.id,
                      );
                    }
                  },
            icon: state.isLoading
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.lock_outline_rounded),
            label: Text(
              state.isLoading
                  ? 'Placing order…'
                  : 'Place order · ${formatCurrency(total)}',
            ),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(58),
            ),
          ),
        ),
      ),
    );
  }

  String? _required(String? value) =>
      (value?.trim().isEmpty ?? true) ? 'This field is required' : null;
}
