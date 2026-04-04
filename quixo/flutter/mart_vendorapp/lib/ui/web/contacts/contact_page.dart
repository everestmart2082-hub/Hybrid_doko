import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickmartvender/features/contacts/bloc/contact_bloc.dart';
import 'package:quickmartvender/features/contacts/bloc/contact_event.dart';
import 'package:quickmartvender/features/contacts/bloc/contact_state.dart';
import '../web_shell.dart';

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
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
    if (_formKey.currentState!.validate()) {
      context.read<ContactBloc>().add(SendContactMessage(
            name: _name.text.trim(),
            email: _email.text.trim(),
            message: _message.text.trim(),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return WebShell(
      title: 'Contact Us',
      child: BlocListener<ContactBloc, ContactState>(
        listener: (context, state) {
          if (state is ContactSuccess) {
            _name.clear();
            _email.clear();
            _message.clear();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ));
          }
          if (state is ContactError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ));
          }
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
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
                          child: Text('Contact Us',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 28),
                        TextFormField(
                          controller: _name,
                          decoration: const InputDecoration(
                              labelText: 'Name', border: OutlineInputBorder()),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                              labelText: 'Email', border: OutlineInputBorder()),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Email is required';
                            if (!RegExp(r'^[\w.-]+@[\w.-]+\.\w{2,}$').hasMatch(v.trim())) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _message,
                          maxLines: 5,
                          decoration: const InputDecoration(
                              labelText: 'Message', border: OutlineInputBorder()),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Message is required' : null,
                        ),
                        const SizedBox(height: 24),
                        BlocBuilder<ContactBloc, ContactState>(
                          builder: (context, state) {
                            final loading = state is ContactLoading;
                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: loading ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16)),
                                child: loading
                                    ? const SizedBox(height: 20, width: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                    : const Text('Send Message'),
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
