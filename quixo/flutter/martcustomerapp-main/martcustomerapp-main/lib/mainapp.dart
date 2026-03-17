import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickmartcustomer/core/constants/app_constants.dart';
import 'package:quickmartcustomer/features/auth/bloc/auth_bloc.dart';
import 'package:quickmartcustomer/features/auth/bloc/auth_event.dart';
import 'package:quickmartcustomer/features/cart/bloc/cart_event.dart';
import 'package:quickmartcustomer/features/cart/data/cart_model.dart';
import 'package:quickmartcustomer/features/product/bloc/product_bloc.dart';
import 'package:quickmartcustomer/features/cart/bloc/cart_bloc.dart';
import 'package:quickmartcustomer/features/product/bloc/product_event.dart';
import 'package:quickmartcustomer/features/product/bloc/product_state.dart';
import 'package:quickmartcustomer/features/product/data/product_list_item_model.dart';
import 'package:quickmartcustomer/features/product/data/product_model.dart';

import 'drawer.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(AuthCheck());
    context.read<ProductBloc>().add(ProductFetchRecommendedRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppConstants.appName), elevation: 0),
      drawer: buildAppDrawer(context),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Theme.of(context).primaryColorLight,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _heroSection(context),
              const SizedBox(height: 24),
              _categoriesSection(),
              const SizedBox(height: 24),
              _recommendedSection(),
              const SizedBox(height: 24),
              _featuresSection(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _heroSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColorLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Image.asset(
            "assets/images/pngs/mountain.png",
            width: 120,
            height: 120,
            alignment: Alignment.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Premium Groceries and daily, within 30 minutes',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Handpicked Quality at your Doorsteps',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          _searchBar(context),
        ],
      ),
    );
  }

  Widget _searchBar(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/products');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Row(
          children: const [
            Expanded(
              child: Text(
                'Search for products',
                style: TextStyle(color: Colors.black),
              ),
            ),
            Icon(Icons.search, color: Colors.black),
          ],
        ),
      ),
    );
  }

  Widget _categoriesSection() {
    final categories = ['groceries', 'gifts', 'fruits', 'vegetables'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Collections',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            children: categories
                .map(
                  (c) => Chip(
                    label: Text(c),
                    backgroundColor: Colors.grey.shade200,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  // ============================
  // Recommended Products Section
  Widget _recommendedSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recommended for You',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 260,
            child: BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                if (state is ProductLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ProductRecommendedLoaded) {
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: state.recommendedProducts.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      final p = state.recommendedProducts[index];
                      return _productCard(p);
                    },
                  );
                } else if (state is ProductFailed) {
                  return Center(child: Text(state.message));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _productCard(ProductListItem p) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/product-detail', arguments: p);
      },
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
              child: Image.network(
                p.images.first,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text('₹${p.pricePerUnit}'),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<CartBloc>().add(CartAddRequested(CartAddRequestModel(number: 1, productId: p.id)));
                      },
                      child: const Text('Add to Cart'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================
  Widget _featuresSection() {
    final features = [
      ('01', 'Express Delivery', 'Delivered within 30 minutes', '02',
          'Premium Quality', 'Hand picked products'),
      ('03', 'Best Value', 'Competitive pricing', '04', 'Live Tracking',
          'Track your delivery'),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColorLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: features
            .map(
              (f) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _featureColumn(f.$1, f.$2, f.$3),
                  _featureColumn(f.$4, f.$5, f.$6),
                ],
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _featureColumn(String title, String subtitle, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColorDark),
          ),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                subtitle,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColorDark),
              ),
              SizedBox(
                width: 120,
                child: Text(
                  description,
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(color: Theme.of(context).primaryColorDark),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}