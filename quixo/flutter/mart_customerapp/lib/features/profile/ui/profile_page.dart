import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:quickmartcustomer/features/profile/bloc/profile_bloc.dart';
import 'package:quickmartcustomer/features/profile/bloc/profile_event.dart';
import 'package:quickmartcustomer/features/profile/bloc/profile_state.dart';
import 'package:quickmartcustomer/features/profile/data/profile_delete_model.dart';
import 'package:quickmartcustomer/features/profile/data/profile_otp_model.dart';
import 'package:quickmartcustomer/features/profile/data/profile_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _editFormKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  String? _lastPhoneForOtp;
  bool _awaitingOtpVerification = false;

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(ProfileGet());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _showOtpDialog(String phone) async {
    final otpCtrl = TextEditingController();
    await showDialog<void>(
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
                context.read<ProfileBloc>().add(
                  ProfileVerifyOtp(ProfileOtpModel(otp: otp, phone: phone)),
                );
                Navigator.pop(context);
              },
              child: const Text('Okay'),
            ),
          ],
        );
      },
    );
  }

  void _showEditProfileDialog(ProfileModel profile) {
    _nameCtrl.text = profile.name;
    _emailCtrl.text = profile.email;
    _phoneCtrl.text = profile.phone;
    _lastPhoneForOtp = null;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: Form(
            key: _editFormKey,
            child: SizedBox(
              width: 360,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Phone (+977)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ],
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
                if (!(_editFormKey.currentState?.validate() ?? false)) {
                  return;
                }
                context.read<ProfileBloc>().add(
                  ProfileUpdate(
                    profile.copyWith(
                      name: _nameCtrl.text.trim(),
                      email: _emailCtrl.text.trim(),
                      phone: _phoneCtrl.text.trim(),
                    ),
                  ),
                );
                _lastPhoneForOtp = _phoneCtrl.text.trim();
                _awaitingOtpVerification = true;
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorLight,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColorDark,
        title: Text(
          'Profile',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).primaryColorLight,
          ),
        ),
        elevation: 1,
      ),
      body: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) async {
          if (state is ProfileSuccess) {
            final phone = _lastPhoneForOtp ?? '';
            if (_awaitingOtpVerification && phone.isNotEmpty) {
              _awaitingOtpVerification = false;
              _lastPhoneForOtp = null;
              await _showOtpDialog(phone);
            } else {
              context.read<ProfileBloc>().add(ProfileGet());
            }
          } else if (state is ProfileFailed) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading || state is ProfileInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ProfileLoaded) {
              final p = state.profile;
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Name:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  p.name,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Email:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  p.email,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Phone:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  p.phone,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Default Address',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  p.defaultAddress.isEmpty
                                      ? 'Not set'
                                      : p.defaultAddress,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 16),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: TextButton.icon(
                                    onPressed: () => Navigator.pushNamed(
                                      context,
                                      '/addresses',
                                    ),
                                    icon: const Icon(Icons.edit),
                                    label: const Text('Change'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Other Addresses',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Address selection/editing happens in AddressPage for now.
                        const Text('Manage addresses in the Addresses page.'),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: 220,
                          child: ElevatedButton.icon(
                            onPressed: () => _showEditProfileDialog(p),
                            icon: const Icon(Icons.edit),
                            label: const Text('Edit profile'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: 220,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              context.read<ProfileBloc>().add(
                                const ProfileDelete(
                                  ProfileDeleteModel(
                                    reason: 'User requested account deletion',
                                    option: 'delete',
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.delete_forever),
                            label: const Text('Delete profile'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            if (state is ProfileFailed) {
              return Center(child: Text(state.message));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
