// ignore_for_file: public_member_api_docs, sort_constructors_first


import 'dart:convert';

import 'package:equatable/equatable.dart';

class AuthToken extends Equatable {
  final String token;


  const AuthToken({
    required this.token,
  });

  @override
  List<Object> get props => [token];
  

  AuthToken copyWith({
    String? token,
  }) {
    return AuthToken(
      token: token ?? this.token,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'token': token,
    };
  }

  factory AuthToken.fromMap(Map<String, dynamic> map) {
    return AuthToken(
      token: map['token'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory AuthToken.fromJson(String source) => AuthToken.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;
}
