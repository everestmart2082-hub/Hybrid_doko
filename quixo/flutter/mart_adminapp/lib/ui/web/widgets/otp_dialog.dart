import 'package:flutter/material.dart';

/// Reusable OTP dialog.
/// Returns the 6-digit OTP string or null if dismissed.
Future<String?> showOtpDialog(BuildContext context) {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return AlertDialog(
        title: const Text('Enter OTP', style: const TextStyle(color: Colors.black),),
        content: TextField(
           style: const TextStyle(color: Colors.black),
          controller: controller,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: const InputDecoration(
            hintText: 'OTP (6 digits)',
            counterText: '',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final otp = controller.text.trim();
              if (otp.length == 6) {
                Navigator.pop(ctx, otp);
              }
            },
            child: const Text('Okay'),
          ),
        ],
      );
    },
  );
}
