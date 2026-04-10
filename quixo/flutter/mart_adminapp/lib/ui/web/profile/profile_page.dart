import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mart_adminapp/features/profile/bloc/admin_profile_bloc.dart';
import 'package:mart_adminapp/features/profile/bloc/admin_profile_event.dart';
import 'package:mart_adminapp/features/profile/bloc/admin_profile_state.dart';
import 'package:mart_adminapp/features/profile/data/admin_profile_model.dart';
import 'package:mart_adminapp/ui/web/widgets/otp_dialog.dart';
import 'package:mart_adminapp/ui/web/web_shell.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  final _editKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _numberCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<AdminProfileBloc>().add(AdminProfileLoad());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _numberCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _showEditDialog(AdminProfile profile) async {
    _nameCtrl.text = profile.name;
    _numberCtrl.text = profile.number;
    _emailCtrl.text = profile.email;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit'),
          content: Form(
            key: _editKey,
            child: SizedBox(
              width: 420,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextFormField(
                      style: const TextStyle(color:Colors.black),
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        final value = v?.trim() ?? '';
                        if (value.isEmpty) return 'Name is required';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      style: const TextStyle(color:Colors.black),
                      controller: _numberCtrl,
                      decoration: const InputDecoration(
                        labelText: 'number',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        final value = v?.trim() ?? '';
                        if (value.isEmpty) return 'Number is required';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      style: const TextStyle(color:Colors.black),
                      controller: _emailCtrl,
                      decoration: const InputDecoration(
                        labelText: 'email',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (!(_editKey.currentState?.validate() ?? false)) return;
                final req = AdminProfileUpdateRequest(
                  name: _nameCtrl.text.trim(),
                  number: _numberCtrl.text.trim(),
                  email: _emailCtrl.text.trim()
                );
                context
                    .read<AdminProfileBloc>()
                    .add(AdminProfileUpdate(req));
                Navigator.pop(context);
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WebShell(
      title: 'Profile',
      child: BlocListener<AdminProfileBloc, AdminProfileState>(
        listener: (context, state) async {
          if (state is AdminProfileUpdatePending) {
            final otp = await showOtpDialog(context);
            if (otp != null && context.mounted) {
              context.read<AdminProfileBloc>().add(AdminProfileOtpVerify(otp));
            }
          } else if (state is AdminProfileSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            context.read<AdminProfileBloc>().add(AdminProfileLoad());
          } else if (state is AdminProfileFailed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<AdminProfileBloc, AdminProfileState>(
          builder: (context, state) {
            if (state is AdminProfileLoading || state is AdminProfileInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is AdminProfileLoaded) {
              final p = state.profile;
              return Padding(
                padding: const EdgeInsets.all(16),
                child: ListView(
                  children: [
                    Card(
                      color: Theme.of(context).primaryColorLight,
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'name: ${p.name}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 6),
                            Text('number: ${p.number}', style: Theme.of(context).textTheme.bodyMedium),
                            const SizedBox(height: 6),
                            Text('email: ${p.email}', style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 220,
                      child: ElevatedButton.icon(
                        onPressed: () => _showEditDialog(p),
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                      ),
                    ),
                    if (p.messages.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Inbox (contact & notices)',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      ...p.messages.reversed.map(
                        (m) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(
                              m.type.isEmpty ? 'message' : m.type,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(m.message),
                            isThreeLine: true,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

