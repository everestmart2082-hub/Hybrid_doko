import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mart_adminapp/features/employee/bloc/admin_employee_bloc.dart';
import 'package:mart_adminapp/features/employee/bloc/admin_employee_event.dart';
import 'package:mart_adminapp/features/employee/bloc/admin_employee_state.dart';
import 'package:mart_adminapp/features/employee/data/admin_employee_model.dart';
import 'package:mart_adminapp/ui/web/web_shell.dart';
import 'package:mart_adminapp/ui/web/widgets/otp_dialog.dart';

class AdminEmployeesPage extends StatefulWidget {
  const AdminEmployeesPage({super.key});

  @override
  State<AdminEmployeesPage> createState() => _AdminEmployeesPageState();
}

class _AdminEmployeesPageState extends State<AdminEmployeesPage>
    with SingleTickerProviderStateMixin {
  final _addFormKey = GlobalKey<FormState>();
  final _editFormKey = GlobalKey<FormState>();

  final _addName = TextEditingController();
  final _addPosition = TextEditingController();
  final _addSalary = TextEditingController();
  final _addAddress = TextEditingController();
  final _addEmail = TextEditingController();
  final _addPhone = TextEditingController();
  final _addBankName = TextEditingController();
  final _addAccountNumber = TextEditingController();
  final _addPan = TextEditingController();

  final _editName = TextEditingController();
  final _editPosition = TextEditingController();
  final _editSalary = TextEditingController();
  final _editAddress = TextEditingController();
  final _editEmail = TextEditingController();
  final _editPhone = TextEditingController();
  final _editBankName = TextEditingController();
  final _editAccountNumber = TextEditingController();
  final _editIfscCode = TextEditingController();

  MultipartFile? _addCitizenshipFile;
  MultipartFile? _editCitizenshipFile;

  bool _otpDialogOpen = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _addName.dispose();
    _addPosition.dispose();
    _addSalary.dispose();
    _addAddress.dispose();
    _addEmail.dispose();
    _addPhone.dispose();
    _addBankName.dispose();
    _addAccountNumber.dispose();
    _addPan.dispose();

    _editName.dispose();
    _editPosition.dispose();
    _editSalary.dispose();
    _editAddress.dispose();
    _editEmail.dispose();
    _editPhone.dispose();
    _editBankName.dispose();
    _editAccountNumber.dispose();
    _editIfscCode.dispose();
    super.dispose();
  }

  Future<MultipartFile?> _pickCitizenship() async {
    final res = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.any,
      withData: true,
    );
    if (res == null || res.files.isEmpty) return null;
    final file = res.files.single;
    final bytes = file.bytes;
    if (bytes == null) return null;
    return MultipartFile.fromBytes(bytes, filename: file.name);
  }

  void _submitAdd() {
    if (!(_addFormKey.currentState?.validate() ?? false)) return;
    final salary = double.tryParse(_addSalary.text.trim()) ?? 0;
    final req = AdminEmployeeAddRequest(
      name: _addName.text.trim(),
      position: _addPosition.text.trim(),
      salary: salary,
      address: _addAddress.text.trim(),
      email: _addEmail.text.trim(),
      phone: _addPhone.text.trim(),
      bankName: _addBankName.text.trim(),
      accountNumber: _addAccountNumber.text.trim(),
      pan: _addPan.text.trim(),
    );
    context.read<AdminEmployeeBloc>().add(
          AdminEmployeeAdd(req: req, citizenshipFile: _addCitizenshipFile),
        );
  }

  void _submitEdit() {
    if (!(_editFormKey.currentState?.validate() ?? false)) return;
    final salary = double.tryParse(_editSalary.text.trim()) ?? 0;
    final req = AdminEmployeeUpdateRequest(
      name: _editName.text.trim(),
      position: _editPosition.text.trim(),
      salary: salary,
      address: _editAddress.text.trim(),
      email: _editEmail.text.trim(),
      phone: _editPhone.text.trim(),
      bankName: _editBankName.text.trim(),
      accountNumber: _editAccountNumber.text.trim(),
      ifscCode: _editIfscCode.text.trim(),
    );
    context.read<AdminEmployeeBloc>().add(
          AdminEmployeeUpdate(req: req, citizenshipFile: _editCitizenshipFile),
        );
  }

  @override
  Widget build(BuildContext context) {
    return WebShell(
      title: 'Employees',
      child: DefaultTabController(
        length: 2,
        child: BlocListener<AdminEmployeeBloc, AdminEmployeeState>(
          listener: (context, state) async {
            if (state is AdminEmployeeOtpRequired && !_otpDialogOpen) {
              _otpDialogOpen = true;
              final otp = await showOtpDialog(context);
              if (otp != null && context.mounted) {
                context.read<AdminEmployeeBloc>().add(
                      AdminEmployeeUpdateOtpVerify(
                        phone: state.phone,
                        otp: otp,
                      ),
                    );
              }
              _otpDialogOpen = false;
            } else if (state is AdminEmployeeActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            } else if (state is AdminEmployeeFailed) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: Column(
            children: [
              const TabBar(
                tabs: [
                  Tab(text: 'Add Employee'),
                  Tab(text: 'Edit Employee'),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: TabBarView(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 720),
                        child: Form(
                          key: _addFormKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Add Employee page',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 14),
                              _buildField(controller: _addPosition, label: 'position'),
                              const SizedBox(height: 12),
                              _buildField(controller: _addSalary, label: 'salary', keyboardType: TextInputType.number),
                              const SizedBox(height: 12),
                              _buildField(controller: _addName, label: 'name'),
                              const SizedBox(height: 12),
                              _buildField(controller: _addAddress, label: 'address'),
                              const SizedBox(height: 12),
                              _buildField(controller: _addEmail, label: 'email', keyboardType: TextInputType.emailAddress),
                              const SizedBox(height: 12),
                              _buildField(controller: _addPhone, label: 'phone', keyboardType: TextInputType.phone),
                              const SizedBox(height: 12),
                              _buildField(controller: _addBankName, label: 'bank name'),
                              const SizedBox(height: 12),
                              _buildField(controller: _addAccountNumber, label: 'account number'),
                              const SizedBox(height: 12),
                              _buildField(controller: _addPan, label: 'pan (text)'),
                              const SizedBox(height: 12),
                              const Text('citizenship file'),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _addCitizenshipFile?.filename ?? 'No file selected',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  OutlinedButton(
                                    onPressed: () async {
                                      final f = await _pickCitizenship();
                                      setState(() => _addCitizenshipFile = f);
                                    },
                                    child: const Text('select file'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () => _submitAdd(),
                                  child: const Text('Add Employee'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 720),
                        child: Form(
                          key: _editFormKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Edit Employee page',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 14),
                              _buildField(controller: _editPosition, label: 'position'),
                              const SizedBox(height: 12),
                              _buildField(controller: _editSalary, label: 'salary', keyboardType: TextInputType.number),
                              const SizedBox(height: 12),
                              _buildField(controller: _editName, label: 'name'),
                              const SizedBox(height: 12),
                              _buildField(controller: _editAddress, label: 'address'),
                              const SizedBox(height: 12),
                              _buildField(controller: _editEmail, label: 'email', keyboardType: TextInputType.emailAddress),
                              const SizedBox(height: 12),
                              _buildField(controller: _editPhone, label: 'phone', keyboardType: TextInputType.phone),
                              const SizedBox(height: 12),
                              _buildField(controller: _editBankName, label: 'bank name'),
                              const SizedBox(height: 12),
                              _buildField(controller: _editAccountNumber, label: 'account number'),
                              const SizedBox(height: 12),
                              _buildField(controller: _editIfscCode, label: 'ifsc code'),
                              const SizedBox(height: 12),
                              const Text('citizenship file (optional)'),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _editCitizenshipFile?.filename ?? 'No file selected',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  OutlinedButton(
                                    onPressed: () async {
                                      final f = await _pickCitizenship();
                                      setState(() => _editCitizenshipFile = f);
                                    },
                                    child: const Text('select file'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () => _submitEdit(),
                                  child: const Text('Update Employee'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (v) {
        final value = v?.trim() ?? '';
        if (value.isEmpty) return '$label is required';
        return null;
      },
    );
  }
}

