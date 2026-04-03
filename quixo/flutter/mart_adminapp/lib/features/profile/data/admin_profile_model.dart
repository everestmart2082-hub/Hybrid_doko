import 'package:equatable/equatable.dart';

// ─── Profile Response ───────────────────────────────────────────────────────
// Server returns: {"name":..., "number":..., "email":...}

class AdminProfile extends Equatable {
  final String name;
  final String number;
  final String email;

  const AdminProfile({
    required this.name,
    required this.number,
    required this.email,
  });

  factory AdminProfile.fromMap(Map<String, dynamic> map) => AdminProfile(
        name: map['name'] as String? ?? '',
        number: map['number'] as String? ?? '',
        email: map['email'] as String? ?? '',
      );

  @override
  List<Object?> get props => [name, number, email];
}

// ─── Update Request ─────────────────────────────────────────────────────────
// Server reads: c.PostForm("name"), "number", "description", "address"

class AdminProfileUpdateRequest extends Equatable {
  final String name;
  final String number;
  final String email;

  const AdminProfileUpdateRequest({
    required this.name,
    required this.number,
    required this.email

  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'number': number,
        'email': email,
      };

  @override
  List<Object?> get props => [name, number, email];
}

// ─── Delete Request ─────────────────────────────────────────────────────────
// Server reads: c.PostForm("reason"), c.PostForm("options") — "delete" | "suspend"

class AdminProfileDeleteRequest extends Equatable {
  final String reason;
  final String option; // "delete" or "suspend"

  const AdminProfileDeleteRequest({required this.reason, required this.option});

  Map<String, dynamic> toMap() => {'reason': reason, 'options': option};

  @override
  List<Object?> get props => [reason, option];
}
