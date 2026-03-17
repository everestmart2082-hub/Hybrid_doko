import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickmartcustomer/features/addresss/bloc/addresses_bloc.dart';
import 'package:quickmartcustomer/features/addresss/bloc/addresses_event.dart';
import 'package:quickmartcustomer/features/addresss/bloc/addresses_state.dart';
import 'package:quickmartcustomer/features/addresss/data/address_model.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../data/profile_model.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(ProfileGet());
    context.read<AddressBloc>().add(const AddressFetchRequested());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Profile"), elevation: 0),
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
            if (state is ProfileFailed) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, profileState) {
            if (profileState is ProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (profileState is ProfileLoaded) {
              return _buildProfile(context, profileState.profile);
            }

            return Center(
              child: Text("No profile found", style: theme.textTheme.bodyLarge),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfile(BuildContext context, ProfileModel profile) {
    final theme = Theme.of(context);

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _item(context, "Name", profile.name),
            _item(context, "Phone", profile.phone),
            _item(context, "Email", profile.email),

            // Default Address from AddressBloc
            BlocBuilder<AddressBloc, AddressState>(
              builder: (context, state) {
                String addressText = "No default address";
                if (state is AddressLoaded) {
                  final defaultAddress = state.addresses.firstWhere(
                    (addr) => addr.isDefault,
                    orElse: () => AddressModel(
                      id: "",
                      label: "",
                      city: "",
                      state: "",
                      pincode: "",
                      landmark: "",
                      phoneNumber: "",
                      email: "",
                      isDefault: false,
                    ),
                  );

                  if (defaultAddress.id.isNotEmpty) {
                    addressText =
                        "${defaultAddress.label}, ${defaultAddress.city}, ${defaultAddress.state} - ${defaultAddress.pincode}";
                    if (defaultAddress.landmark.isNotEmpty) {
                      addressText += "\nLandmark: ${defaultAddress.landmark}";
                    }
                  }
                }
                return _item(context, "Default Address", addressText);
              },
            ),

            _item(context, "Description", profile.description),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => EditProfilePage(profile: profile)),
                  );
                  context.read<ProfileBloc>().add(ProfileGet());
                },
                child: const Text("Edit Profile"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(BuildContext context, String title, String value) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.labelMedium),
          const SizedBox(height: 4),
          Text(value, style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }
}