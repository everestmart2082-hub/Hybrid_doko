import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickmartcustomer/core/network/shared_pref.dart';
import 'package:quickmartcustomer/features/addresss/bloc/addresses_bloc.dart';
import 'package:quickmartcustomer/features/addresss/bloc/addresses_event.dart';
import 'package:quickmartcustomer/features/addresss/bloc/addresses_state.dart';
import 'package:quickmartcustomer/features/cart/bloc/cart_bloc.dart';
import 'package:quickmartcustomer/features/cart/bloc/cart_event.dart';
import 'package:quickmartcustomer/features/cart/bloc/cart_state.dart';
import 'package:quickmartcustomer/features/cart/data/cart_item_model.dart';
import 'package:quickmartcustomer/features/cart/data/cart_query_model.dart';
import 'package:quickmartcustomer/features/payment/bloc/payment_bloc.dart';
import 'package:quickmartcustomer/features/payment/bloc/payment_event.dart';
import 'package:quickmartcustomer/features/payment/bloc/payment_state.dart';
import 'package:quickmartcustomer/features/payment/data/checkout_request_model.dart';
import 'package:quickmartcustomer/widgets/customer_hub_bar_icons.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final SharedPreferencesProvider _prefs = SharedPreferencesProvider();

  String? _selectedAddressId;
  String _paymentMethod = 'cash on delivary'; // server expects this exact string for COD

  @override
  void initState() {
    super.initState();
    context.read<CartBloc>().add(const CartFetchRequested(CartQueryModel()));
    context.read<AddressBloc>().add(const AddressFetchRequested());
    // default address id may arrive later from prefs
    _loadDefaultAddress();
  }

  Future<void> _loadDefaultAddress() async {
    final defaultId = await _prefs.getKey('default_address_id');
    if (!mounted) return;
    setState(() {
      _selectedAddressId = defaultId;
    });
  }

  bool _isQuick(List<CartItemModel> items) {
    return items.any((e) => e.deliveryCategory.toLowerCase().contains('quick'));
  }

  double _subtotal(List<CartItemModel> items) {
    return items.fold<double>(
      0,
      (sum, e) => sum + ((e.pricePerUnit * (1 - (e.discount / 100))) * e.number),
    );
  }

  double _deliveryCharge(double subtotal, bool quick) {
    if (quick) return subtotal < 500 ? 50 : 0;
    return subtotal < 1000 ? 100 : 0;
  }

  double _discountAmount(List<CartItemModel> items) {
    return items.fold<double>(
      0,
      (sum, e) => sum + ((e.pricePerUnit * e.number) - ((e.pricePerUnit * (1 - (e.discount / 100))) * e.number)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorLight,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColorDark,
        title: Text('Checkout', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).primaryColorLight)),
        elevation: 1,
        actions: const [CustomerHubBarIcons()],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<PaymentBloc, PaymentState>(
            listener: (context, state) {
              if (state is PaymentSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
                Navigator.pushReplacementNamed(context, '/mainapp');
              } else if (state is PaymentFailed) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: BlocBuilder<AddressBloc, AddressState>(
            builder: (context, addressState) {
              if (addressState is AddressLoading || addressState is AddressInitial) {
                return const Center(child: CircularProgressIndicator());
              }
              if (addressState is! AddressLoaded) {
                return const Center(child: Text('Failed to load addresses'));
              }
              final addresses = addressState.addresses;

              return BlocBuilder<CartBloc, CartState>(
                builder: (context, cartState) {
                  if (cartState is CartLoading || cartState is CartInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (cartState is! CartLoaded) {
                    return const Center(child: Text('Failed to load cart'));
                  }
                  final cartItems = cartState.items;
                  final quick = _isQuick(cartItems);
                  final discountTotal = _discountAmount(cartItems);
                  final subtotal = _subtotal(cartItems);
                  final deliveryCharge = _deliveryCharge(subtotal, quick);
                  final vat = subtotal * 0.13;
                  final total = subtotal + deliveryCharge ;

                  final cartIds = cartItems.map((e) => e.id).where((e) => e.isNotEmpty).toList();

                  final effectiveSelectedAddressId =
                      _selectedAddressId ?? (addresses.isNotEmpty ? addresses.first.id : null);

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Select Address', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            if (addresses.isEmpty)
                              const Text('No addresses found. Add one from Addresses page.')
                            else
                              DropdownButtonFormField<String>(
                                value: effectiveSelectedAddressId,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                items: addresses
                                    .map((a) => DropdownMenuItem(
                                          value: a.id,
                                          child: Text('${a.label} - ${a.city}'),
                                        ))
                                    .toList(),
                                onChanged: (v) {
                                  setState(() => _selectedAddressId = v);
                                },
                              ),
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(context, '/addresses');
                              },
                              icon: const Icon(Icons.add_location_alt),
                              label: const Text('Create Address'),
                            ),
                            const SizedBox(height: 24),
                            const Text('Select Payment method', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            _paymentMethodOption('khalti', 'Khalti'),
                            _paymentMethodOption('esewa', 'Esewa'),
                            _paymentMethodOption('fonepay', 'Fonepay'),
                            _paymentMethodOption('cash on delivary', 'Cash on Delivery'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 2,
                        child: Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Items Total: ₹${(subtotal + discountTotal).toStringAsFixed(2)}'),
                                const SizedBox(height: 8),
                                Text('Discount: -₹${discountTotal.toStringAsFixed(2)}'),
                                const SizedBox(height: 8),
                                Text('Subtotal: ₹${subtotal.toStringAsFixed(2)}'),
                                const SizedBox(height: 8),
                                Text('Delivary Charge: ₹${deliveryCharge.toStringAsFixed(2)}'),
                                const SizedBox(height: 8),
                                // Text('VAT (13%): ₹${vat.toStringAsFixed(2)}'),
                                // const SizedBox(height: 8),
                                Text('Total: ₹${total.toStringAsFixed(2)}'),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: cartIds.isEmpty || effectiveSelectedAddressId == null
                                        ? null
                                        : () {
                                            final request = CheckoutRequestModel(
                                              addressId: effectiveSelectedAddressId,
                                              cartIds: cartIds,
                                              paymentMethod: _paymentMethod,
                                            );
                                            context.read<PaymentBloc>().add(
                                                  CheckoutRequested(request),
                                                );
                                          },
                                    child: const Text('Place Order Button'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _paymentMethodOption(String value, String label) {
    return RadioListTile<String>(
      value: value,
      groupValue: _paymentMethod,
      onChanged: (v) {
        if (v == null) return;
        setState(() => _paymentMethod = v);
      },
      title: Text(label),
      dense: true,
    );
  }
}

