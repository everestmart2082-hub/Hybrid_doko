import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickmartcustomer/features/auth/bloc/auth_bloc.dart';
import 'package:quickmartcustomer/features/auth/bloc/auth_event.dart';
import 'package:quickmartcustomer/features/auth/bloc/auth_state.dart';
import 'package:quickmartcustomer/features/auth/data/auth_model_input.dart';
import 'package:quickmartcustomer/features/auth/data/otp_verify_model_input.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  void _submitLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AuthLogin(
          input: AuthModel(
            phone: _phoneController.text.trim(),
            email: '', // Not required for login
          ),
        ),
      );
    }
  }

  void _submitOtp() {
    if (_otpController.text.length == 6) {
      context.read<AuthBloc>().add(
        AuthLoginOtpVerify(
          input: OtpVerifyModel(
            phone: _phoneController.text.trim(),
            otp: _otpController.text.trim(),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP must be exactly 6 digits')),
      );
    }
  }

  void _showOtpDialog() {
    _otpController.clear();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("Enter OTP"),
          content: TextField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 6,
            decoration: const InputDecoration(
              labelText: "OTP",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog manually if needed
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                _submitOtp();
              },
              child: const Text("Okay"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated && !state.authenticated) {
            _showOtpDialog();
          } else if (state is AuthAuthenticated && state.authenticated) {
            // Dismiss dialog if open
            if (Navigator.canPop(context)) Navigator.pop(context);
            // Navigate to home after successful Auth
            // Based on route map, mainapp manages Shell, wait mainapp resolves auth automatically
            // But let's pushReplacement to mainapp to be safe
            Navigator.pushReplacementNamed(context, '/mainapp');
          } else if (state is AuthFailed) {
            if (Navigator.canPop(context)) Navigator.pop(context);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(
                          labelText: "Phone (+977)",
                          border: OutlineInputBorder(),
                          prefixText: "+977 ",
                        ),
                        validator: (value) {
                          if (value == null || value.trim().length != 10) {
                            return 'Enter a valid 10-digit phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            return ElevatedButton(
                              onPressed: (state is AuthLoading)
                                  ? null
                                  : _submitLogin,
                              child: (state is AuthLoading)
                                  ? const CircularProgressIndicator()
                                  : const Text("Login Button"),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/register');
                        },
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
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }
}
