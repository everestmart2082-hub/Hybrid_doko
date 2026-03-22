import 'dart:convert';
import 'package:equatable/equatable.dart';

class VenderAuthToken extends Equatable {
  final String token;

  const VenderAuthToken({
    required this.token,
  });

  @override
  List<Object> get props => [token];

  Map<String, dynamic> toMap() {
    return {"token": token};
  }

  factory VenderAuthToken.fromMap(Map<String, dynamic> map) {
    return VenderAuthToken(
      token: map["token"],
    );
  }

  String toJson() => json.encode(toMap());

  factory VenderAuthToken.fromJson(String source) =>
      VenderAuthToken.fromMap(json.decode(source));

  @override
  bool get stringify => true;
}