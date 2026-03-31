import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickmartrider/features/auth/bloc/auth_bloc.dart';
import 'package:quickmartrider/features/auth/bloc/auth_event.dart';
import 'package:quickmartrider/features/auth/bloc/auth_state.dart';
import 'package:quickmartrider/features/auth/data/rider_model.dart';
import 'package:quickmartrider/features/auth/data/rider_otp_model.dart';

class RiderRegisterPage extends StatefulWidget {
  const RiderRegisterPage({super.key});

  @override
  State<RiderRegisterPage> createState() => _RiderRegisterPageState();
}

class _RiderRegisterPageState extends State<RiderRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  final _addressCtrl = TextEditingController();
  final _bikeModelCtrl = TextEditingController();
  final _bikeNumberCtrl = TextEditingController();
  final _bikeColorCtrl = TextEditingController();

  String? _bikeType;

  RiderPickedFile? _rcBookFile;
  RiderPickedFile? _citizenshipFile;
  RiderPickedFile? _panCardFile;
  RiderPickedFile? _bikeInsuranceFile;

  bool _awaitingOtp = false;
  String? _pendingPhone;

  @override
  void initState() {
    super.initState();
    _bikeType = 'bike';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _bikeModelCtrl.dispose();
    _bikeNumberCtrl.dispose();
    _bikeColorCtrl.dispose();
    super.dispose();
  }

  Future<RiderPickedFile?> _pickAnyFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.any,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return null;

    final file = result.files.single;
    final bytes = file.bytes;
    final filename = file.name;
    if (bytes == null || filename.isEmpty) return null;

    return RiderPickedFile(bytes: bytes, filename: filename);
  }

  Future<String?> _showOtpDialog() async {
    final otpCtrl = TextEditingController();

    return showDialog<String>(
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
                Navigator.pop(context, otp);
              },
              child: const Text('Okay'),
            ),
          ],
        );
      },
    );
  }

  void _submitRegister() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_rcBookFile == null ||
        _citizenshipFile == null ||
        _panCardFile == null ||
        _bikeInsuranceFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select all required documents')),
      );
      return;
    }

    final phone = _phoneCtrl.text.trim();
    _pendingPhone = phone;

    context.read<RiderAuthBloc>().add(
          RiderRegisterRequested(
            RiderRegistrationModel(
              name: _nameCtrl.text.trim(),
              number: phone,
              email: _emailCtrl.text.trim(),
              rating: 0.0,
              rcBook: _rcBookFile!,
              citizenship: _citizenshipFile!,
              panCard: _panCardFile!,
              address: _addressCtrl.text.trim(),
              bikeModel: _bikeModelCtrl.text.trim(),
              bikeNumber: _bikeNumberCtrl.text.trim(),
              bikeColor: _bikeColorCtrl.text.trim(),
              type: _bikeType ?? 'bike',
              bikeInsurancePaper: _bikeInsuranceFile!,
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    const bikeTypes = ['bike', 'scooter', 'cycle'];

    return Scaffold(
      body: BlocListener<RiderAuthBloc, RiderAuthState>(
        listener: (context, state) async {
          if (state is RiderAuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }

          if (state is RiderAuthSuccess) {
            if (state.message == 'verify otp' && !_awaitingOtp) {
              if (_pendingPhone == null) return;
              _awaitingOtp = true;
              final otp = await _showOtpDialog();
              if (!mounted) return;

              if (otp != null) {
                context.read<RiderAuthBloc>().add(
                      RiderRegistrationOtpRequested(
                        RiderOtpModel(phone: _pendingPhone!, otp: otp),
                      ),
                    );
              }
              _awaitingOtp = false;
              return;
            }

            if (state.token != null && state.token!.isNotEmpty) {
              Navigator.pushReplacementNamed(context, '/mainapp');
            }
          }
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Card(
                elevation: 4,
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
                          child: Text(
                            'Register',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        TextFormField(
                          controller: _nameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'name',
                            hintText: 'Enter your full name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) {
                            final value = v?.trim() ?? '';
                            if (value.isEmpty) return 'Name is required';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _phoneCtrl,
                          decoration: const InputDecoration(
                            labelText: 'phone (+977)',
                            hintText: '10 digits',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          maxLength: 10,
                          validator: (v) {
                            final value = v?.trim() ?? '';
                            if (value.isEmpty) return 'Phone is required';
                            if (value.length != 10) return 'Phone must be 10 digits';
                            if (!RegExp(r'^\d{10}$').hasMatch(value)) return 'Numbers only';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _emailCtrl,
                          decoration: const InputDecoration(
                            labelText: 'email',
                            hintText: 'Enter your email',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            final value = v?.trim() ?? '';
                            if (value.isEmpty) return 'Email is required';
                            if (!RegExp(r'^[\w.-]+@[\w.-]+\.\w{2,}$').hasMatch(value)) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        _filePickerRow(
                          label: 'Rc Book file',
                          fileName: _rcBookFile?.filename,
                          onPick: () async {
                            final picked = await _pickAnyFile();
                            if (!mounted) return;
                            setState(() => _rcBookFile = picked);
                          },
                        ),
                        const SizedBox(height: 14),
                        _filePickerRow(
                          label: 'Citizenship file',
                          fileName: _citizenshipFile?.filename,
                          onPick: () async {
                            final picked = await _pickAnyFile();
                            if (!mounted) return;
                            setState(() => _citizenshipFile = picked);
                          },
                        ),
                        const SizedBox(height: 14),
                        _filePickerRow(
                          label: 'pan card file',
                          fileName: _panCardFile?.filename,
                          onPick: () async {
                            final picked = await _pickAnyFile();
                            if (!mounted) return;
                            setState(() => _panCardFile = picked);
                          },
                        ),
                        const SizedBox(height: 14),
                        _filePickerRow(
                          label: 'bike insurance paper file',
                          fileName: _bikeInsuranceFile?.filename,
                          onPick: () async {
                            final picked = await _pickAnyFile();
                            if (!mounted) return;
                            setState(() => _bikeInsuranceFile = picked);
                          },
                        ),
                        const SizedBox(height: 14),

                        TextFormField(
                          controller: _addressCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Address',
                            hintText: 'Enter address',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) {
                            final value = v?.trim() ?? '';
                            if (value.isEmpty) return 'Address is required';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _bikeModelCtrl,
                          decoration: const InputDecoration(
                            labelText: 'bike model',
                            hintText: 'Enter bike model',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) {
                            final value = v?.trim() ?? '';
                            if (value.isEmpty) return 'Bike model is required';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _bikeNumberCtrl,
                          decoration: const InputDecoration(
                            labelText: 'bike number',
                            hintText: 'Enter bike number',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) {
                            final value = v?.trim() ?? '';
                            if (value.isEmpty) return 'Bike number is required';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _bikeColorCtrl,
                          decoration: const InputDecoration(
                            labelText: 'bike color',
                            hintText: 'Enter bike color',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) {
                            final value = v?.trim() ?? '';
                            if (value.isEmpty) return 'Bike color is required';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        DropdownButtonFormField<String>(
                          value: _bikeType,
                          decoration: const InputDecoration(
                            labelText: 'type',
                            border: OutlineInputBorder(),
                          ),
                          items: bikeTypes
                              .map(
                                (t) => DropdownMenuItem(
                                  value: t,
                                  child: Text(t),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => _bikeType = v),
                        ),
                        const SizedBox(height: 22),

                        BlocBuilder<RiderAuthBloc, RiderAuthState>(
                          builder: (context, state) {
                            final loading = state is RiderAuthLoading;
                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: loading ? null : _submitRegister,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: loading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text('Register'),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, '/login');
                            },
                            child: const Text('Already have an account? Login'),
                          ),
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

  Widget _filePickerRow({
    required String label,
    required String? fileName,
    required Future<void> Function() onPick,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            fileName ?? 'No file selected',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: () async {
            await onPick();
          },
          icon: const Icon(Icons.attach_file),
          label: Text(label),
        ),
      ],
    );
  }
}

