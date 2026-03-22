import 'dart:convert';
import 'package:equatable/equatable.dart';

class ProfileDeleteModel extends Equatable {

  final String reason;
  final String option;

  const ProfileDeleteModel({
    required this.reason,
    required this.option,
  });

  @override
  List<Object?> get props => [reason, option];

  Map<String, dynamic> toMap() {
    return {
      "reason": reason,
      "options": option,
    };
  }

  String toJson() => json.encode(toMap());
}