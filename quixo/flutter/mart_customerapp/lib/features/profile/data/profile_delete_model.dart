import 'dart:convert';
import 'package:equatable/equatable.dart';

class ProfileDeleteModel extends Equatable {
  final String reason;
  final String option; // pause or delete

  const ProfileDeleteModel({
    required this.reason,
    required this.option,
  });

  @override
  List<Object> get props => [reason, option];

  Map<String, dynamic> toMap() {
    return {
      "reason": reason,
      "option": option,
    };
  }

  String toJson() => json.encode(toMap());

  factory ProfileDeleteModel.fromJson(String source) =>
      ProfileDeleteModel.fromMap(json.decode(source));

  factory ProfileDeleteModel.fromMap(Map<String, dynamic> map) {
    return ProfileDeleteModel(
      reason: map["reason"],
      option: map["option"],
    );
  }
}