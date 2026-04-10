import 'package:equatable/equatable.dart';

// ─── Inbox (contact / system messages on admin document) ─────────────────────

class AdminInboxMessage extends Equatable {
  final String type;
  final String date;
  final String message;

  const AdminInboxMessage({
    required this.type,
    required this.date,
    required this.message,
  });

  factory AdminInboxMessage.fromMap(Map<String, dynamic> map) =>
      AdminInboxMessage(
        type: map['type']?.toString() ?? '',
        date: map['date']?.toString() ?? '',
        message: map['message']?.toString() ?? map['description']?.toString() ?? '',
      );

  @override
  List<Object?> get props => [type, date, message];
}

// ─── Profile Response ───────────────────────────────────────────────────────
// Server returns: {"name":..., "number":..., "email":..., "messages": [...]}

class AdminProfile extends Equatable {
  final String name;
  final String number;
  final String email;
  final List<AdminInboxMessage> messages;

  const AdminProfile({
    required this.name,
    required this.number,
    required this.email,
    this.messages = const [],
  });

  factory AdminProfile.fromMap(Map<String, dynamic> map) {
    final raw = map['messages'];
    final List<AdminInboxMessage> msgs = [];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map) {
          msgs.add(
              AdminInboxMessage.fromMap(Map<String, dynamic>.from(e)));
        }
      }
    }
    return AdminProfile(
      name: map['name'] as String? ?? '',
      number: map['number'] as String? ?? '',
      email: map['email'] as String? ?? '',
      messages: msgs,
    );
  }

  @override
  List<Object?> get props => [name, number, email, messages];
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
