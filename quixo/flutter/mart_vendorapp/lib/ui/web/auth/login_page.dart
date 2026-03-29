import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickmartvender/features/auth/bloc/auth_bloc.dart';
import 'package:quickmartvender/features/auth/bloc/auth_event.dart';
import 'package:quickmartvender/features/auth/bloc/auth_state.dart';
import 'package:quickmartvender/features/auth/data/otp_verify_model.dart';
import '../widgets/otp_dialog.dart';

class VenderLoginPage extends StatefulWidget {
  const VenderLoginPage({super.key});

  @override
  State<VenderLoginPage> createState() => _VenderLoginPageState();
}

class _VenderLoginPageState extends State<VenderLoginPage> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _awaitingOtp = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<VenderAuthBloc>().add(
            VenderLogin(phone: _phoneController.text.trim()),
          );
    }
  }

  Future<void> _showOtpAndVerify() async {
    final otp = await showOtpDialog(context);
    if (!mounted || otp == null) return;
    context.read<VenderAuthBloc>().add(
          VenderLoginOtpVerify(
            input: VenderOtpVerifyModel(
              phone: _phoneController.text.trim(),
              otp: otp,
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: BlocListener<VenderAuthBloc, VenderAuthState>(
        listener: (context, state) {
          if (state is VenderAuthenticated && !state.authenticated && !_awaitingOtp) {
            _awaitingOtp = true;
            _showOtpAndVerify().then((_) => _awaitingOtp = false);
          }
          if (state is VenderAuthenticated && state.authenticated) {
            Navigator.pushReplacementNamed(context, '/mainapp');
          }
          if (state is VenderAuthFailed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Login',
                            style: theme.textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 32),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            prefixText: '+977 ',
                            border: OutlineInputBorder(),
                            counterText: '',
                          ),
                          validator: (v) {
                            if (v == null || v.trim().length != 10) {
                              return 'Enter a valid 10-digit phone number';
                            }
                            if (!RegExp(r'^\d{10}$').hasMatch(v.trim())) {
                              return 'Numbers only';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        BlocBuilder<VenderAuthBloc, VenderAuthState>(
                          builder: (context, state) {
                            final loading = state is VenderAuthLoading;
                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: loading ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                child: loading
                                    ? const SizedBox(height: 20, width: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                    : const Text('Login'),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () =>
                              Navigator.pushReplacementNamed(context, '/register'),
                          child: const Text("Don't have an account? Register"),
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
