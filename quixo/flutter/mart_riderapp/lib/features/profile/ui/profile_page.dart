import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../data/rider_profile_model.dart';
import '../data/rider_profile_update_model.dart';

class RiderProfilePage extends StatefulWidget {
  const RiderProfilePage({super.key});

  @override
  State<RiderProfilePage> createState() => _RiderProfilePageState();
}

class _RiderProfilePageState extends State<RiderProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _defaultAddressController;
  late TextEditingController _descriptionController;
  late TextEditingController _otpController;
  late TextEditingController _phoneController;

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    context.read<RiderProfileBloc>().add(RiderProfileFetchRequested());
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _defaultAddressController = TextEditingController();
    _descriptionController = TextEditingController();
    _otpController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _defaultAddressController.dispose();
    _descriptionController.dispose();
    _otpController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RiderProfileBloc, RiderProfileState>(
      listener: (context, state) {
        if (state is RiderProfileSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is RiderProfileFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        } else if (state is RiderProfileLoaded && !_isEditing) {
          _nameController.text = state.profile.name;
          _emailController.text = state.profile.email ?? "";
          _defaultAddressController.text = state.profile.defaultAddress ?? "";
        }
      },
      builder: (context, state) {
        if (state is RiderProfileLoading || state is RiderProfileInitial) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is RiderProfileLoaded || _isEditing) {
          return _buildProfileForm(state is RiderProfileLoaded ? state.profile : null);
        } else if (state is RiderProfileFailure) {
          return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildProfileForm(RiderProfileModel? profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Name",
                prefixIcon: Icon(Icons.person),
              ),
              enabled: _isEditing,
              validator: (val) => val == null || val.isEmpty ? "Name required" : null,
            ),
            const SizedBox(height: 16),
            // Email
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                prefixIcon: Icon(Icons.email),
              ),
              enabled: false, // Email not editable
            ),
            const SizedBox(height: 16),
            // Phone
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: "Phone (for OTP update)",
                prefixIcon: Icon(Icons.phone),
              ),
              enabled: true,
            ),
            const SizedBox(height: 16),
            // Default Address
            TextFormField(
              controller: _defaultAddressController,
              decoration: const InputDecoration(
                labelText: "Default Address",
                prefixIcon: Icon(Icons.home),
              ),
              enabled: _isEditing,
            ),
            const SizedBox(height: 16),
            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: "Description",
                prefixIcon: Icon(Icons.info_outline),
              ),
              enabled: _isEditing,
            ),
            const SizedBox(height: 16),
            // OTP field
            TextFormField(
              controller: _otpController,
              decoration: const InputDecoration(
                labelText: "OTP",
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 24),
            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (_isEditing && _formKey.currentState!.validate()) {
                      final model = RiderProfileUpdateModel(
                        number: _phoneController.text.isNotEmpty
                            ? _phoneController.text
                            : profile?.number ?? "",
                        defaultAddress: _defaultAddressController.text,
                        description: _descriptionController.text,
                      );
                      context.read<RiderProfileBloc>().add(RiderProfileUpdateRequested(model));
                    }
                    setState(() => _isEditing = !_isEditing);
                  },
                  child: Text(_isEditing ? "Save" : "Edit"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_otpController.text.isNotEmpty && _phoneController.text.isNotEmpty) {
                      context.read<RiderProfileBloc>().add(
                        RiderProfileOtpRequested(_phoneController.text, _otpController.text),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Enter phone & OTP"),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                  },
                  child: const Text("Verify OTP"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}