import 'package:flutter/material.dart';
import 'package:quickmartcustomer/widgets/customer_hub_bar_icons.dart';

class PaymentPage extends StatelessWidget {
  final String? message;

  const PaymentPage({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorLight,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColorDark,
        title: Text('Payment', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).primaryColorLight)),
        elevation: 1,
        actions: const [CustomerHubBarIcons()],
      ),
      body: Center(
        child: Text(message ?? 'Payment page'),
      ),
    );
  }
}

