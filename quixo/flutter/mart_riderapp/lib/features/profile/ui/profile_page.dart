import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickmartrider/core/constants/api_constants.dart';
import 'package:quickmartrider/features/profile/bloc/profile_bloc.dart';
import 'package:quickmartrider/features/profile/bloc/profile_event.dart';
import 'package:quickmartrider/features/profile/bloc/profile_state.dart';
import 'package:quickmartrider/features/profile/data/rider_profile_model.dart';
import 'package:quickmartrider/features/profile/data/rider_profile_update_model.dart';
import 'package:quickmartrider/drawer.dart';

class RiderProfilePage extends StatefulWidget {
  const RiderProfilePage({super.key});

  @override
  State<RiderProfilePage> createState() => _RiderProfilePageState();
}

class _RiderProfilePageState extends State<RiderProfilePage> {
  final _otpFormKey = GlobalKey<FormState>();
  final _otpCtrl = TextEditingController();

  String? _phoneForOtp;

  final _editFormKey = GlobalKey<FormState>();
  final _numberCtrl = TextEditingController();
  final _defaultAddressCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<RiderProfileBloc>().add(RiderProfileFetchRequested());
  }

  @override
  void dispose() {
    _otpCtrl.dispose();
    _numberCtrl.dispose();
    _defaultAddressCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<String?> _showOtpDialog() async {
    _otpCtrl.text = '';
    _otpFormKey.currentState?.reset();

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Verify OTP'),
          content: Form(
            key: _otpFormKey,
            child: TextFormField(
              controller: _otpCtrl,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'OTP',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                final value = v?.trim() ?? '';
                if (value.length != 6) return 'OTP must be 6 digits';
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (!(_otpFormKey.currentState?.validate() ?? false)) return;
                Navigator.pop(context, _otpCtrl.text.trim());
              },
              child: const Text('Okay'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditProfileDialog(RiderProfileModel profile) async {
    _numberCtrl.text = profile.number;
    _defaultAddressCtrl.text = profile.defaultAddress ?? '';
    _descriptionCtrl.text = '';

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: Form(
            key: _editFormKey,
            child: SizedBox(
              width: 420,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _numberCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Number',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 10,
                      validator: (v) {
                        final value = v?.trim() ?? '';
                        if (value.isEmpty) return 'Number is required';
                        if (value.length != 10) return 'Number must be 10 digits';
                        if (!RegExp(r'^\d{10}$').hasMatch(value)) return 'Numbers only';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _defaultAddressCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Address',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        final value = v?.trim() ?? '';
                        if (value.isEmpty) return 'Address is required';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descriptionCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Description (optional)',
                        border: OutlineInputBorder(),
                      ),
                      minLines: 1,
                      maxLines: 3,
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
                if (!(_editFormKey.currentState?.validate() ?? false)) return;

                final model = RiderProfileUpdateModel(
                  number: _numberCtrl.text.trim(),
                  defaultAddress: _defaultAddressCtrl.text.trim(),
                  description: _descriptionCtrl.text.trim().isEmpty
                      ? null
                      : _descriptionCtrl.text.trim(),
                );

                _phoneForOtp = model.number;
                context.read<RiderProfileBloc>().add(
                      RiderProfileUpdateRequested(model),
                    );
                Navigator.pop(context);
              },
              child: const Text('Update Profile'),
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
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: Theme.of(context).primaryColorLight),
        ),
      ),
      drawer: buildAppDrawer(context),
      body: BlocListener<RiderProfileBloc, RiderProfileState>(
        listener: (context, state) async {
          if (state is RiderProfileFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }

          if (state is RiderProfileSuccess) {
            if (state.message == 'verify otp') {
              final phone = _phoneForOtp;
              if (phone == null || phone.isEmpty) return;

              final otp = await _showOtpDialog();
              if (!mounted) return;
              if (otp != null) {
                context.read<RiderProfileBloc>().add(
                      RiderProfileOtpRequested(phone, otp),
                    );
              }
              return;
            }

            // After OTP verification, refresh profile so the edit button updates.
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            context.read<RiderProfileBloc>().add(RiderProfileFetchRequested());
          }
        },
        child: BlocBuilder<RiderProfileBloc, RiderProfileState>(
          builder: (context, state) {
            if (state is RiderProfileLoading || state is RiderProfileInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is RiderProfileLoaded) {
              final profile = state.profile;
              final editDisabled = profile.updationRequested;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                'name: ${profile.name}',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 10),
                              Text('number: ${profile.number}', style: Theme.of(context).textTheme.bodyMedium),
                              const SizedBox(height: 6),
                              Text('email: ${profile.email ?? ''}', style: Theme.of(context).textTheme.bodyMedium),
                              const SizedBox(height: 6),
                              Text(
                                'Address: ${profile.defaultAddress ?? ''}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 6),
                              Text('bikeDetail: ${profile.bikeDetail ?? ''}', style: Theme.of(context).textTheme.bodyMedium),
                              const SizedBox(height: 14),
                              const Divider(),
                              const SizedBox(height: 10),
                              Text('verified: ${profile.verified}', style: Theme.of(context).textTheme.bodyMedium),
                              const SizedBox(height: 6),
                              Text('updation requested: ${profile.updationRequested}', style: Theme.of(context).textTheme.bodyMedium),
                              const SizedBox(height: 14),
                              const Divider(),
                              const SizedBox(height: 10),
                              Text('Rc Book file:', style: Theme.of(context).textTheme.bodySmall),
                              Image.network(_absolutePhotoUrl(profile.blueBookUrl ?? "") ?? ""),
                              const SizedBox(height: 6),
                              Text(
                                'Citizenship file:',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Image.network(_absolutePhotoUrl(profile.citizenshipUrl ?? "") ?? ""),
                              const SizedBox(height: 6),
                              Text(
                                'pan card file:',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Image.network(_absolutePhotoUrl(profile.panCardUrl ?? "") ?? ""),
                              const SizedBox(height: 6),
                              Text(
                                'bike insurance paper file:',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Image.network(_absolutePhotoUrl(profile.insurancePaperUrl ?? "") ?? ""),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: 220,
                        child: ElevatedButton.icon(
                          onPressed: editDisabled
                              ? null
                              : () => _showEditProfileDialog(profile),
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit Profile'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is RiderProfileFailure) {
              return Center(
                child: Text(
                  state.message,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  
  String? _absolutePhotoUrl(String path) {
    final t = path.trim();
    if (t.isEmpty) return null;
    if (t.startsWith('http://') || t.startsWith('https://')) return t;
    final p = t.startsWith('/') ? t : '/$t';
    return '${ApiEndpoints.baseImageUrl}$p';
  }

}
