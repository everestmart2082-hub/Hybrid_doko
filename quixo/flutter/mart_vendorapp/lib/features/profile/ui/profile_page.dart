import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../data/profile_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  final name = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final address = TextEditingController();
  final pan = TextEditingController();
  final storeName = TextEditingController();
  final businessType = TextEditingController();
  final description = TextEditingController();

  @override
  void initState() {
    super.initState();

    context.read<ProfileBloc>().add(LoadProfile());
  }

  void _fillData(ProfileModel p) {
    name.text = p.name;
    email.text = p.email;
    phone.text = p.number;
    address.text = p.address;
    pan.text = p.pan;
    storeName.text = p.storeName;
    businessType.text = p.businessType;
    description.text = p.description;
  }

  void _save() {

    final model = ProfileModel(
      name: name.text,
      number: phone.text,
      pan: pan.text,
      storeName: storeName.text,
      address: address.text,
      email: email.text,
      businessType: businessType.text,
      description: description.text,
      geolocation: "",
    );

    context.read<ProfileBloc>().add(
          UpdateProfile(profile: model),
        );
  }

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),

      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {

          if (state is ProfileLoaded) {
            _fillData(state.profile);
          }

          if (state is ProfileUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Profile Updated")),
            );
          }

          if (state is ProfileFailed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },

        builder: (context, state) {

          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Container(
            padding: const EdgeInsets.all(16),

            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  theme.primaryColorLight,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),

            child: SingleChildScrollView(
              child: Column(
                children: [

                  _field("Owner Name", name),
                  _field("Email", email),
                  _field("Phone", phone),

                  const SizedBox(height: 16),

                  _field("PAN", pan),

                  _field("Business Name", storeName),

                  _field("Store Name", storeName),

                  _field("Business Type", businessType),

                  _field("Address", address),

                  _field("Description", description, lines: 4),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _save,
                      child: const Text("Update Profile"),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    int lines = 1,
  }) {

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),

      child: TextField(
        controller: controller,
        maxLines: lines,

        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}