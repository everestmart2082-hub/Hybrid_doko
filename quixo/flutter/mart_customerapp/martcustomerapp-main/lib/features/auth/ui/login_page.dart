import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickmartcustomer/core/constants/app_constants.dart';
import 'package:quickmartcustomer/drawer.dart';
import 'package:quickmartcustomer/features/auth/bloc/auth_bloc.dart';
import 'package:quickmartcustomer/features/auth/bloc/auth_event.dart';
import 'package:quickmartcustomer/features/auth/bloc/auth_state.dart';
import 'package:quickmartcustomer/features/auth/data/auth_model_input.dart';
import 'package:quickmartcustomer/features/auth/data/otp_verify_model_input.dart';

import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final otpController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool showOtp = false;

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {

        if (state is AuthAuthenticated && state.authenticated) {
          Navigator.pushReplacementNamed(context, "/profile");
        }

        if (state is AuthFailed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }

        if (state is AuthAuthenticated && !state.authenticated) {
          setState(() => showOtp = true);
        }

      },

      builder: (context, state) {

        return Scaffold(

          appBar: AppBar(
            title: const Text(AppConstants.appName),
            elevation: 0,
          ),
          drawer: buildAppDrawer(context),

          body: Container(

            width: double.infinity,
            height: double.infinity,

            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  theme.primaryColorLight,
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
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                      ),
                    ],
                  ),

                  child: Form(
                    key: _formKey,

                    child: Column(

                      mainAxisSize: MainAxisSize.min,

                      children: [

                        /// Logo
                        Image.asset(
                          "assets/images/pngs/mountain.png",
                          height: 80,
                        ),

                        const SizedBox(height: 16),

                        /// Title
                        Text(
                          "Welcome Back",
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColorDark,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          "Login to continue",
                          style: theme.textTheme.bodyMedium,
                        ),

                        const SizedBox(height: 24),

                        /// Phone
                        TextFormField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          decoration: InputDecoration(
                            labelText: "Phone",
                            labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                            border: OutlineInputBorder(),
                            counterText: "",
                          ),
                          validator: (value) {

                            if (value == null || value.isEmpty) {
                              return "Phone required";
                            }

                            if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                              return "Enter valid 10 digit phone";
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 12),

                        /// Email
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: "Email",
                            labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {

                            if (value == null || value.isEmpty) {
                              return "Email required";
                            }

                            final emailRegex = RegExp(
                              r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$',
                            );

                            if (!emailRegex.hasMatch(value)) {
                              return "Enter valid email";
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 12),

                        /// OTP field
                        if (showOtp)
                          TextFormField(
                            controller: otpController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "OTP",
                              border: OutlineInputBorder(),
                            ),
                          ),

                        const SizedBox(height: 20),

                        /// Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(

                            onPressed: state is AuthLoading
                                ? null
                                : () {

                              if (!showOtp) {

                                if (!_formKey.currentState!.validate()) return;

                                context.read<AuthBloc>().add(
                                  AuthLogin(
                                    input: AuthModel(
                                      phone: phoneController.text,
                                      email: emailController.text,
                                    ),
                                  ),
                                );

                                setState(() => showOtp = true);

                              } else {

                                context.read<AuthBloc>().add(
                                  AuthLoginOtpVerify(
                                    input: OtpVerifyModel(
                                      phone: phoneController.text,
                                      otp: otpController.text,
                                    ),
                                  ),
                                );

                              }

                            },

                            child: state is AuthLoading
                                ? const CircularProgressIndicator()
                                : Text(showOtp ? "Verify OTP" : "Send OTP"),

                          ),
                        ),

                        const SizedBox(height: 12),

                        /// Register button
                        TextButton(

                          onPressed: () {

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterPage(),
                              ),
                            );

                          },

                          child: Text(
                            "Create new account",
                            style: TextStyle(
                              color: theme.primaryColorDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

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