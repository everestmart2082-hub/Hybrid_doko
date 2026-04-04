import 'package:equatable/equatable.dart';

// ─── Employee Model ──────────────────────────────────────────────────────────
// Mirrors server models.Employee

class AdminEmployeeModel extends Equatable {
  final String id;
  final String name;
  final String position;
  final double salary;
  final String address;
  final String email;
  final String phone;
  final String citizenshipFile;
  final String bankName;
  final String accountNumber;
  final String panFile;
  final bool suspended;
  final List<dynamic> violations;

  const AdminEmployeeModel({
    required this.id,
    required this.name,
    required this.position,
    required this.salary,
    required this.address,
    required this.email,
    required this.phone,
    required this.citizenshipFile,
    required this.bankName,
    required this.accountNumber,
    required this.panFile,
    required this.suspended,
    required this.violations,
  });

  factory AdminEmployeeModel.fromMap(Map<String, dynamic> map) =>
      AdminEmployeeModel(
        id: map['_id']?.toString() ?? map['id']?.toString() ?? '',
        name: map['name'] as String? ?? '',
        position: map['position'] as String? ?? '',
        salary: num.tryParse(map['salary']?.toString() ?? '')?.toDouble() ?? 0.0,
        address: map['address'] as String? ?? '',
        email: map['email'] as String? ?? '',
        phone: map['phone'] as String? ?? '',
        citizenshipFile: map['citizenship_file'] as String? ?? '',
        bankName: map['bank_name'] as String? ?? '',
        accountNumber: map['account_number'] as String? ?? '',
        panFile: map['pan_file'] as String? ?? '',
        suspended: map['suspended'] as bool? ?? false,
        violations: (map['violations'] as List<dynamic>?) ?? [],
      );

  @override
  List<Object?> get props => [
        id, name, position, salary, address, email, phone,
        citizenshipFile, bankName, accountNumber, panFile, suspended, violations,
      ];
}

// ─── Add Request ─────────────────────────────────────────────────────────────
// Server reads: c.PostForm("name"), "position", "salary", "address", "email",
//               "phone", "bank name", "account number", "pan"
// File: c.FormFile("citizenship")

class AdminEmployeeAddRequest extends Equatable {
  final String name;
  final String position;
  final double salary;
  final String address;
  final String email;
  final String phone;
  final String bankName;
  final String accountNumber;
  final String pan; // PAN number stored as text

  const AdminEmployeeAddRequest({
    required this.name,
    required this.position,
    required this.salary,
    required this.address,
    required this.email,
    required this.phone,
    required this.bankName,
    required this.accountNumber,
    required this.pan,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'position': position,
        'salary': salary.toString(),
        'address': address,
        'email': email,
        'phone': phone,
        'bank name': bankName,        // exact server field name (with space)
        'account number': accountNumber, // exact server field name (with space)
        'pan': pan,
      };

  @override
  List<Object?> get props => [
        name, position, salary, address, email, phone, bankName,
        accountNumber, pan,
      ];
}

// ─── Update Request ──────────────────────────────────────────────────────────
// Server reads: same field names + "ifsc code"

class AdminEmployeeUpdateRequest extends Equatable {
  final String name;
  final String position;
  final double salary;
  final String address;
  final String email;
  final String phone;
  final String bankName;
  final String accountNumber;
  final String ifscCode;
  final String pan;

  const AdminEmployeeUpdateRequest({
    required this.name,
    required this.position,
    required this.salary,
    required this.address,
    required this.email,
    required this.phone,
    required this.bankName,
    required this.accountNumber,
    required this.ifscCode,
    required this.pan,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'position': position,
        'salary': salary.toString(),
        'address': address,
        'email': email,
        'phone': phone,
        'bank name': bankName,
        'account number': accountNumber,
        'ifsc code': ifscCode,        // exact server field name (with space)
        'pan': pan,
      };

  @override
  List<Object?> get props => [
        name, position, salary, address, email, phone, bankName,
        accountNumber, ifscCode, pan,
      ];
}
