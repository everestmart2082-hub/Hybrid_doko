import 'package:flutter/material.dart';

import '../data/address_model.dart';
import 'addressEditPage.dart';

class AddressCard extends StatelessWidget {
  final AddressModel address;

  const AddressCard({required this.address});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddressFormPage(address: address),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LABEL HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    address.label,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  if (address.isDefault)
                    const Chip(
                      label: Text("Default"),
                      backgroundColor: Colors.green,
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // SUB ITEMS (ALL MODEL FIELDS)
              Text("City: ${address.city}"),
              Text("State: ${address.state}"),
              Text("Pincode: ${address.pincode}"),
              Text("Landmark: ${address.landmark}"),
              Text("Phone: ${address.phoneNumber}"),
              Text("Email: ${address.email}"),
            ],
          ),
        ),
      ),
    );
  }
}