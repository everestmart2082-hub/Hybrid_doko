import 'dart:convert';
import 'package:equatable/equatable.dart';

class VenderAuthToken extends Equatable {
  final String token;
  final String? userId;

  const VenderAuthToken({
    required this.token,
    this.userId,
  });

  @override
  List<Object?> get props => [token, userId];

  Map<String, dynamic> toMap() {
    return {"token": token, if (userId != null) "id": userId};
  }

  factory VenderAuthToken.fromMap(Map<String, dynamic> map) {
    return VenderAuthToken(
      token: map["token"]?.toString() ?? '',
      userId: map["id"]?.toString(),
    );
  }

  String toJson() => json.encode(toMap());

  factory VenderAuthToken.fromJson(String source) =>
      VenderAuthToken.fromMap(json.decode(source));

  @override
  bool get stringify => true;
}