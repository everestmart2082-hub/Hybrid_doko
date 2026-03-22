import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../data/rider_login_model.dart';

class RiderLoginPage extends StatefulWidget {
  const RiderLoginPage({super.key});

  @override
  State<RiderLoginPage> createState() => _RiderLoginPageState();
}

class _RiderLoginPageState extends State<RiderLoginPage> {
  final TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Check existing auth
    context.read<RiderAuthBloc>().add(AuthCheck());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Rider Login")),
      body: BlocConsumer<RiderAuthBloc, RiderAuthState>(
        listener: (context, state) {
          if (state is RiderAuthSuccess && state.token != null) {
            Navigator.pushReplacementNamed(context, "/mainApp");
          }
          if (state is RiderAuthFailure) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is RiderAuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: "Phone Number",
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    context.read<RiderAuthBloc>().add(
                        RiderLoginRequested(RiderLoginModel(
                            phone: phoneController.text.trim())));
                  },
                  child: const Text("Send OTP"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/register");
                  },
                  child: const Text("Register as Rider"),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}