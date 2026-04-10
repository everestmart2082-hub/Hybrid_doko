import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quickmartvender/features/Product/bloc/product_bloc.dart';
import 'package:quickmartvender/features/Product/bloc/product_event.dart';
import 'package:quickmartvender/features/Product/bloc/product_state.dart';
import 'package:quickmartvender/features/Product/data/product_detail_model.dart';
import 'package:quickmartvender/features/Product/data/product_input_model.dart';
import '../web_shell.dart';

String _categoryIdHex(Map<String, dynamic> c) {
  final v = c['_id'];
  if (v is String) return v;
  if (v is Map && v[r'$oid'] is String) return v[r'$oid'] as String;
  return '';
}

/// Parses admin-entered category field specs (comma/newline/semicolon list or JSON array).
List<String> parseCategoryFieldSpec(String raw) {
  final t = raw.trim();
  if (t.isEmpty) return [];
  try {
    final decoded = json.decode(t);
    if (decoded is List) {
      return decoded
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
  } catch (_) {}
  return t
      .split(RegExp(r'[,\n;]'))
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();
}

class ProductFormPage extends StatefulWidget {
  /// If [existing] is provided, the form is in edit mode.
  final ProductDetail? existing;

  const ProductFormPage({super.key, this.existing});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _brand = TextEditingController();
  final _shortDesc = TextEditingController();
  final _desc = TextEditingController();
  final _price = TextEditingController();
  final _discount = TextEditingController();
  final _stock = TextEditingController();

  String _unit = 'kg';
  String _category = '';
  String _deliveryCategory = '';
  List<Map<String, dynamic>> _categories = [];
  final Map<String, TextEditingController> _categoryFieldCtrls = {};
  List<String> _requiredCategoryFieldNames = [];
  List<String> _optionalCategoryFieldNames = [];
  List<XFile> _photos = [];
  bool _submitted = false;

  static const _units = [
    'kg',
    'g',
    'litre',
    'ml',
    'piece',
    'dozen',
    'box',
    'm',
    'cm',
  ];

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final p = widget.existing!;
      _name.text = p.name;
      _brand.text = p.brand;
      _shortDesc.text = p.shortDescription;
      _desc.text = p.description;
      _price.text = p.price.toString();
      _discount.text = p.discount.toString();
      _stock.text = p.stock.toString();
      _unit = p.unit.isNotEmpty ? p.unit : 'kg';
      _category = p.productCategory;
      _deliveryCategory = p.deliveryCategory;
    }
    context.read<ProductBloc>().add(GetProductFilters());
  }

  void _disposeCategoryFieldControllers() {
    for (final c in _categoryFieldCtrls.values) {
      c.dispose();
    }
    _categoryFieldCtrls.clear();
    _requiredCategoryFieldNames = [];
    _optionalCategoryFieldNames = [];
  }

  void _applyCategoryFieldControllersFromSelection() {
    _disposeCategoryFieldControllers();
    if (_category.isEmpty) {
      setState(() {});
      return;
    }
    Map<String, dynamic>? selected;
    for (final c in _categories) {
      if (_categoryIdHex(c) == _category) {
        selected = c;
        break;
      }
    }
    if (selected == null) {
      setState(() {});
      return;
    }
    _requiredCategoryFieldNames =
        parseCategoryFieldSpec(selected['required_fields']?.name.toString() ?? '');
    _optionalCategoryFieldNames =
        parseCategoryFieldSpec(selected['other_fields']?.toString() ?? '');
    final initial = _isEdit ? widget.existing!.categoryAttributes : const <String, String>{};
    final names = {
      ..._requiredCategoryFieldNames,
      ..._optionalCategoryFieldNames,
    };
    for (final name in names) {
      _categoryFieldCtrls[name] =
          TextEditingController(text: initial[name] ?? '');
    }
    setState(() {});
  }

  @override
  void dispose() {
    _name.dispose();
    _brand.dispose();
    _shortDesc.dispose();
    _desc.dispose();
    _price.dispose();
    _discount.dispose();
    _stock.dispose();
    _disposeCategoryFieldControllers();
    super.dispose();
  }

  Future<void> _pickPhotos() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage();
    if (files.isNotEmpty) setState(() => _photos.addAll(files));
  }

  Future<List<MultipartFile>> _buildMultiparts() async {
    final result = <MultipartFile>[];
    for (final f in _photos) {
      final bytes = await f.readAsBytes();
      result.add(
        MultipartFile.fromBytes(bytes, filename: f.name),
      );
    }
    return result;
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    for (final name in _requiredCategoryFieldNames) {
      final v = _categoryFieldCtrls[name]?.text.trim() ?? '';
      if (v.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Required category field: $name'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }
    final attrs = <String, String>{
      for (final e in _categoryFieldCtrls.entries) e.key: e.value.text.trim(),
    };
    final input = ProductInput(
      name: _name.text.trim(),
      brand: _brand.text.trim(),
      shortDescription: _shortDesc.text.trim(),
      description: _desc.text.trim(),
      pricePerUnit: double.tryParse(_price.text.trim()) ?? 0,
      unit: _unit,
      discount: double.tryParse(_discount.text.trim()) ?? 0,
      productCategory: _category,
      deliveryCategory: _deliveryCategory,
      stock: int.tryParse(_stock.text.trim()) ?? 0,
      photos: _photos.map((f) => f.path).toList(),
      categoryAttributes: attrs,
    );
    final files = await _buildMultiparts();

    if (_isEdit) {
      context.read<ProductBloc>().add(
        EditProduct(input, files, widget.existing!.id),
      );
    } else {
      context.read<ProductBloc>().add(AddProduct(input, files));
    }
  }

  void _delete() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              context.read<ProductBloc>().add(
                DeleteProduct(widget.existing!.id),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return WebShell(
      title: _isEdit ? 'Edit Product' : 'Add Product',
      child: BlocListener<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state is ProductFiltersLoaded) {
            _categories = state.categories;
            _applyCategoryFieldControllersFromSelection();
          }
          if (state is ProductSuccess) {
            if (_isEdit) {
              setState(() => _submitted = true);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            }
          }
          if (state is ProductError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: Colors.red),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Submitted banner
                  if (_submitted)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.amber.shade800,
                          ),
                          const SizedBox(width: 8),
                          const Text('Update submitted for review.'),
                        ],
                      ),
                    ),
                  _field(_name, 'Name'),
                  _field(_brand, 'Brand'),
                  _field(
                    _shortDesc,
                    'Short Description (max 50 words)',
                    maxLines: 2,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (v.trim().split(' ').length > 50)
                        return 'Max 50 words';
                      return null;
                    },
                  ),
                  _field(_desc, 'Description', maxLines: 4),
                  _field(
                    _price,
                    'Price per Unit',
                    keyboardType: TextInputType.number,
                  ),
                  // Unit dropdown
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    dropdownColor: Theme.of(context).primaryColorLight,
                    iconEnabledColor: Theme.of(context).primaryColorDark,
                    value: _units.contains(_unit) ? _unit : _units.first,
                    decoration: const InputDecoration(
                      labelText: 'Unit',
                      border: OutlineInputBorder(),
                    ),
                    items: _units
                        .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                        .toList(),
                    onChanged: (v) => setState(() => _unit = v ?? 'kg'),
                  ),
                  const SizedBox(height: 14),
                  _field(
                    _discount,
                    'Discount %',
                    keyboardType: TextInputType.number,
                    validator: (v) => null,
                  ),
                  // Delivery Category dropdown
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    dropdownColor: Theme.of(context).primaryColorLight,
                    iconEnabledColor: Theme.of(context).primaryColorDark,
                    value: _deliveryCategory.isNotEmpty ? _deliveryCategory : null,
                    hint: const Text('Select Delivery Type'),
                    decoration: const InputDecoration(
                      labelText: 'Delivery Category',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'quick', child: Text('Quick Delivery')),
                      DropdownMenuItem(value: 'normal', child: Text('Normal Delivery')),
                    ],
                    onChanged: (v) => setState(() => _deliveryCategory = v ?? ''),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  // Category dropdown
                  if (_categories.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      dropdownColor: Theme.of(context).primaryColorLight,
                      iconEnabledColor: Theme.of(context).primaryColorDark,
                      value: _category.isNotEmpty &&
                              _categories.any((c) => _categoryIdHex(c) == _category)
                          ? _category
                          : null,
                      hint: const Text('Select Category'),
                      decoration: const InputDecoration(
                        labelText: 'Product Category',
                        border: OutlineInputBorder(),
                      ),
                      items: _categories
                          .map((c) {
                            final id = _categoryIdHex(c);
                            if (id.isEmpty) return null;
                            return DropdownMenuItem(
                              value: id,
                              child: Text(c['name']?.toString() ?? ''),
                            );
                          })
                          .whereType<DropdownMenuItem<String>>()
                          .toList(),
                      onChanged: (v) {
                        setState(() => _category = v ?? '');
                        _applyCategoryFieldControllersFromSelection();
                      },
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                  ],
                  if (_categoryFieldCtrls.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Category fields',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Fill every required field. Optional fields can be left blank.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                    ),
                    ..._requiredCategoryFieldNames.map(
                      (name) => _categoryFieldTile(
                        context,
                        name,
                        requiredField: true,
                      ),
                    ),
                    ..._optionalCategoryFieldNames
                        .where((n) => !_requiredCategoryFieldNames.contains(n))
                        .map(
                          (name) => _categoryFieldTile(
                            context,
                            name,
                            requiredField: false,
                          ),
                        ),
                  ],
                  const SizedBox(height: 14),
                  _field(_stock, 'Stock', keyboardType: TextInputType.number),
                  const SizedBox(height: 16),
                  // Photo picker
                  Text('Photos', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ..._photos.map(
                        (f) => Chip(
                          label: Text(f.name, overflow: TextOverflow.ellipsis),
                          onDeleted: () => setState(() => _photos.remove(f)),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: _pickPhotos,
                        icon: const Icon(Icons.add_photo_alternate),
                        label: const Text('Add Photos'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: BlocBuilder<ProductBloc, ProductState>(
                          builder: (_, state) {
                            final loading = state is ProductLoading;
                            return ElevatedButton(
                              onPressed: _submitted || loading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              child: loading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      _isEdit
                                          ? 'Send For Update'
                                          : 'Add Product',
                                    ),
                            );
                          },
                        ),
                      ),
                      if (_isEdit) ...[
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _submitted ? null : _delete,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 20,
                            ),
                          ),
                          child: const Text('Delete'),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _categoryFieldTile(
    BuildContext context,
    String name, {
    required bool requiredField,
  }) {
    final ctrl = _categoryFieldCtrls[name];
    if (ctrl == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: TextFormField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: requiredField ? '$name *' : '$name (optional)',
          border: const OutlineInputBorder(),
        ),
        validator: requiredField
            ? (v) =>
                (v == null || v.trim().isEmpty) ? 'Required' : null
            : (_) => null,
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator:
            validator ??
            (v) =>
                (v == null || v.trim().isEmpty) ? '$label is required' : null,
      ),
    );
  }
}
