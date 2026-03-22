import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickmartvender/drawer.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../data/otp_verify_model.dart';
import 'register_page.dart';

class VenderLoginPage extends StatefulWidget {
  const VenderLoginPage({super.key});

  @override
  State<VenderLoginPage> createState() => _VenderLoginPageState();
}

class _VenderLoginPageState extends State<VenderLoginPage> {

  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool showOtp = false;

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    return BlocConsumer<VenderAuthBloc, VenderAuthState>(

      listener: (context, state) {

        if (state is VenderAuthenticated && state.authenticated) {
          Navigator.pushReplacementNamed(context, "vender_home");
        }

        if (state is VenderAuthFailed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }

        if (state is VenderAuthenticated && !state.authenticated) {
          setState(() => showOtp = true);
        }

      },

      builder: (context, state) {

        return Scaffold(

          appBar: AppBar(
            title: const Text("Vendor Login"),
          ),
          drawer: buildAppDrawer(context),

          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white ,
                  Theme.of(context).primaryColorLight,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Center(
            
              child: SingleChildScrollView(
            
                padding: const EdgeInsets.all(20),
            
                child: Container(
            
                  padding: const EdgeInsets.all(24),
            
                  decoration: BoxDecoration(
                    color: theme.primaryColorLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
            
                  child: Form(
            
                    key: _formKey,
            
                    child: Column(
            
                      mainAxisSize: MainAxisSize.min,
            
                      children: [
            
                        Text(
                          "Vendor Login",
                          style: theme.textTheme.headlineSmall,
                        ),
            
                        const SizedBox(height: 24),
            
                        /// PHONE
                        TextFormField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          decoration: InputDecoration(
                            labelText: "Phone",
                            labelStyle: Theme.of(context).textTheme.bodyMedium,
                            border: OutlineInputBorder(),
                            counterText: "",
                          ),
                          validator: (v) {
            
                            if (v == null || v.isEmpty) {
                              return "Phone required";
                            }
            
                            if (!RegExp(r'^\d{10}$').hasMatch(v)) {
                              return "Enter valid phone";
                            }
            
                            return null;
                          },
                        ),
            
                        const SizedBox(height: 12),
            
                        if (showOtp)
                          TextFormField(
                            controller: otpController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: "OTP",
                            labelStyle: Theme.of(context).textTheme.bodyMedium,
                              border: OutlineInputBorder(),
                            ),
                          ),
            
                        const SizedBox(height: 20),
            
                        SizedBox(
            
                          width: double.infinity,
            
                          child: ElevatedButton(
            
                            onPressed: state is VenderAuthLoading
                                ? null
                                : () {
            
                              if (!showOtp) {
            
                                if (!_formKey.currentState!.validate()) return;
            
                                context.read<VenderAuthBloc>().add(
                                  VenderLogin(
                                    phone: phoneController.text,
                                  ),
                                );
            
                                setState(() => showOtp = true);
            
                              } else {
            
                                context.read<VenderAuthBloc>().add(
                                  VenderLoginOtpVerify(
                                    input: VenderOtpVerifyModel(
                                      phone: phoneController.text,
                                      otp: otpController.text,
                                    ),
                                  ),
                                );
            
                              }
            
                            },
            
                            child: state is VenderAuthLoading
                                ? const CircularProgressIndicator()
                                : Text(showOtp ? "Verify OTP" : "Send OTP", 
                            style: Theme.of(context).textTheme.bodyMedium,),
            
                          ),
                        ),
            
                        const SizedBox(height: 12),
            
                        TextButton(
            
                          onPressed: () {
            
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const VenderRegisterPage(),
                              ),
                            );
            
                          },
            
                          child: Text("Register as Vendor",
                            style: Theme.of(context).textTheme.bodyMedium),
            
                        )
            
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}