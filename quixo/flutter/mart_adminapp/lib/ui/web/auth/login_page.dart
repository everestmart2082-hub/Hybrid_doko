import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mart_adminapp/features/auth/bloc/admin_auth_bloc.dart';
import 'package:mart_adminapp/features/auth/bloc/admin_auth_event.dart';
import 'package:mart_adminapp/features/auth/bloc/admin_auth_state.dart';
import 'package:mart_adminapp/ui/web/web_shell.dart';
import 'package:mart_adminapp/ui/web/widgets/otp_dialog.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phone = TextEditingController();

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context
          .read<AdminAuthBloc>()
          .add(AdminLogin(phone: _phone.text.trim()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return WebShell(
      title: 'Login',
      child: BlocConsumer<AdminAuthBloc, AdminAuthState>(
        listener: (ctx, state) async {
          if (state is AdminAuthOtpSent) {
            final otp = await showOtpDialog(ctx);
            if (otp != null && ctx.mounted) {
              ctx.read<AdminAuthBloc>().add(
                    AdminLoginOtpVerify(
                        phone: state.phone, otp: otp),
                  );
            }
          } else if (state is AdminAuthenticated && state.authenticated) {
            Navigator.pushReplacementNamed(ctx, '/mainapp');
          } else if (state is AdminAuthFailed) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red),
            );
          }
        },
        builder: (ctx, state) {
          final loading = state is AdminAuthLoading;
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Admin Login',
                            style: Theme.of(ctx)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 32),
                          TextFormField(
                            controller: _phone,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Phone (+977)',
                              prefixText: '+977 ',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Phone is required';
                              }
                              if (v.trim().length != 10) {
                                return 'Phone must be 10 digits';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: loading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16)),
                              child: loading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white))
                                  : const Text('Login'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
