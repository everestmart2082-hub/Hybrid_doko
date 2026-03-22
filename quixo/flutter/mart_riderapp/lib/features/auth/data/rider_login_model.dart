import 'package:equatable/equatable.dart';

class RiderLoginModel extends Equatable {
  final String phone;

  const RiderLoginModel({required this.phone});

  Map<String, dynamic> toJson() {
    return {
      "phone": phone,
    };
  }

  @override
  List<Object?> get props => [phone];
}