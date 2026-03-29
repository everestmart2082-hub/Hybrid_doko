import 'package:equatable/equatable.dart';

// ─── Login ─────────────────────────────────────────────────────────────────

class AdminLoginRequest extends Equatable {
  final String phone;

  const AdminLoginRequest({required this.phone});

  Map<String, dynamic> toMap() => {'phone': phone};

  @override
  List<Object?> get props => [phone];
}

// ─── OTP Login ──────────────────────────────────────────────────────────────

class AdminOtpLoginRequest extends Equatable {
  final String phone;
  final String otp;

  const AdminOtpLoginRequest({required this.phone, required this.otp});

  Map<String, dynamic> toMap() => {'phone': phone, 'otp': otp};

  @override
  List<Object?> get props => [phone, otp];
}

// ─── Add Admin ──────────────────────────────────────────────────────────────
// Server reads: c.PostForm("name"), c.PostForm("email"), c.PostForm("number")

class AdminAddRequest extends Equatable {
  final String name;
  final String email;
  final String number;

  const AdminAddRequest({
    required this.name,
    required this.email,
    required this.number,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'email': email,
    'number': number,
  };

  @override
  List<Object?> get props => [name, email, number];
}

// ─── Add Admin OTP ──────────────────────────────────────────────────────────
// Server reads: {"number": ..., "otp": ...}

class AdminAddOtpRequest extends Equatable {
  final String number;
  final String otp;

  const AdminAddOtpRequest({required this.number, required this.otp});

  Map<String, dynamic> toMap() => {'number': number, 'otp': otp};

  @override
  List<Object?> get props => [number, otp];
}

// ─── Auth Token ─────────────────────────────────────────────────────────────

class AdminAuthToken extends Equatable {
  final String token;

  const AdminAuthToken({required this.token});

  factory AdminAuthToken.fromMap(Map<String, dynamic> map) =>
      AdminAuthToken(token: map['token'] as String);

  @override
  List<Object?> get props => [token];
}
