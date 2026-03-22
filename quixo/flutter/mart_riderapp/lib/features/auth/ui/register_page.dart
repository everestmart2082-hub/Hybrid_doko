import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../data/rider_model.dart';

class RiderRegisterPage extends StatefulWidget {
  const RiderRegisterPage({super.key});

  @override
  State<RiderRegisterPage> createState() => _RiderRegisterPageState();
}

class _RiderRegisterPageState extends State<RiderRegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController bikeModelController = TextEditingController();
  final TextEditingController bikeNumberController = TextEditingController();
  final TextEditingController bikeColorController = TextEditingController();

  String bikeType = "bike"; // bike or scooter
  double rating = 0.0;

  File? rcBook;
  File? citizenship;
  File? panCard;
  File? insurance;

  final ImagePicker picker = ImagePicker();

  Future<void> pickImage(String type) async {
    final XFile? picked =
        await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        switch (type) {
          case "rcBook":
            rcBook = File(picked.path);
            break;
          case "citizenship":
            citizenship = File(picked.path);
            break;
          case "panCard":
            panCard = File(picked.path);
            break;
          case "insurance":
            insurance = File(picked.path);
            break;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Rider Registration")),
      body: BlocConsumer<RiderAuthBloc, RiderAuthState>(
        listener: (context, state) {
          if (state is RiderAuthSuccess && state.token != null) {
            Navigator.pushReplacementNamed(context, "/mainApp");
          }
          if (state is RiderAuthFailure) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is RiderAuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Full Name"),
                  ),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: "Phone"),
                  ),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: "Email"),
                  ),
                  TextField(
                    controller: addressController,
                    decoration: const InputDecoration(labelText: "Address"),
                  ),
                  TextField(
                    controller: bikeModelController,
                    decoration: const InputDecoration(labelText: "Bike Model"),
                  ),
                  TextField(
                    controller: bikeNumberController,
                    decoration: const InputDecoration(labelText: "Bike Number"),
                  ),
                  TextField(
                    controller: bikeColorController,
                    decoration: const InputDecoration(labelText: "Bike Color"),
                  ),
                  DropdownButton<String>(
                    value: bikeType,
                    onChanged: (v) => setState(() => bikeType = v!),
                    items: const [
                      DropdownMenuItem(value: "bike", child: Text("Bike")),
                      DropdownMenuItem(value: "scooter", child: Text("Scooter")),
                    ],
                  ),
                  const SizedBox(height: 8),
                  buildImagePicker("RC Book", rcBook, "rcBook"),
                  buildImagePicker("Citizenship", citizenship, "citizenship"),
                  buildImagePicker("Pan Card", panCard, "panCard"),
                  buildImagePicker("Insurance Paper", insurance, "insurance"),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate() &&
                          rcBook != null &&
                          citizenship != null &&
                          panCard != null &&
                          insurance != null) {
                        final model = RiderRegistrationModel(
                          name: nameController.text.trim(),
                          number: phoneController.text.trim(),
                          email: emailController.text.trim(),
                          rating: rating,
                          rcBook: rcBook!,
                          citizenship: citizenship!,
                          panCard: panCard!,
                          address: addressController.text.trim(),
                          bikeModel: bikeModelController.text.trim(),
                          bikeNumber: bikeNumberController.text.trim(),
                          bikeColor: bikeColorController.text.trim(),
                          type: bikeType,
                          bikeInsurancePaper: insurance!,
                        );

                        context
                            .read<RiderAuthBloc>()
                            .add(RiderRegisterRequested(model));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Please fill all fields")));
                      }
                    },
                    child: const Text("Register"),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildImagePicker(String label, File? file, String type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () => pickImage(type),
          child: Container(
            height: 80,
            width: double.infinity,
            color: Colors.grey[300],
            child: file != null
                ? Image.file(file, fit: BoxFit.cover)
                : Center(child: Text("Select $label")),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}