import 'package:flutter/material.dart';

class PaymentPage extends StatelessWidget {
  final String? message;

  const PaymentPage({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: Center(
        child: Text(message ?? 'Payment page'),
      ),
    );
  }
}

