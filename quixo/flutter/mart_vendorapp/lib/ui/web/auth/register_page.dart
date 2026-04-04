import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quickmartvender/features/auth/bloc/auth_bloc.dart';
import 'package:quickmartvender/features/auth/bloc/auth_event.dart';
import 'package:quickmartvender/features/auth/bloc/auth_state.dart';
import 'package:quickmartvender/features/auth/data/auth_model.dart';
import 'package:quickmartvender/features/auth/data/business_type_model.dart';
import 'package:quickmartvender/features/auth/data/otp_verify_model.dart';
import '../widgets/otp_dialog.dart';

class VenderRegisterPage extends StatefulWidget {
  const VenderRegisterPage({super.key});

  @override
  State<VenderRegisterPage> createState() => _VenderRegisterPageState();
}

class _VenderRegisterPageState extends State<VenderRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _storeName = TextEditingController();
  final _address = TextEditingController();
  final _description = TextEditingController();
  final _geolocation = TextEditingController();

  String? _selectedBizType;
  List<BusinessTypeModel> _bizTypes = [];
  XFile? _panFile;
  bool _loadingBizTypes = false;
  bool _awaitingOtp = false;

  @override
  void initState() {
    super.initState();
    _fetchBizTypes();
  }

  void _fetchBizTypes() {
    setState(() => _loadingBizTypes = true);
    context.read<VenderAuthBloc>().add(VenderFetchBusinessTypes());
  }

  @override
  void dispose() {
    _name.dispose(); _phone.dispose(); _email.dispose();
    _storeName.dispose(); _address.dispose(); _description.dispose();
    _geolocation.dispose();
    super.dispose();
  }

  Future<void> _pickPan() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) setState(() => _panFile = file);
  }

  Future<void> _useAutoLocation() async {
    // geolocator not installed — prompt user to enter manually
    setState(() => _geolocation.text = 'Location entered manually');
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedBizType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a Business Type')),
        );
        return;
      }
      final input = VenderAuthModel(
        name: _name.text.trim(),
        number: _phone.text.trim(),
        pan: _panFile?.name ?? '',
        storeName: _storeName.text.trim(),
        address: _address.text.trim(),
        email: _email.text.trim(),
        businessType: _selectedBizType!,
        description: _description.text.trim(),
        geolocation: _geolocation.text.trim(),
      );
      List<MultipartFile> files = [];
      context.read<VenderAuthBloc>().add(VenderRegister(input: input, files: files));
    }
  }

  Future<void> _showOtpAndVerify() async {
    final otp = await showOtpDialog(context);
    if (!mounted || otp == null) return;
    context.read<VenderAuthBloc>().add(
          VenderRegisterOtpVerify(
            input: VenderOtpVerifyModel(
              phone: _phone.text.trim(),
              otp: otp,
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorLight,
      body: BlocListener<VenderAuthBloc, VenderAuthState>(
        listener: (context, state) {
          if (state is VenderBusinessTypesLoaded) {
            setState(() {
              _bizTypes = List<BusinessTypeModel>.from(state.businessTypes);
              _loadingBizTypes = false;
            });
          }
          if (state is VenderAuthOtpStep && state.forRegistration && !_awaitingOtp) {
            _awaitingOtp = true;
            _showOtpAndVerify().then((_) => _awaitingOtp = false);
          }
          if (state is VenderAuthenticated && state.authenticated) {
            Navigator.pushReplacementNamed(context, '/mainapp');
          }
          if (state is VenderAuthFailed) {
            setState(() => _loadingBizTypes = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
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
                          child: Text('Register',
                              style: theme.textTheme.headlineMedium
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 28),
                        _field(_name, 'Name', 'Enter your full name'),
                        const SizedBox(height: 14),
                        _field(_phone, 'Phone Number', '10-digit phone',
                            prefix: '+977 ',
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            validator: (v) {
                              if (v == null || v.trim().length != 10) return '10-digit number required';
                              if (!RegExp(r'^\d{10}$').hasMatch(v.trim())) return 'Numbers only';
                              return null;
                            }),
                        const SizedBox(height: 14),
                        _field(_email, 'Email', 'Enter your email',
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || !RegExp(r'^[\w.-]+@[\w.-]+\.\w{2,}$').hasMatch(v.trim())) {
                                return 'Enter a valid email';
                              }
                              return null;
                            }),
                        const SizedBox(height: 14),
                        // PAN file picker
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _panFile != null ? _panFile!.name : 'No PAN file chosen',
                                style: theme.textTheme.bodyMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton.icon(
                              onPressed: _pickPan,
                              icon: const Icon(Icons.attach_file),
                              label: const Text('PAN'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _field(_storeName, 'Store Name', 'Enter your store name'),
                        const SizedBox(height: 14),
                        _field(_address, 'Address', 'Enter address'),
                        const SizedBox(height: 14),
                        // Business Type dropdown
                        _loadingBizTypes
                            ? const Center(child: CircularProgressIndicator())
                            : DropdownButtonFormField<String>(
                                value: _selectedBizType,
                                hint: const Text('Select Business Type'),
                                decoration: const InputDecoration(
                                  labelText: 'Business Type',
                                  border: OutlineInputBorder(),
                                ),
                                items: _bizTypes
                                    .map((e) => DropdownMenuItem(
                                          value: e.name,
                                          child: Text(e.name),
                                        ))
                                    .toList(),
                                onChanged: (v) => setState(() => _selectedBizType = v),
                              ),
                        const SizedBox(height: 14),
                        _field(_description, 'Description', 'Describe your business',
                            maxLines: 4),
                        const SizedBox(height: 14),
                        // Geolocation
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _geolocation,
                                decoration: const InputDecoration(
                                  labelText: 'Geolocation',
                                  border: OutlineInputBorder(),
                                  hintText: 'lat,lng or description',
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton.outlined(
                              tooltip: 'Use auto-location',
                              onPressed: _useAutoLocation,
                              icon: const Icon(Icons.my_location),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        BlocBuilder<VenderAuthBloc, VenderAuthState>(
                          builder: (context, state) {
                            final loading = state is VenderAuthLoading;
                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: loading ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                child: loading
                                    ? const SizedBox(height: 20, width: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                    : const Text('Register'),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: TextButton(
                            onPressed: () =>
                                Navigator.pushReplacementNamed(context, '/login'),
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

  Widget _field(
    TextEditingController ctrl,
    String label,
    String hint, {
    String? prefix,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixText: prefix,
        border: const OutlineInputBorder(),
        counterText: '',
      ),
      validator: validator ??
          (v) {
            if (v == null || v.trim().isEmpty) return '$label is required';
            return null;
          },
    );
  }
}
