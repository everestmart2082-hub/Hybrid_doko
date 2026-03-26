import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/addresses_bloc.dart';
import '../bloc/addresses_event.dart';
import '../data/address_model.dart';
import '../data/address_request_model.dart';

class AddressFormPage extends StatefulWidget {
  final AddressModel? address;

  const AddressFormPage({super.key, this.address});

  @override
  State<AddressFormPage> createState() => _AddressFormPageState();
}

class _AddressFormPageState extends State<AddressFormPage> {
  final _formKey = GlobalKey<FormState>();

  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final pincodeController = TextEditingController();
  final landmarkController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();

  String selectedLabel = "Home";
  bool isDefault = false;

  @override
  void initState() {
    super.initState();

    if (widget.address != null) {
      final a = widget.address!;
      cityController.text = a.city;
      stateController.text = a.state;
      pincodeController.text = a.pincode;
      landmarkController.text = a.landmark;
      phoneController.text = a.phoneNumber;
      emailController.text = a.email;
      selectedLabel = a.label;
      isDefault = a.isDefault;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.address != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Address" : "Add Address"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [

              /// LABEL SELECTION
              const Text("Select Label"),
              const SizedBox(height: 8),

              Wrap(
                spacing: 10,
                children: ["Home", "Work", "Others"]
                    .map(
                      (label) => ChoiceChip(
                        label: Text(label),
                        selected: selectedLabel == label,
                        onSelected: (_) {
                          setState(() {
                            selectedLabel = label;
                          });
                        },
                      ),
                    )
                    .toList(),
              ),

              const SizedBox(height: 16),

              _buildField(cityController, "City"),
              _buildField(stateController, "State"),
              _buildField(pincodeController, "Pincode"),
              _buildField(landmarkController, "Landmark"),
              _buildField(phoneController, "Phone Number"),
              _buildField(emailController, "Email"),

              SwitchListTile(
                value: isDefault,
                onChanged: (v) {
                  setState(() => isDefault = v);
                },
                title: const Text("Set as Default"),
              ),

              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: _submit,
                child: Text(isEdit ? "Update" : "Add"),
              ),

              if (isEdit)
                TextButton(
                  onPressed: () {
                    context.read<AddressBloc>().add(
                          AddressDeleteRequested(
                              widget.address!.id),
                        );
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Delete Address",
                    style: TextStyle(color: Colors.red),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
      TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (v) =>
            v == null || v.isEmpty ? "Required" : null,
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final request = AddressRequestModel(
      addressId: widget.address?.id,
      label: selectedLabel,
      city: cityController.text,
      state: stateController.text,
      pincode: pincodeController.text,
      landmark: landmarkController.text,
      phoneNumber: phoneController.text,
      email: emailController.text,
      isDefault: isDefault,
    );

    if (widget.address == null) {
      context
          .read<AddressBloc>()
          .add(AddressAddRequested(request));
    } else {
      context
          .read<AddressBloc>()
          .add(AddressUpdateRequested(request));
    }

    Navigator.pop(context);
  }
}