import 'package:equatable/equatable.dart';

// ─── Constant Model ──────────────────────────────────────────────────────────
// Mirrors server models.Constant

class AdminConstantModel extends Equatable {
  final String id;
  final String name;
  final List<String> typesList;

  const AdminConstantModel({
    required this.id,
    required this.name,
    required this.typesList,
  });

  factory AdminConstantModel.fromMap(Map<String, dynamic> map) =>
      AdminConstantModel(
        id: map['_id']?.toString() ?? map['id']?.toString() ?? '',
        name: map['name'] as String? ?? '',
        typesList: (map['types_list'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
      );

  @override
  List<Object?> get props => [id, name, typesList];
}

// ─── Constant Update Request ─────────────────────────────────────────────────
// Server reads: c.PostForm("name"), c.PostForm("doingwhat"), c.PostFormArray("type list []")
// action: "add" | "remove" | "" (replace/set)

class AdminConstantUpdateRequest extends Equatable {
  final String name;
  final List<String> typesList;
  final String action; // "add", "remove", or "" for full replace

  const AdminConstantUpdateRequest({
    required this.name,
    required this.typesList,
    required this.action,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'doingwhat': action,       // exact server field name
        // "type list []" handled separately in FormData as list
      };

  @override
  List<Object?> get props => [name, typesList, action];
}
