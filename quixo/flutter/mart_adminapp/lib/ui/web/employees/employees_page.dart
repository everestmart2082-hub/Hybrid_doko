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

class _AdminEmployeesPageState extends State<AdminEmployeesPage> {
  static const int _perPage = 10;

  int _page = 0;
  List<AdminEmployeeModel> _employees = const [];

  // Add form
  final _addFormKey = GlobalKey<FormState>();
  final _addName = TextEditingController();
  final _addPosition = TextEditingController();
  final _addSalary = TextEditingController();
  final _addAddress = TextEditingController();
  final _addEmail = TextEditingController();
  final _addPhone = TextEditingController();
  final _addBankName = TextEditingController();
  final _addAccountNumber = TextEditingController();
  final _addPan = TextEditingController();
  MultipartFile? _addCitizenshipFile;

  // Edit form
  final _editFormKey = GlobalKey<FormState>();
  final _editName = TextEditingController();
  final _editPosition = TextEditingController();
  final _editSalary = TextEditingController();
  final _editAddress = TextEditingController();
  final _editEmail = TextEditingController();
  final _editPhone = TextEditingController();
  final _editBankName = TextEditingController();
  final _editAccountNumber = TextEditingController();
  final _editIfscCode = TextEditingController();
  MultipartFile? _editCitizenshipFile;

  bool _otpDialogOpen = false;

  @override
  void initState() {
    super.initState();
    context.read<AdminEmployeeBloc>().add(AdminEmployeeLoad());
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

  void _openAddDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).primaryColorLight,
          title: const Text('Add Employee'),
          content: SingleChildScrollView(
            child: Form(
              key: _addFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildField(controller: _addPosition, label: 'position'),
                  const SizedBox(height: 8),
                  _buildField(
                    controller: _addSalary,
                    label: 'salary',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 8),
                  _buildField(controller: _addName, label: 'name'),
                  const SizedBox(height: 8),
                  _buildField(controller: _addAddress, label: 'address'),
                  const SizedBox(height: 8),
                  _buildField(
                    controller: _addEmail,
                    label: 'email',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 8),
                  _buildField(
                    controller: _addPhone,
                    label: 'phone',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 8),
                  _buildField(controller: _addBankName, label: 'bank name'),
                  const SizedBox(height: 8),
                  _buildField(
                      controller: _addAccountNumber, label: 'account number'),
                  const SizedBox(height: 8),
                  _buildField(controller: _addPan, label: 'pan (text)'),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('citizenship file'),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _addCitizenshipFile?.filename ??
                                    'No file selected',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton(
                              onPressed: () async {
                                final f = await _pickCitizenship();
                                setState(() => _addCitizenshipFile = f);
                              },
                              child: const Text('select'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _submitAdd,
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
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
    Navigator.of(context).pop();
  }

  void _openEditDialog(AdminEmployeeModel e) {
    _editName.text = e.name;
    _editPosition.text = e.position;
    _editSalary.text = e.salary.toString();
    _editAddress.text = e.address;
    _editEmail.text = e.email;
    _editPhone.text = e.phone;
    _editBankName.text = e.bankName;
    _editAccountNumber.text = e.accountNumber;
    _editIfscCode.text = '';
    _editCitizenshipFile = null;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).primaryColorLight,
          title: const Text('Edit Employee'),
          content: SingleChildScrollView(
            child: Form(
              key: _editFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildField(controller: _editPosition, label: 'position'),
                  const SizedBox(height: 8),
                  _buildField(
                    controller: _editSalary,
                    label: 'salary',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 8),
                  _buildField(controller: _editName, label: 'name'),
                  const SizedBox(height: 8),
                  _buildField(controller: _editAddress, label: 'address'),
                  const SizedBox(height: 8),
                  _buildField(
                    controller: _editEmail,
                    label: 'email',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 8),
                  _buildField(
                    controller: _editPhone,
                    label: 'phone',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 8),
                  _buildField(controller: _editBankName, label: 'bank name'),
                  const SizedBox(height: 8),
                  _buildField(
                      controller: _editAccountNumber, label: 'account number'),
                  const SizedBox(height: 8),
                  _buildField(controller: _editIfscCode, label: 'ifsc code'),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('citizenship file (optional)'),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _editCitizenshipFile?.filename ??
                                    'No file selected',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton(
                              onPressed: () async {
                                final f = await _pickCitizenship();
                                setState(() => _editCitizenshipFile = f);
                              },
                              child: const Text('select'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _submitEdit,
              child: const Text('Verify OTP'),
            ),
          ],
        );
      },
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
    Navigator.of(context).pop();
  }

  void _deleteEmployee(AdminEmployeeModel e) {
    context.read<AdminEmployeeBloc>().add(AdminEmployeeDelete(e.id));
  }

  @override
  Widget build(BuildContext context) {
    return WebShell(
      title: 'Employees',
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
            // Refresh list after any action
            context.read<AdminEmployeeBloc>().add(AdminEmployeeLoad());
          } else if (state is AdminEmployeeFailed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is AdminEmployeeListLoaded) {
            setState(() => _employees = state.employees);
          }
        },
        child: Builder(
          builder: (context) {
            final totalPages =
                (_employees.length / _perPage).ceil().clamp(1, 999999);
            final page = _page.clamp(0, totalPages - 1);
            final start = page * _perPage;
            final end = (start + _perPage).clamp(0, _employees.length);
            final items = _employees.sublist(start, end);

            return Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Text(
                        'Employees',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: _openAddDialog,
                        child: const Text('Add Employee'),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: _employees.isEmpty
                      ? const Center(child: Text('No employees found.'))
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemBuilder: (context, index) {
                            final e = items[index];
                            return _EmployeeCard(
                              employee: e,
                              onEdit: () => _openEditDialog(e),
                              onDelete: () => _deleteEmployee(e),
                            );
                          },
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemCount: items.length,
                        ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      TextButton(
                        onPressed: page > 0
                            ? () => setState(() => _page = page - 1)
                            : null,
                        child: Text('Prev', style: Theme.of(context).textTheme.bodyMedium,),
                      ),
                      const SizedBox(width: 8),
                      Text('${page + 1} / $totalPages', style: Theme.of(context).textTheme.bodyMedium),
                      const Spacer(),
                      TextButton(
                        onPressed: page < totalPages - 1
                            ? () => setState(() => _page = page + 1)
                            : null,
                        child: Text('Next', style: Theme.of(context).textTheme.bodyMedium,),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
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
      style: Theme.of(context).textTheme.bodyMedium,
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: Theme.of(context).textTheme.bodyMedium,
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

class _EmployeeCard extends StatelessWidget {
  final AdminEmployeeModel employee;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _EmployeeCard({
    required this.employee,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).primaryColorLight,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    employee.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Text(employee.position, style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
            const SizedBox(height: 4),
            Text('${employee.email} | ${employee.phone}', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text(employee.address, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text(
                'Salary: ${employee.salary.toStringAsFixed(2)} | Bank: ${employee.bankName} | Acc: ${employee.accountNumber}', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: [
                Chip(
                  label: Text(
                      'suspended: ${employee.suspended ? 'yes' : 'no'}'),
                ),
                if (employee.citizenshipFile.isNotEmpty)
                  const Chip(label: Text('citizenship file')),
                if (employee.panFile.isNotEmpty)
                  const Chip(label: Text('pan file')),
              ],
            ),
            const SizedBox(height: 8),
            if (employee.violations.isNotEmpty) ...[
              const Text(
                'Violations:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: employee.violations
                    .map(
                      (v) => Chip(
                        label: Text(v.toString()),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                ElevatedButton(
                  onPressed: onEdit,
                  child: const Text('Edit'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: onDelete,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

