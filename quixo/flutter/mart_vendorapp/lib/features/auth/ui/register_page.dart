import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quickmartvender/drawer.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../data/auth_model.dart';
import '../data/otp_verify_model.dart';


class VenderRegisterPage extends StatefulWidget {
  const VenderRegisterPage({super.key});

  @override
  State<VenderRegisterPage> createState() => _VenderRegisterPageState();
}

class _VenderRegisterPageState extends State<VenderRegisterPage> {

  final formKey = GlobalKey<FormState>();

  final name = TextEditingController();
  final phone = TextEditingController();
  final email = TextEditingController();
  final pan = TextEditingController();
  final store = TextEditingController();
  final address = TextEditingController();
  final businessType = TextEditingController();
  final description = TextEditingController();
  final geo = TextEditingController();
  final otp = TextEditingController();

  File? panFile;
  File? licenseFile;

  bool showOtp = false;

  final ImagePicker picker = ImagePicker();

  Future<void> pickPan() async {

    final picked = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (picked != null) {
      setState(() {
        panFile = File(picked.path);
      });
    }
  }

  Future<void> pickLicense() async {

    final picked = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (picked != null) {
      setState(() {
        licenseFile = File(picked.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    return BlocConsumer<VenderAuthBloc, VenderAuthState>(

      listener: (context, state) {

        if (state is VenderAuthenticated && state.authenticated) {
          Navigator.pop(context);
        }

        if (state is VenderAuthFailed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }

      },

      builder: (context, state) {

        return Scaffold(

          appBar: AppBar(
            title: const Text("Vendor Registration"),
          ),
          drawer: buildAppDrawer(context),

          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColorLight
              ),
            child: SingleChildScrollView(
            
              padding: const EdgeInsets.all(20),
            
              child: Form(
            
                key: formKey,
            
                child: Column(
            
                  children: [
            
                    _field(name, "Name"),
            
                    _field(phone, "Phone"),
            
                    _field(email, "Email"),
            
                    _field(store, "Store Name"),
            
                    _field(pan, "PAN Number"),
            
                    _field(address, "Address"),
            
                    _field(businessType, "Business Type"),
            
                    _field(description, "Description"),
            
                    _field(geo, "Geo Location"),
            
                    const SizedBox(height: 16),
            
                    /// PAN Upload
                    _fileUpload(
                      title: "Upload PAN Card",
                      file: panFile,
                      onTap: pickPan,
                    ),
            
                    const SizedBox(height: 12),
            
                    /// License Upload
                    _fileUpload(
                      title: "Upload Business License",
                      file: licenseFile,
                      onTap: pickLicense,
                    ),
            
                    const SizedBox(height: 20),
            
                    if (showOtp)
                      _field(otp, "OTP"),
            
                    const SizedBox(height: 20),
            
                    SizedBox(
            
                      width: double.infinity,
            
                      child: ElevatedButton(
            
                        onPressed: state is VenderAuthLoading
                            ? null
                            : () async {
            
                          if (!showOtp) {
            
                            if (!formKey.currentState!.validate()) return;
            
                            if (panFile == null || licenseFile == null) {
            
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Upload required documents"),
                                ),
                              );
            
                              return;
                            }
            
                            MultipartFile panMultipart =
                                await MultipartFile.fromFile(panFile!.path);
            
                            MultipartFile licenseMultipart =
                                await MultipartFile.fromFile(licenseFile!.path);
            
                            context.read<VenderAuthBloc>().add(
            
                              VenderRegister(
            
                                input: VenderAuthModel(
                                  name: name.text,
                                  number: phone.text,
                                  pan: pan.text,
                                  storeName: store.text,
                                  address: address.text,
                                  email: email.text,
                                  businessType: businessType.text,
                                  description: description.text,
                                  geolocation: geo.text,
                                ),
            
                                files: [
                                  panMultipart,
                                  licenseMultipart,
                                ],
            
                              ),
            
                            );
            
                            setState(() {
                              showOtp = true;
                            });
            
                          } else {
            
                            context.read<VenderAuthBloc>().add(
            
                              VenderRegisterOtpVerify(
            
                                input: VenderOtpVerifyModel(
                                  otp: otp.text,
                                  phone: phone.text,
                                ),
            
                              ),
            
                            );
            
                          }
            
                        },
            
                        child: state is VenderAuthLoading
                            ? const CircularProgressIndicator()
                            : Text(showOtp ? "Verify OTP" : "Submit Application"),
            
                      ),
                    )
            
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _field(TextEditingController c, String label) {

    return Padding(

      padding: const EdgeInsets.only(bottom: 12),

      child: TextFormField(

        controller: c,

        decoration: InputDecoration(
          labelText: label,
          labelStyle: Theme.of(context).textTheme.bodyMedium,
          border: const OutlineInputBorder(),
        ),

        validator: (v) {

          if (v == null || v.isEmpty) {
            return "$label required";
          }

          return null;
        },
      ),
    );
  }

  Widget _fileUpload({
    required String title,
    required File? file,
    required VoidCallback onTap,
  }) {

    return Column(

      crossAxisAlignment: CrossAxisAlignment.center,


      children: [

        Text(title),

        const SizedBox(height: 6),

        ElevatedButton(
          onPressed: onTap,
          child: const Text("Select File"),
        ),

        if (file != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              file.path.split('/').last,
              style: const TextStyle(color: Colors.green),
            ),
          )

      ],
    );
  }
}