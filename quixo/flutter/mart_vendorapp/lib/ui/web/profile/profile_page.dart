import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickmartvender/core/constants/api_constants.dart';
import 'package:quickmartvender/features/profile/bloc/profile_bloc.dart';
import 'package:quickmartvender/features/profile/bloc/profile_event.dart';
import 'package:quickmartvender/features/profile/bloc/profile_state.dart';
import 'package:quickmartvender/features/profile/data/profile_model.dart';
import '../web_shell.dart';
import '../widgets/otp_dialog.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _editing = false;
  bool _updateRequested = false;
  bool _awaitingOtp = false;

  // Edit-form controllers
  final _numberCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _addrCtrl = TextEditingController();
  final _geoCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(LoadProfile());
  }

  @override
  void dispose() {
    _numberCtrl.dispose();
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _addrCtrl.dispose();
    _geoCtrl.dispose();
    super.dispose();
  }

  void _populateControllers(ProfileModel p) {
    _numberCtrl.text = p.number;
    _nameCtrl.text = p.name;
    _descCtrl.text = p.description;
    _addrCtrl.text = p.address;
    _geoCtrl.text = p.geolocation;
  }

  Future<void> _onOtpRequired(String phone) async {
    if (_awaitingOtp) return;
    _awaitingOtp = true;
    final otp = await showOtpDialog(context);
    _awaitingOtp = false;
    if (!mounted || otp == null) return;
    context.read<ProfileBloc>().add(VerifyProfileOtp(phone: phone, otp: otp));
  }

  Future<void> _showSuccessDialog(String msg) async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Success'),
        content: Text(msg),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushReplacementNamed(context, '/mainapp');
            },
            child: const Text('Okay'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WebShell(
      title: 'Profile',
      child: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileOtpRequired) {
            _onOtpRequired(_numberCtrl.text.trim());
          }
          if (state is ProfileUpdateSuccess) {
            setState(() { _editing = false; _updateRequested = true; });
            _showSuccessDialog(state.message);
          }
          if (state is ProfileFailed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ProfileLoaded) {
            if (_editing) {
              return _buildEditForm(state.profile, context);
            }
            return _buildDisplay(state.profile, context);
          }
          if (state is ProfileFailed) {
            return Center(child: Text(state.message));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  // ── Display view ─────────────────────────────────────────────────────────

  Widget _buildDisplay(ProfileModel p, BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Card(
          elevation: 3,
          color: theme.primaryColorLight,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    CircleAvatar(
                      radius: 34,
                      backgroundColor: theme.primaryColorLight,
                      child: Icon(Icons.store, size: 36, color: theme.primaryColor),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.name,
                              style: theme.textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                          Text(p.storeName, style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                    // Status badges
                    Wrap(
                      spacing: 6,
                      children: [
                        _StatusBadge(label: 'Verified', active: true, icon: Icons.verified),
                        if (_updateRequested)
                          _StatusBadge(
                              label: 'Update Requested', active: true, icon: Icons.update),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 28),
                _InfoRow('Phone', p.number, Icons.phone),
                _InfoRow('Email', p.email, Icons.email),
                _InfoRow('Business Type', p.businessType, Icons.business),
                // _InfoRow('PAN', p.pan, Icons.file_copy),
                Image.network(_absolutePhotoUrl(p.pan) ?? ""),
                _InfoRow('Address', p.address, Icons.location_on),
                _InfoRow('Geolocation', p.geolocation, Icons.my_location),
                _InfoRow('Description', p.description, Icons.description),
                const SizedBox(height: 20),
                if (!_updateRequested)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _populateControllers(p);
                        setState(() => _editing = true);
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Profile'),
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14)),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  
  String? _absolutePhotoUrl(String path) {
    final t = path.trim();
    if (t.isEmpty) return null;
    if (t.startsWith('http://') || t.startsWith('https://')) return t;
    final p = t.startsWith('/') ? t : '/$t';
    return '${ApiEndpoints.baseUrl}$p';
  }

  // ── Edit form ─────────────────────────────────────────────────────────────

  Widget _buildEditForm(ProfileModel p, BuildContext context) {
    final formKey = GlobalKey<FormState>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Card(
          elevation: 3,
          color: Theme.of(context).primaryColorLight,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Edit Profile',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  _editField(_numberCtrl, 'Phone Number', '+977 ',
                      keyboardType: TextInputType.phone,
                      validator: (v) {
                        if (v == null || v.trim().length != 10) return '10-digit number required';
                        if (!RegExp(r'^\d{10}$').hasMatch(v.trim())) return 'Numbers only';
                        return null;
                      }),
                  _editField(_nameCtrl, 'Name', null),
                  _editField(_descCtrl, 'Description', null, maxLines: 4),
                  _editField(_addrCtrl, 'Address', null),
                  Row(
                    children: [
                      Expanded(child: _editField(_geoCtrl, 'Geolocation', null)),
                      const SizedBox(width: 8),
                      IconButton.outlined(
                        tooltip: 'Auto-location (enter manually)',
                        onPressed: () => setState(() => _geoCtrl.text = 'Auto'),
                        icon: const Icon(Icons.my_location),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: BlocBuilder<ProfileBloc, ProfileState>(
                          builder: (_, state) => ElevatedButton(
                            onPressed: state is ProfileLoading
                                ? null
                                : () {
                                    if (formKey.currentState!.validate()) {
                                      context.read<ProfileBloc>().add(
                                            UpdateProfile(
                                              profile: ProfileModel(
                                                name: _nameCtrl.text.trim(),
                                                number: _numberCtrl.text.trim(),
                                                pan: p.pan,
                                                storeName: p.storeName,
                                                address: _addrCtrl.text.trim(),
                                                email: p.email,
                                                businessType: p.businessType,
                                                description: _descCtrl.text.trim(),
                                                geolocation: _geoCtrl.text.trim(),
                                              ),
                                            ),
                                          );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14)),
                            child: state is ProfileLoading
                                ? const SizedBox(height: 20, width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Text('Update Profile'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: () => setState(() => _editing = false),
                        style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20)),
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _editField(
    TextEditingController ctrl,
    String label,
    String? prefix, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixText: prefix,
          border: const OutlineInputBorder(),
        ),
        validator: validator ?? (v) => (v == null || v.trim().isEmpty) ? '$label is required' : null,
      ),
    );
  }
}

// ── Sub-widgets ─────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _InfoRow(this.label, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Theme.of(context).hintColor),
          const SizedBox(width: 10),
          SizedBox(width: 130, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.w600))),
          Expanded(child: Text(value.isEmpty ? '—' : value)),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final bool active;
  final IconData icon;
  const _StatusBadge({required this.label, required this.active, required this.icon});

  @override
  Widget build(BuildContext context) {
    final color = active ? Colors.green : Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
