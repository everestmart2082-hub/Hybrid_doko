import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickmartcustomer/features/addresss/bloc/addresses_bloc.dart';
import 'package:quickmartcustomer/features/addresss/bloc/addresses_state.dart';
import 'package:quickmartcustomer/features/addresss/data/address_model.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_state.dart';
import '../bloc/profile_event.dart';
import '../data/profile_model.dart';

class EditProfilePage extends StatefulWidget {
  final ProfileModel profile;

  const EditProfilePage({super.key, required this.profile});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController name;
  late TextEditingController phone;
  late TextEditingController email;
  late TextEditingController description;

  AddressModel? selectedAddress;

  @override
  void initState() {
    super.initState();

    name = TextEditingController(text: widget.profile.name);
    phone = TextEditingController(text: widget.profile.phone);
    email = TextEditingController(text: widget.profile.email);
    description = TextEditingController(text: widget.profile.description);

    // Load default address from AddressBloc
    final addressState = context.read<AddressBloc>().state;
    if (addressState is AddressLoaded) {
      selectedAddress = addressState.addresses.firstWhere(
        (a) => a.isDefault,
        orElse: () => addressState.addresses.isNotEmpty ? addressState.addresses[0] : AddressModel(id: "0", label: "", city: "", state: "", pincode: "0", landmark: "", phoneNumber: "", email: "", isDefault: false) ,
      );
    }
  }

  @override
  void dispose() {
    name.dispose();
    phone.dispose();
    email.dispose();
    description.dispose();
    super.dispose();
  }

  void updateProfile() {
    final model = ProfileModel(
      name: name.text,
      phone: phone.text,
      email: email.text,
      defaultAddress: selectedAddress != null
          ? "${selectedAddress!.label}, ${selectedAddress!.city}, ${selectedAddress!.state} - ${selectedAddress!.pincode}"
          : "",
      description: description.text,
    );

    context.read<ProfileBloc>().add(ProfileUpdate(model));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile"), elevation: 0),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, theme.primaryColorLight],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: BlocConsumer<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is ProfileSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Profile updated successfully")),
              );
              Navigator.pop(context);
            }
            if (state is ProfileFailed) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            final loading = state is ProfileLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: theme.dividerColor.withOpacity(0.2), blurRadius: 8)],
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: name,
                      decoration: const InputDecoration(labelText: "Name"),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: phone,
                      decoration: const InputDecoration(labelText: "Phone"),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: email,
                      decoration: const InputDecoration(labelText: "Email"),
                    ),
                    const SizedBox(height: 12),

                    // Default Address dropdown
                    BlocBuilder<AddressBloc, AddressState>(
                      builder: (context, addrState) {
                        if (addrState is AddressLoading) {
                          return const CircularProgressIndicator();
                        }

                        if (addrState is AddressLoaded && addrState.addresses.isNotEmpty) {
                          return DropdownButtonFormField<AddressModel>(
                            value: selectedAddress,
                            items: addrState.addresses.map((address) {
                              return DropdownMenuItem(
                                value: address,
                                child: Text(
                                    "${address.label}, ${address.city}, ${address.state} - ${address.pincode}"),
                              );
                            }).toList(),
                            onChanged: (value) => setState(() => selectedAddress = value),
                            decoration: const InputDecoration(labelText: "Default Address"),
                          );
                        }

                        return const Text("No saved addresses found");
                      },
                    ),

                    const SizedBox(height: 12),
                    TextField(
                      controller: description,
                      decoration: const InputDecoration(labelText: "Description"),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: loading ? null : updateProfile,
                        child: loading
                            ? const CircularProgressIndicator()
                            : const Text("Update"),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}