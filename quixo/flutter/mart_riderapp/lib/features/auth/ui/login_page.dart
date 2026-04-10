import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickmartrider/drawer.dart';
import 'package:quickmartrider/features/auth/bloc/auth_bloc.dart';
import 'package:quickmartrider/features/auth/bloc/auth_event.dart';
import 'package:quickmartrider/features/auth/bloc/auth_state.dart';
import 'package:quickmartrider/features/auth/data/rider_login_model.dart';
import 'package:quickmartrider/features/auth/data/rider_otp_model.dart';

class RiderLoginPage extends StatefulWidget {
  const RiderLoginPage({super.key});

  @override
  State<RiderLoginPage> createState() => _RiderLoginPageState();
}

class _RiderLoginPageState extends State<RiderLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();

  bool _awaitingOtp = false;
  String? _pendingPhone;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<String?> _showOtpDialog() async {
    final otpCtrl = TextEditingController();

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Verify OTP'),
          content: TextField(
            controller: otpCtrl,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: const InputDecoration(
              labelText: 'OTP',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final otp = otpCtrl.text.trim();
                if (otp.length != 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('OTP must be 6 digits')),
                  );
                  return;
                }
                Navigator.pop(context, otp);
              },
              child: const Text('Okay'),
            ),
          ],
        );
      },
    );
  }

  void _submitLogin() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final phone = _phoneCtrl.text.trim();
    _pendingPhone = phone;
    context.read<RiderAuthBloc>().add(
          RiderLoginRequested(RiderLoginModel(phone: phone)),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorLight,
      drawer: buildAppDrawer(context),
      body: BlocListener<RiderAuthBloc, RiderAuthState>(
        listener: (context, state) async {
          if (state is RiderAuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }

          if (state is RiderAuthSuccess) {
            // Backend sends "verify otp" without token for the OTP step.
            if (state.message == 'verify otp' && !_awaitingOtp) {
              if (_pendingPhone == null) return;
              _awaitingOtp = true;
              final otp = await _showOtpDialog();
              if (!mounted) return;

              if (otp != null) {
                context.read<RiderAuthBloc>().add(
                      RiderLoginOtpRequested(
                        RiderOtpModel(phone: _pendingPhone!, otp: otp),
                      ),
                    );
              }
              _awaitingOtp = false;
              return;
            }

            // OTP verified (or already authenticated) -> token exists.
            if (state.token != null && state.token!.isNotEmpty) {
              Navigator.pushReplacementNamed(context, '/profile');
            }
          }
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Card(
                elevation: 4,
                color: Theme.of(context).primaryColorLight,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'Login',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        TextFormField(
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.number,
                          maxLength: 10,
                          decoration: const InputDecoration(
                            labelText: 'phone (+977)',
                            hintText: '10 digits',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) {
                            final value = v?.trim() ?? '';
                            if (value.isEmpty) return 'Phone number is required';
                            if (value.length != 10) return 'Phone must be 10 digits';
                            if (!RegExp(r'^\d{10}$').hasMatch(value)) return 'Numbers only';
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        BlocBuilder<RiderAuthBloc, RiderAuthState>(
                          builder: (context, state) {
                            final loading = state is RiderAuthLoading;
                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: loading ? null : _submitLogin,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: loading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Text('Login'),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 18),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, '/register');
                            },
                            child: const Text("Don't have an account? Register"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

