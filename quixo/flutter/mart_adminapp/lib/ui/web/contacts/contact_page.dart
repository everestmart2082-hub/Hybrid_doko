import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mart_adminapp/features/contacts/bloc/contact_bloc.dart';
import 'package:mart_adminapp/features/contacts/bloc/contact_event.dart';
import 'package:mart_adminapp/features/contacts/bloc/contact_state.dart';
import 'package:mart_adminapp/ui/web/web_shell.dart';

class AdminContactsPage extends StatefulWidget {
  const AdminContactsPage({super.key});

  @override
  State<AdminContactsPage> createState() => _AdminContactsPageState();
}

class _AdminContactsPageState extends State<AdminContactsPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _message = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _message.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<ContactBloc>().add(
          SendContactMessage(
            name: _name.text.trim(),
            email: _email.text.trim(),
            message: _message.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return WebShell(
      title: 'Contact Us',
      child: BlocListener<ContactBloc, ContactState>(
        listener: (context, state) {
          if (state is ContactSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            _name.clear();
            _email.clear();
            _message.clear();
          } else if (state is ContactError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'COntact Us',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          style: const TextStyle(color: Colors.black),
                          controller: _name,
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          style: const TextStyle(color: Colors.black),
                          controller: _email,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            final value = v?.trim() ?? '';
                            if (value.isEmpty) return 'Email is required';
                            final emailRegex =
                                RegExp(r'^[\w.-]+@[\w.-]+\.\w{2,}$');
                            if (!emailRegex.hasMatch(value)) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          style: const TextStyle(color: Colors.black),
                          controller: _message,
                          decoration: const InputDecoration(
                            labelText: 'Message',
                            border: OutlineInputBorder(),
                          ),
                          minLines: 4,
                          maxLines: 7,
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Message is required' : null,
                        ),
                        const SizedBox(height: 22),
                        BlocBuilder<ContactBloc, ContactState>(
                          builder: (context, state) {
                            final loading = state is ContactLoading;
                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: loading ? null : _submit,
                                child: loading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text('Send'),
                              ),
                            );
                          },
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

