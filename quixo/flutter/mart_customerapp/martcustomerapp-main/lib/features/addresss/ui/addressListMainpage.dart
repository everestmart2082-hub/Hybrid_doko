import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/addresses_bloc.dart';
import '../bloc/addresses_event.dart';
import '../bloc/addresses_state.dart';
import '../data/address_model.dart';
import 'addressCard.dart';
import 'addressEditPage.dart';

class AddressPage extends StatefulWidget {
  const AddressPage({super.key});

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  @override
  void initState() {
    super.initState();
    context.read<AddressBloc>().add(
          const AddressFetchRequested(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Addresses")),
      body: BlocConsumer<AddressBloc, AddressState>(
        listener: (context, state) {
          if (state is AddressActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );

            context
                .read<AddressBloc>()
                .add(const AddressFetchRequested());
          }
        },
        builder: (context, state) {
          if (state is AddressLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AddressFailed) {
            return Center(child: Text(state.message));
          }

          if (state is AddressLoaded) {
            if (state.addresses.isEmpty) {
              return const Center(child: Text("No addresses added yet"));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.addresses.length,
              itemBuilder: (context, index) {
                final address = state.addresses[index];
                return AddressCard(address: address);
              },
            );
          }

          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddressFormPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}