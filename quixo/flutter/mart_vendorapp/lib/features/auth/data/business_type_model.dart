import 'dart:convert';
import 'package:equatable/equatable.dart';

class BusinessTypeModel extends Equatable {
  final int id;
  final String name;

  const BusinessTypeModel({
    required this.id,
    required this.name,
  });

  factory BusinessTypeModel.fromMap(Map<String, dynamic> map) {
    return BusinessTypeModel(
      id: map['id']?.toInt() ?? 0,
      name: map['name'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory BusinessTypeModel.fromJson(String source) => BusinessTypeModel.fromMap(json.decode(source));

  String toJson() => json.encode(toMap());

  @override
  List<Object?> get props => [id, name];
}
